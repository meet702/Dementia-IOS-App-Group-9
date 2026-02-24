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

    var wholeImage: WholeImage!
    var faces: [Face] = []
    var people: [Person] = []
    var questionsByPerson: [UUID: [Question]] = [:]
    var portraitImage: UIImage!

    // MARK: - State

    private var currentFaceIndex = 0
    private var currentQuestionIndex = 0
    private var isFaceComplete = false
    private var isInFinalReflection = false
    private var hasShownFinalReflectionInRecap = false

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
        
        print("People received in FaceVC:")
        for person in people {
            print(person.name ?? "nil")
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layoutIfNeeded()
        imageView.layoutIfNeeded()
        startFaceFlow()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Session Management
    
    private func initializeSession() {
        guard sessionMode == .play else { return }
        currentImageSession = ImageSession(
            isid: UUID(),
            imageID: wholeImage.wid,
            sessionType: .memoryLane,
            playedBy: "Patient",  // TODO: Get from user context
            startedAt: Date(),
            endedAt: nil,
            hasBeenViewedAsRecap: false
        )
        
        print("\n🟢 IMAGE SESSION STARTED")
        print("   Session ID: \(currentImageSession.isid)")
        print("   Image ID: \(currentImageSession.imageID)")
        print("   Started at: \(currentImageSession.startedAt)")
    }
    
    private func createPersonSession(for face: Face) {
        guard let personID = face.personID else { return }
        
        let personSession = PersonSession(
            psid: UUID(),
            imageSessionID: currentImageSession.isid,
            personID: personID
        )
        
        currentPersonSession = personSession
        personSessions.append(personSession)
        PersonSessionStore.shared.add(personSession)
        
        print("\n👤 PERSON SESSION STARTED")
        if let person = people.first(where: { $0.pid == personID }) {
            print("   Name: \(person.name ?? "Unknown")")
            print("   Relation: \(person.relationLabel ?? "N/A")")
        }
        print("   Person ID: \(personID)")
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
            personSessionID: personSession.psid,
            questionID: question.qid,
            responseText: responseText,
            selectedOption: selectedOption,
            answeredAt: Date(),
            wasPositive: wasPositive,
            confidenceScore: nil
        )

        
        personSessionAnswers.append(answer)
        PersonSessionQuestionStore.shared.add(answer)
        
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
        print("   Timestamp: \(answer.answeredAt)")
    }
    
    private func saveFinalReflection(text: String) {
        //let questionID = UUID()  // Or use fixed UUID for final reflection
        let questionID = AppDataStore.shared.reflectionQuestion.qid
        
        let answer = ImageSessionQuestion(
            isqid: UUID(),
            imageSessionID: currentImageSession.isid,
            questionID: questionID,
            responseText: text,
            selectedOption: nil,
            answeredAt: Date(),
            confidenceScore: nil
        )

        
        imageSessionAnswers.append(answer)
        ImageSessionQuestionStore.shared.add(answer)
        
        print("\n💭 FINAL REFLECTION SAVED")
        print("   Reflection: \"\(text)\"")
        print("   Answer ID: \(answer.isqid)")
        print("   Timestamp: \(answer.answeredAt)")
    }
    
    private func completeSession() {

        currentImageSession.endedAt = Date()

        // 🔥 Persist session
        ImageSessionStore.shared.addSession(currentImageSession)

        print("✅ ImageSession persisted")

        printSessionSummary()
    }
    
    private func printSessionSummary() {
        print("\n" + String(repeating: "=", count: 70))
        print("📊 SESSION SUMMARY")
        print(String(repeating: "=", count: 70))
        
        // Session Info
        print("\n🔷 Image Session:")
        print("   Session ID: \(currentImageSession.isid)")
        print("   Image ID: \(currentImageSession.imageID)")
        print("   Type: \(currentImageSession.sessionType.rawValue)")
        print("   Started: \(currentImageSession.startedAt)")
        if let endedAt = currentImageSession.endedAt {
            let duration = endedAt.timeIntervalSince(currentImageSession.startedAt)
            print("   Ended: \(endedAt)")
            print("   Duration: \(Int(duration)) seconds")
        }
        
        // Person Sessions
        print("\n👥 Person Sessions: \(personSessions.count)")
        for (index, session) in personSessions.enumerated() {
            if let person = people.first(where: { $0.pid == session.personID }) {
                print("\n   [\(index + 1)] \(person.name ?? "Unknown")")
                print("       Person ID: \(session.personID)")
                print("       Session ID: \(session.psid)")
                print("       Relation: \(person.relationLabel ?? "N/A")")
                
                // Get answers for this person session
                let answers = personSessionAnswers.filter { $0.personSessionID == session.psid }
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
                    print("         Time: \(answer.answeredAt)")
                }
            }
        }
        
        // Final Reflection
        print("\n💭 Final Reflection:")
        if let reflection = imageSessionAnswers.first {
            print("   Response: \"\(reflection.responseText ?? "N/A")\"")
            print("   Time: \(reflection.answeredAt)")
        } else {
            print("   Not completed")
        }
        
        // Statistics
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

    // MARK: - UI Setup

    private func configureUI() {
        imageView.contentMode = .scaleAspectFit
        zoomContainerView.clipsToBounds = true

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
        guard let image = LocalImageStore.shared.fetchImage(by: wholeImage.wid) else {
            print("Failed to load image from LocalImageStore")
            return
        }

        imageView.image = image
        backgroundImageView.image = image
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
        guard !faces.isEmpty else { return }
        showFace(at: 0)
    }

    private func showFace(at index: Int) {
        guard index < faces.count else {

            if sessionMode == .recap,
               let session = recapImageSession {

                // Reset zoom first
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

        textAnswerTextView.text = ""
        textAnswerTextView.resignFirstResponder()

        hideAllQuestionUI()

        let face = faces[index]
        
        // Create person session
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
        let faceRect = convertFaceRectToImageView(face.boundingBox)
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
            if self.sessionMode == .recap {
                self.presentNextRecapSummary()
            } else {
                self.showPersonIntroThenQuestions()
            }
        }
    }

    // MARK: - Questions Engine

    private func presentNextQuestion() {
        let face = faces[currentFaceIndex]

        guard let personID = face.personID,
              let questions = questionsByPerson[personID]
        else {
            isFaceComplete = true
            return
        }

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

    // MARK: - TEXT UI

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

        let face = faces[currentFaceIndex]

        guard let personID = face.personID,
              let questions = questionsByPerson[personID],
              currentQuestionIndex < questions.count
        else { return }

        let question = questions[currentQuestionIndex]
        let selected = sender.title(for: .normal) ?? ""

        if question.type == .mcq {
            let isPositive = question.positiveOptions?.contains(selected) ?? false
            
            // Save MCQ response
            savePersonResponse(
                question: question,
                selectedOption: selected,
                wasPositive: isPositive
            )

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
    
    private func getPersonName(for face: Face) -> String {
        guard let pid = face.personID,
              let person = people.first(where: { $0.pid == pid })
        else { return "Someone special" }

        return person.name ?? "Someone special"
    }

    private func showPersonNameAndContinue() {
        let face = faces[currentFaceIndex]
        let name = getPersonName(for: face)

        hideAllQuestionUI()
        
        transitionLabel.text = "This is \(name)."

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


    // MARK: - Transition
    
//    private func showPersonIntroThenQuestions() {
//        let personIntroMessages = [
//            "That was beautiful.\nLet's continue your journey.",
//            "A moment worth remembering.\nLet's move ahead.",
//            "Thanks for sharing this memory.\nLet's see what's next.",
//            "That was meaningful.\nLet's keep going.",
//            "A memory to hold onto.\nLet's move forward.",
//            "That was special.\nLet's continue.",
//            "Thanks for taking a moment to look back.\nLet's go ahead.",
//            "A piece of your story.\nLet's keep moving.",
//            "That was a nice moment to revisit.\nLet's continue forward.",
//            "A memory that mattered.\nLet's move to the next one."
//        ]
//
//        let message = personIntroMessages.randomElement() ?? ""
//
//        transitionLabel.text = message
//        transitionLabel.alpha = 0
//
//        UIView.animate(withDuration: 0.4) {
//            self.transitionLabel.alpha = 1
//        } completion: { _ in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
//                UIView.animate(withDuration: 0.3) {
//                    self.transitionLabel.alpha = 0
//                } completion: { _ in
//                    self.presentNextQuestion()
//                }
//            }
//        }
//    }
    
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
//        let messages = [
//            "That was wonderful!\nLet's move ahead.",
//            "Thank you for sharing!\nLet's continue.",
//            "Beautiful memories!\nLet's see what's next.",
//            "Lovely!\nMoving forward."
//        ]
//        
//        transitionLabel.text = messages.randomElement()
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
        //questionLabel.text = "What was happening in this moment?"
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
    
    private func exitMemoryLane() {

        if sessionMode == .play {
            completeSession()
        }

        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Navigation

    @objc private func handleTap() {
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

        guard let session = recapImageSession else { return }

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

        let prompt = AppDataStore.shared.prompt(for: answer.questionID)

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

        guard isFaceComplete else { return }

        isFaceComplete = false
        currentQuestionIndex += 1

        let personSessions = personSessionsForRecap()

        if currentFaceIndex < personSessions.count {
            let answers = answersForPersonSession(personSessions[currentFaceIndex])

            if currentQuestionIndex < answers.count {
                presentNextRecapSummary()
                return
            }
        }

        // Move to next face
        currentQuestionIndex = 0
        currentFaceIndex += 1

        if currentFaceIndex < faces.count {
            showFace(at: currentFaceIndex)
            return
        }

        // All faces done — show final reflection once
        currentQuestionIndex = 0
        currentFaceIndex += 1

        showFace(at: currentFaceIndex)

        // After reflection tap → finish
        finishRecap()
    }
    
    private func finishRecap() {

        guard var session = recapImageSession else { return }

        transitionLabel.text = "These memories are part of your story."

        UIView.animate(withDuration: 0.5) {
            self.transitionLabel.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {

                // Mark as viewed
                session.hasBeenViewedAsRecap = true
                ImageSessionStore.shared.updateSession(session)

                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}

// MARK: - TEXT VIEW DELEGATE

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
        
        // Save text response
        let currentFace = faces[currentFaceIndex]  // ✅ First declaration
        if let personID = currentFace.personID,
           let questions = questionsByPerson[personID],
           currentQuestionIndex < questions.count {
            
            let question = questions[currentQuestionIndex]
            let responseText = (textAnswerTextView.textColor == .lightGray) ? "" : textAnswerTextView.text
            
            savePersonResponse(
                question: question,
                responseText: responseText
            )
        }
        
        hideAllQuestionUI()
        currentQuestionIndex += 1

        if let personID = currentFace.personID,  // ✅ Use the same currentFace variable
           let questions = questionsByPerson[personID],
           currentQuestionIndex >= questions.count {

            showPersonNameAndContinue()

        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.presentNextQuestion()
            }
        }
    }

    
}

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
