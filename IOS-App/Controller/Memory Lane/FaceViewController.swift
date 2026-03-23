import UIKit

final class FaceViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var optionsStack: UIStackView!
    @IBOutlet private weak var tapHintLabel: UILabel!
    @IBOutlet private weak var zoomContainerView: UIView!
    @IBOutlet private var optionButtons: [UIButton]!
    @IBOutlet private weak var textAnswerContainerView: UIView!
    @IBOutlet weak var textAnswerTextView: UITextView!
    @IBOutlet weak var transitionLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!

    // MARK: - Injected Data

    private var isRecapTransitioning = false
    var wholeImage: WholeImage!
    var faces: [Face] = []
    var questionsByPerson: [String: [Question]] = [:]
    var portraitImage: UIImage!

    // MARK: - State

    private var lastMCQAnswerID: UUID?
    private var currentFaceIndex = 0
    private var currentQuestionIndex = 0
    private var isFaceComplete = false
    private var isInFinalReflection = false
    private var hasShownFinalReflectionInRecap = false
    private var imageSessionReady = false

    /// Cache of generated questions per face index.
    /// This ensures the same Question objects (with their positiveOptions)
    /// are used both when displaying buttons and when checking answers.
    private var cachedQuestionsForFace: [Int: [Question]] = [:]

    // MARK: - Session Data

    private var currentImageSession: ImageSession!
    private var currentPersonSession: PersonSession?
    private var personSessions: [PersonSession] = []
    private var personSessionAnswers: [PersonSessionQuestion] = []
    private var imageSessionAnswers: [ImageSessionQuestion] = []

    enum SessionMode {
        case play
        case recap
    }

    // MARK: - Session Mode

    var sessionMode: SessionMode = .play

    // Inject this when launching recap
    var recapImageSession: ImageSession?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if sessionMode == .play {
            initializeSession()
        }
        configureUI()
        loadImage()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.layoutIfNeeded()
        imageView.layoutIfNeeded()

        // ✅ Only start immediately for recap — play mode waits for session insert
        if sessionMode == .recap {
            startFaceFlow()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Session Management

    private func initializeSession() {
        guard sessionMode == .play else { return }
        currentImageSession = ImageSession(
            isid: UUID(),
            wid: wholeImage.wid,
            sessionType: .memoryLane,
            startedAt: Date(),
            endedAt: nil,
            recapCount: 0
        )

        Task {
            await SupabaseSyncManager.shared.insertImageSession(currentImageSession)

            await MainActor.run {
                self.imageSessionReady = true
                // ✅ Now safe to start — session is confirmed inserted
                self.startFaceFlow()
            }

            print("☁️ ImageSession inserted")
        }

        print("\n🟢 IMAGE SESSION STARTED")
        print("   Session ID: \(currentImageSession.isid)")
        print("   Image ID: \(currentImageSession.wid)")
        print("   Started at: \(currentImageSession.startedAt)")
    }

    private func createPersonSession(for face: Face) {

        guard imageSessionReady else {
            print("⚠️ ImageSession not ready yet, skipping PersonSession creation")
            return
        }

        let name = face.personName ?? "Unknown"

        let personSession = PersonSession(
            psid: UUID(),
            isid: currentImageSession.isid,
            fid: face.fid
        )

        currentPersonSession = personSession
        personSessions.append(personSession)

        PersonSessionStore.shared.add(personSession)

        Task {
            await SupabaseSyncManager.shared.insertPersonSession(personSession)
        }

        print("\n👤 PERSON SESSION STARTED")
        print("   Name: \(name)")
        print("   Session ID: \(personSession.psid)")
    }

    private func savePersonResponse(
        question: Question,
        selectedOption: String? = nil,
        responseText: String? = nil,
        wasPositive: Bool? = nil
    ) {
        guard let personSession = currentPersonSession else {
            print("❌ No current person session")
            return
        }

        let answer = PersonSessionQuestion(
            psqid: UUID(),
            psid: personSession.psid,
            qid: question.qid,
            responseText: responseText,
            selectedOption: selectedOption,
            answeredAt: Date(),
            wasPositive: wasPositive
        )

        personSessionAnswers.append(answer)
        PersonSessionQuestionStore.shared.add(answer)
        Task {
            await SupabaseSyncManager.shared.insertPersonSessionQuestion(answer)
            print("✅ Supabase insert done for: \(answer.selectedOption ?? answer.responseText ?? "nil")")
        }

        print("\n💾 PERSON RESPONSE SAVED")
        print("   Question: \(question.prompt)")
        print("   Type: \(question.type)")
        if let selected = selectedOption {
            print("   Selected: \(selected)")
            print("   Was Positive: \(wasPositive == true ? "✅" : "❌")")
        }
        if let text = responseText {
            print("   Text: \"\(text)\"")
        }
        print("   Answer ID: \(answer.psqid)")
    }

    private func saveFinalReflection(text: String) {
        let questionID = AppDataStore.shared.reflectionQuestion.qid

        let answer = ImageSessionQuestion(
            isqid: UUID(),
            isid: currentImageSession.isid,
            qid: questionID,
            responseText: text,
            selectedOption: nil,
            answeredAt: Date()
        )

        imageSessionAnswers.append(answer)
        ImageSessionQuestionStore.shared.add(answer)
        Task {
            await SupabaseSyncManager.shared.insertImageSessionQuestion(answer)
        }

        print("\n💭 FINAL REFLECTION SAVED")
        print("   Reflection: \"\(text)\"")
        print("   Answer ID: \(answer.isqid)")
    }

    private func completeSession() {

        currentImageSession.endedAt = Date()

        SessionImageStore.shared.saveSessionImage(for: currentImageSession.wid)

        ImageSessionStore.shared.addSession(currentImageSession)
        Task {
            await SupabaseSyncManager.shared.updateImageSessionEnd(
                isid: currentImageSession.isid,
                endedAt: currentImageSession.endedAt!
            )
        }

        print("✅ ImageSession persisted")
        printSessionSummary()
    }

    private func printSessionSummary() {
        print("\n" + String(repeating: "=", count: 70))
        print("📊 SESSION SUMMARY")
        print(String(repeating: "=", count: 70))

        print("\n🔷 Image Session:")
        print("   Session ID: \(currentImageSession.isid)")
        print("   Image ID: \(currentImageSession.wid)")
        print("   Type: \(currentImageSession.sessionType.rawValue)")
        print("   Started: \(currentImageSession.startedAt)")
        if let endedAt = currentImageSession.endedAt {
            let duration = endedAt.timeIntervalSince(currentImageSession.startedAt)
            print("   Ended: \(endedAt)")
            print("   Duration: \(Int(duration)) seconds")
        }

        print("\n👥 Person Sessions: \(personSessions.count)")
        for (index, session) in personSessions.enumerated() {

            print("\n   [\(index + 1)] \(session.fid)")
            print("       Session ID: \(session.psid)")

            let answers = personSessionAnswers.filter { $0.psid == session.psid }
            print("       Responses: \(answers.count)")

            for (answerIndex, answer) in answers.enumerated() {
                print("\n       Response [\(answerIndex + 1)]:")
                print("         Type: \(answer.selectedOption != nil ? "MCQ" : "Text")")

                if let selected = answer.selectedOption {
                    print("         Selected: \(selected)")
                    print("         Positive: \(answer.wasPositive == true ? "✅" : "❌")")
                }

                if let text = answer.responseText {
                    print("         Text: \"\(text)\"")
                }
            }
        }

        print("\n💭 Final Reflection:")
        if let reflection = imageSessionAnswers.first {
            print("   Response: \"\(reflection.responseText ?? "N/A")\"")
        } else {
            print("   Not completed")
        }

        let totalPersonResponses = personSessionAnswers.count
        let mcqCount = personSessionAnswers.filter { $0.selectedOption != nil }.count
        let textCount = personSessionAnswers.filter { $0.responseText != nil && !$0.responseText!.isEmpty }.count
        let positiveCount = personSessionAnswers.filter { $0.wasPositive == true }.count

        print("\n📈 Statistics:")
        print("   Total Person Responses: \(totalPersonResponses)")
        print("   MCQ Responses: \(mcqCount)")
        print("   Text Responses: \(textCount)")
        print("   Positive MCQs: \(positiveCount)")
        print("   People Viewed: \(personSessions.count)")
        print("   Final Reflection: \(imageSessionAnswers.isEmpty ? "No" : "Yes")")
        print("\n" + String(repeating: "=", count: 70))
        print("\n")
    }

    private func makeLowResolutionImage(from image: UIImage) -> UIImage {

        let scale: CGFloat = 0.08

        let targetSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        UIGraphicsBeginImageContextWithOptions(targetSize, true, 1)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let lowResImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return lowResImage ?? image
    }

    // MARK: - UI Setup

    private func configureUI() {
        imageView.contentMode = .scaleAspectFit
        zoomContainerView.clipsToBounds = true

        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true

        questionLabel.alpha = 0
        optionsStack.alpha = 0

        textAnswerContainerView.alpha = 0
        textAnswerContainerView.isHidden = true
        textAnswerContainerView.isUserInteractionEnabled = false
        textAnswerContainerView.layer.cornerRadius = 30
        textAnswerContainerView.layer.masksToBounds = true

        textAnswerTextView.delegate = self
        textAnswerTextView.font = UIFont.systemFont(ofSize: 16)
        textAnswerTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textAnswerTextView.backgroundColor = .white
        textAnswerTextView.layer.cornerRadius = 12
        textAnswerTextView.isScrollEnabled = true
        textAnswerTextView.returnKeyType = .done

        tapHintLabel.text = "Tap to move forward"

        transitionLabel.alpha = 0
        transitionLabel.textAlignment = .center
        transitionLabel.numberOfLines = 0
        transitionLabel.textColor = .white
        transitionLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        setupKeyboardObservers()
    }

    private func loadImage() {
        if sessionMode == .recap,
           let image = SessionImageStore.shared.fetchImage(by: wholeImage.wid) {
            imageView.image = image
            backgroundImageView.image = image
            return
        }

        guard let image = LocalImageStore.shared.fetchImage(by: wholeImage.wid) else {
            print("Failed to load image from LocalImageStore")
            return
        }

        imageView.image = image
        backgroundImageView.image = makeLowResolutionImage(from: image)
    }

    // MARK: - Keyboard Handling

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let keyboardHeight = keyboardFrame.height
        let textFieldBottom = textAnswerContainerView.frame.maxY
        let screenHeight = view.bounds.height
        let availableSpace = screenHeight - keyboardHeight

        if textFieldBottom > availableSpace {
            let offset = textFieldBottom - availableSpace + 20

            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -offset)
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }

    // MARK: - Flow

    private func startFaceFlow() {
        guard !faces.isEmpty else {
            // Faces not loaded yet — go straight to final reflection
            print("⚠️ No faces found, skipping to final reflection")
            showFinalReflection()
            return
        }
        showFace(at: 0)
    }

    private func showFace(at index: Int) {
        

        guard index < faces.count else {

            if sessionMode == .recap,
               let session = recapImageSession {

                resetZoom {
                    let reflection =
                        ImageSessionQuestionStore.shared
                            .overallReflection(for: session.isid)

                    self.transitionLabel.text = "\"\(reflection)\""
                    self.transitionLabel.alpha = 0

                    UIView.animate(withDuration: 0.5) {
                        self.transitionLabel.alpha = 1
                    }

                    self.isFaceComplete = true
                }

                return
            }

            finishFlow()
            return
        }

        currentFaceIndex = index
        currentQuestionIndex = 0
        isFaceComplete = false

        // ✅ Clear cached questions for this face so a fresh set is generated
        cachedQuestionsForFace.removeValue(forKey: index)

        textAnswerTextView.text = ""
        textAnswerTextView.resignFirstResponder()

        hideAllQuestionUI()

        let face = faces[index]

        if sessionMode == .play {
            createPersonSession(for: face)
        }

        if index == 0 {
            zoomToFace(face)
        } else {
            resetZoom { self.zoomToFace(face) }
        }
    }

    // MARK: - Zoom

    private func resetZoom(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.4) {
            self.imageView.transform = .identity
        } completion: { _ in completion?() }
    }

    private func zoomToFace(_ face: Face) {

        view.isUserInteractionEnabled = false
        let faceRect = convertFaceRectToImageView(face.boundingBox.cgRect)
        let imageFrame = imageView.displayedImageFrame

        let scaleX = imageFrame.width / faceRect.width
        let scaleY = imageFrame.height / faceRect.height
        let scale = min(max(scaleX, scaleY) * 0.85, 2.5)

        let faceCenter = CGPoint(x: faceRect.midX, y: faceRect.midY)
        let imageCenter = CGPoint(x: imageFrame.midX, y: imageFrame.midY)

        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)

        let scaledFaceCenter = CGPoint(x: faceCenter.x * scale, y: faceCenter.y * scale)
        let scaledImageCenter = CGPoint(x: imageCenter.x * scale, y: imageCenter.y * scale)

        let translateX = scaledImageCenter.x - scaledFaceCenter.x
        let translateY = scaledImageCenter.y - scaledFaceCenter.y

        let transform = scaleTransform.translatedBy(
            x: translateX / scale,
            y: translateY / scale
        )

        UIView.animate(withDuration: 0.8) {
            self.imageView.transform = transform
        } completion: { _ in
            self.view.isUserInteractionEnabled = true
            if self.sessionMode == .recap {
                self.presentNextRecapSummary()
            } else {
                self.showPersonIntroThenQuestions()
            }
        }
    }

    // MARK: - Questions Engine

    /// Single source of truth for the current face's questions.
    /// Results are cached per face index so the same Question objects
    /// (with their positiveOptions) are used both when rendering buttons
    /// and when evaluating the answer — preventing option/positiveOptions mismatch.
    private func questionsForCurrentFace() -> [Question] {
        if let cached = cachedQuestionsForFace[currentFaceIndex] {
            print("✅ Using cached questions for face \(currentFaceIndex)")
            return cached
        }

        print("🆕 Generating questions for face \(currentFaceIndex)")

        let face = faces[currentFaceIndex]
        let questions: [Question]

        if let name = face.personName,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let namedQuestions = questionsByPerson[name] {
            questions = namedQuestions
        } else {
            // ✅ Pass face so questions are deterministic per face but vary across faces
            questions = AppDataStore.shared.defaultQuestions()
        }

        cachedQuestionsForFace[currentFaceIndex] = questions
        return questions
    }

    private func presentNextQuestion() {
        let face = faces[currentFaceIndex]
        let questions = questionsForCurrentFace()

        print("Person:", face.personName ?? "unnamed")
        print("Questions found:", questions.count)

        if currentQuestionIndex >= questions.count {
            isFaceComplete = true
            return
        }

        showQuestion(questions[currentQuestionIndex])
    }

    private func showQuestion(_ question: Question) {
        questionLabel.text = question.prompt

        if question.type == .mcq {
            showMCQ(question)
        } else {
            showTextQuestion(question)
        }
    }

    // MARK: - MCQ UI

    private func showMCQ(_ question: Question) {
        textAnswerContainerView.isHidden = true
        textAnswerContainerView.isUserInteractionEnabled = false

        guard let options = question.options else { return }

        for (index, button) in optionButtons.enumerated() {
            if index < options.count {
                button.setTitle(options[index], for: .normal)
                button.isHidden = false
            } else {
                button.isHidden = true
            }
        }

        UIView.animate(withDuration: 0.3) {
            self.questionLabel.alpha = 1
            self.optionsStack.alpha = 1
            self.textAnswerContainerView.alpha = 0
        }
    }

    // MARK: - Text UI

    private func showTextQuestion(_ question: Question) {
        textAnswerContainerView.isHidden = false
        textAnswerContainerView.isUserInteractionEnabled = true

        textAnswerTextView.text = "Type your thoughts..."
        textAnswerTextView.textColor = .lightGray

        UIView.animate(withDuration: 0.3) {
            self.questionLabel.alpha = 1
            self.optionsStack.alpha = 0
            self.textAnswerContainerView.alpha = 1
        }
    }

    private func hideAllQuestionUI() {
        optionsStack.alpha = 0
        textAnswerContainerView.alpha = 0
        textAnswerContainerView.isHidden = true
        questionLabel.alpha = 0
        transitionLabel.alpha = 0
    }

    // MARK: - Button Tap

    @IBAction private func optionTapped(_ sender: UIButton) {
        guard currentFaceIndex < faces.count else { return }

        // ✅ Use cached questions — guaranteed same objects as when buttons were rendered
        let questions = questionsForCurrentFace()

        guard currentQuestionIndex < questions.count else { return }

        let question = questions[currentQuestionIndex]
        let selected = sender.title(for: .normal) ?? ""

        if question.type == .mcq {
            // ✅ positiveOptions always matches this exact question
            let isPositive = question.positiveOptions?.contains(selected) ?? false

            let answer = PersonSessionQuestion(
                psqid: UUID(),
                psid: currentPersonSession!.psid,
                qid: question.qid,
                responseText: nil,
                selectedOption: selected,
                answeredAt: Date(),
                wasPositive: isPositive
            )

            // ✅ Track this MCQ row ID so text response can be merged into it later
            lastMCQAnswerID = answer.psqid

            personSessionAnswers.append(answer)
            PersonSessionQuestionStore.shared.add(answer)
            Task {
                await SupabaseSyncManager.shared.insertPersonSessionQuestion(answer)
                print("✅ MCQ inserted: \(selected), positive: \(isPositive)")
            }

            print("\n💾 MCQ RESPONSE SAVED")
            print("   Question: \(question.prompt)")
            print("   Selected: \(selected)")
            print("   Was Positive: \(isPositive ? "✅" : "❌")")
            print("   Answer ID: \(answer.psqid)")

            hideAllQuestionUI()

            if isPositive {
                currentQuestionIndex += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.presentNextQuestion()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showPersonNameAndContinue()
                }
            }
        }
    }

    // MARK: - Display Name

    private func getPersonName(for face: Face) -> String? {
        guard let name = face.personName?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty,
              name != "Add Name"
        else { return nil }

        return name
    }

    private func showPersonNameAndContinue() {
        let face = faces[currentFaceIndex]
        if let name = getPersonName(for: face) {
            transitionLabel.text = "This is \(name)."
        } else {
            showTransitionAndMoveToNextFace()
            return
        }

        hideAllQuestionUI()

        UIView.animate(withDuration: 0.4) {
            self.transitionLabel.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                UIView.animate(withDuration: 0.3) {
                    self.transitionLabel.alpha = 0
                } completion: { _ in
                    self.showTransitionAndMoveToNextFace()
                }
            }
        }
    }

    private func showPersonIntroThenQuestions() {

        let message = AppDataStore.shared.randomPersonIntro()

        transitionLabel.text = message
        transitionLabel.alpha = 0

        UIView.animate(withDuration: 0.4) {
            self.transitionLabel.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                UIView.animate(withDuration: 0.3) {
                    self.transitionLabel.alpha = 0
                } completion: { _ in
                    self.presentNextQuestion()
                }
            }
        }
    }

    private func showTransitionAndMoveToNextFace() {
        transitionLabel.text = AppDataStore.shared.randomFallbackStatement()

        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut) {
            self.imageView.transform = .identity
            self.imageView.contentMode = .scaleAspectFit
            self.transitionLabel.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                UIView.animate(withDuration: 0.4) {
                    self.transitionLabel.alpha = 0
                } completion: { _ in
                    self.isFaceComplete = true
                    self.showFace(at: self.currentFaceIndex + 1)
                }
            }
        }
    }

    // MARK: - Final Reflection

    private func showFinalReflection() {
        isInFinalReflection = true

        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut) {
            self.imageView.transform = .identity
            self.imageView.contentMode = .scaleAspectFit
        } completion: { _ in
            self.showReflectionQuestion()
        }
    }

    private func showReflectionQuestion() {
        questionLabel.text = AppDataStore.shared.randomMomentPrompt()

        textAnswerContainerView.isHidden = false
        textAnswerContainerView.isUserInteractionEnabled = true

        textAnswerTextView.text = "Type your thoughts..."
        textAnswerTextView.textColor = .lightGray

        UIView.animate(withDuration: 0.3) {
            self.questionLabel.alpha = 1
            self.optionsStack.alpha = 0
            self.textAnswerContainerView.alpha = 1
        }
    }

    private func handleFinalReflectionComplete() {
        let reflection = (textAnswerTextView.textColor == .lightGray) ? "" : (textAnswerTextView.text ?? "")

        saveFinalReflection(text: reflection)
        showCompletionMessage()
    }

    private func showCompletionMessage() {
        hideAllQuestionUI()

        transitionLabel.text = "Thank you for sharing\nthese beautiful memories."

        UIView.animate(withDuration: 0.5) {
            self.transitionLabel.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.exitMemoryLane()
            }
        }
    }

    func navigateToHome() {
        guard let navController = navigationController else { return }

        if let homeVC = navController.viewControllers.first(where: { $0 is HomeViewController }) {
            navController.popToViewController(homeVC, animated: true)
        }
    }

    private func exitMemoryLane() {
        if sessionMode == .play {
            completeSession()
        }
        navigateToHome()
    }

    // MARK: - Navigation

    @objc private func handleTap() {

        if isInFinalReflection { return }

        guard isFaceComplete else { return }

        if sessionMode == .recap {
            handleRecapTap()
        } else {
            showFace(at: currentFaceIndex + 1)
        }
    }

    private func finishFlow() {
        showFinalReflection()
    }

    // MARK: - Helpers

    private func convertFaceRectToImageView(_ faceRect: CGRect) -> CGRect {
        guard let image = imageView.image else { return .zero }

        let imageFrame = imageView.displayedImageFrame

        let scaleX = imageFrame.width / image.size.width
        let scaleY = imageFrame.height / image.size.height

        return CGRect(
            x: imageFrame.origin.x + faceRect.origin.x * scaleX,
            y: imageFrame.origin.y + faceRect.origin.y * scaleY,
            width: faceRect.width * scaleX,
            height: faceRect.height * scaleY
        )
    }

    // MARK: - Recap

    private func personSessionsForRecap() -> [PersonSession] {
        guard let session = recapImageSession else { return [] }

        return PersonSessionStore.shared
            .personSessions(for: session.isid)
    }

    private func answersForPersonSession(_ personSession: PersonSession) -> [PersonSessionQuestion] {

        PersonSessionQuestionStore.shared
            .questions(for: personSession.psid)
            .sorted { ($0.answeredAt ?? Date()) < ($1.answeredAt ?? Date()) }
    }

    private func presentNextRecapSummary() {

        guard let _ = recapImageSession else { return }

        let personSessions = personSessionsForRecap()

        guard currentFaceIndex < personSessions.count else {
            finishRecap()
            return
        }

        let personSession = personSessions[currentFaceIndex]
        let answers = answersForPersonSession(personSession)

        guard currentQuestionIndex < answers.count else {
            isFaceComplete = true
            return
        }

        let answer = answers[currentQuestionIndex]
        let _ = AppDataStore.shared.prompt(for: answer.qid)
        let summaryText = answer.recapSummaryText

        transitionLabel.text = summaryText

        UIView.animate(withDuration: 0.4) {
            self.questionLabel.alpha = 0
            self.transitionLabel.alpha = 1
        } completion: { _ in
            self.isFaceComplete = true
        }
    }

    private func handleRecapTap() {

        if isRecapFinished { return }

        if isRecapTransitioning { return }
        isRecapTransitioning = true

        guard isFaceComplete else {
            isRecapTransitioning = false
            return
        }

        isFaceComplete = false
        currentQuestionIndex += 1

        let personSessions = personSessionsForRecap()

        if currentFaceIndex < personSessions.count {
            let answers = answersForPersonSession(personSessions[currentFaceIndex])

            if currentQuestionIndex < answers.count {
                presentNextRecapSummary()
                isRecapTransitioning = false
                return
            }
        }

        currentQuestionIndex = 0
        currentFaceIndex += 1

        if currentFaceIndex < faces.count {
            showFace(at: currentFaceIndex)
            isRecapTransitioning = false
            return
        }

        finishRecap()
    }

    private var isRecapFinished = false

    private func finishRecap() {

        if isRecapFinished { return }
        isRecapFinished = true

        view.isUserInteractionEnabled = false

        guard var session = recapImageSession else { return }

        resetZoom {

            self.transitionLabel.text = "These memories are part of your story."
            self.transitionLabel.alpha = 0

            UIView.animate(withDuration: 0.4) {
                self.transitionLabel.alpha = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {

                let reflection =
                    ImageSessionQuestionStore.shared
                        .overallReflection(for: session.isid)

                self.transitionLabel.alpha = 0
                self.transitionLabel.text = "\"\(reflection)\""

                UIView.animate(withDuration: 0.4) {
                    self.transitionLabel.alpha = 1
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {

                    session.recapCount += 1
                    ImageSessionStore.shared.updateSession(session)
                    Task {
                        await SupabaseSyncManager.shared.updateImageSessionRecapCount(
                            isid: session.isid,
                            recapCount: session.recapCount
                        )
                    }

                    self.navigateToHome()
                }
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension FaceViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type your thoughts..."
            textView.textColor = .lightGray
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            handleTextInputComplete()
            return false
        }
        return true
    }

    private func handleTextInputComplete() {
        if isInFinalReflection {
            handleFinalReflectionComplete()
            return
        }

        let questions = questionsForCurrentFace()

        if currentQuestionIndex < questions.count {
            let question = questions[currentQuestionIndex]
            let rawText = textAnswerTextView.textColor == .lightGray ? "" : (textAnswerTextView.text ?? "")
            let responseText: String? = rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : rawText

            // ✅ If there's a previous MCQ row for this face, merge text into it
            if let mcqID = lastMCQAnswerID,
               let existingIndex = personSessionAnswers.firstIndex(where: { $0.psqid == mcqID }) {

                let existing = personSessionAnswers[existingIndex]
                let merged = PersonSessionQuestion(
                    psqid: existing.psqid,
                    psid: existing.psid,
                    qid: existing.qid,
                    responseText: responseText,
                    selectedOption: existing.selectedOption,
                    answeredAt: existing.answeredAt,
                    wasPositive: existing.wasPositive
                )

                personSessionAnswers[existingIndex] = merged
                PersonSessionQuestionStore.shared.add(merged)

                Task {
                    await SupabaseSyncManager.shared.updatePersonSessionQuestion(merged)
                }

                lastMCQAnswerID = nil

            } else {
                // No MCQ to merge into — save as standalone text row
                savePersonResponse(question: question, responseText: responseText)
            }
        }

        hideAllQuestionUI()
        currentQuestionIndex += 1

        if currentQuestionIndex >= questions.count {
            showPersonNameAndContinue()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.presentNextQuestion()
            }
        }
    }
}

// MARK: - UIImageView Display Frame

extension UIImageView {

    var displayedImageFrame: CGRect {
        guard let image = image else { return .zero }

        let imageRatio = image.size.width / image.size.height
        let viewRatio = bounds.width / bounds.height

        if imageRatio > viewRatio {
            let width = bounds.width
            let height = width / imageRatio
            let y = (bounds.height - height) / 2
            return CGRect(x: 0, y: y, width: width, height: height)
        } else {
            let height = bounds.height
            let width = height * imageRatio
            let x = (bounds.width - width) / 2
            return CGRect(x: x, y: 0, width: width, height: height)
        }
    }
}
