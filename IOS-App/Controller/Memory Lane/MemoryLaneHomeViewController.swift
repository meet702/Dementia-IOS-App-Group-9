import UIKit

class MemoryLaneHomeViewController: UIViewController {

    @IBOutlet weak var collageImageView: UIImageView!

    // MARK: - Decorative Collage Images (UI only)

    private var portraitImage: UIImage!
    private var leftImage: UIImage!
    private var rightImage: UIImage!
    
    private var centerImageView: UIImageView!
    private var leftImageView: UIImageView!
    private var rightImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollage()
        loadMemoryLaneJSON()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureCollageImages()

    }
    
    func loadMemoryLaneJSON() {
        if UserDefaults.standard.data(forKey: "memoryLaneData") != nil {
            return
        }

        if let url = Bundle.main.url(forResource: "memory_lane_data", withExtension: "json"),
           let data = try? Data(contentsOf: url) {

            saveMemoryLaneDataToUserDefaults(data)
            print("✅ Memory Lane JSON loaded")

        } else {
            print("❌ Failed to load Memory Lane JSON")
        }
    }

    // MARK: - Start Session

    @IBAction func newSessionButtonTapped(_ sender: UIButton) {

        let allImages = LocalImageStore.shared.fetchAllImages()
            .sorted { $0.createdAt > $1.createdAt }

        guard !allImages.isEmpty else {
            print("❌ No caregiver images available")
            return
        }

        let allSessions = ImageSessionStore.shared.allSessions()

        // Count how many times each image has been played
        let playCountByImage: [UUID: Int] = allImages.reduce(into: [:]) { counts, image in
            counts[image.wid] = allSessions.filter { $0.wid == image.wid }.count
        }

        // Find the minimum play count across all images
        let minPlayCount = allImages.map { playCountByImage[$0.wid, default: 0] }.min() ?? 0

        // Next image = first image that has only been played `minPlayCount` times (not yet played in this round)
        guard let nextImage = allImages.first(where: {
            (playCountByImage[$0.wid] ?? 0) == minPlayCount
        }) else { return }

        guard let uiImage = LocalImageStore.shared.fetchImage(by: nextImage.wid) else { return }

        let faces = FaceStore.shared.loadFaces(for: nextImage.wid)

        let questions = buildQuestions(for: faces)

        navigateToPictureIntro(
            wholeImage: nextImage,
            faces: faces,
            questions: questions,
            portraitImage: uiImage
        )
    }

    // MARK: - Question Builder

    private func buildQuestions(for faces: [Face]) -> [String: [Question]] {
        var questionsByPerson: [String: [Question]] = [:]
        let dataStore = AppDataStore.shared

        for face in faces {

            guard let name = face.personName?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty else { continue }

            if let mcq = dataStore.randomMCQ(),
               let textQ = dataStore.randomTextQuestion() {

                questionsByPerson[name] = [mcq, textQ]
            }
        }

        return questionsByPerson
    }

    // MARK: - Decorative Collage

    private func setupCollage() {
        
        // Remove existing image views if already created
        centerImageView?.removeFromSuperview()
        leftImageView?.removeFromSuperview()
        rightImageView?.removeFromSuperview()

        let screenWidth = view.bounds.width
        let centerX = view.center.x
        let centerY = collageImageView.center.y

        let centerWidth = screenWidth * 0.32
        let centerHeight = centerWidth

        let sideWidth = screenWidth * 0.30
        let sideHeight = sideWidth

        let horizontalOffset = screenWidth * 0.23

        // Center
        centerImageView = UIImageView(image: portraitImage)
        centerImageView.frame = CGRect(x: 0, y: 0, width: centerWidth, height: centerHeight)
        centerImageView.center = CGPoint(x: centerX, y: centerY - 5)
        centerImageView.contentMode = .scaleAspectFill
        centerImageView.clipsToBounds = true
        centerImageView.layer.cornerRadius = 5
        centerImageView.layer.borderWidth = 2
        centerImageView.layer.borderColor = UIColor.white.cgColor

        // Left
        leftImageView = UIImageView(image: leftImage)
        leftImageView.frame = CGRect(x: 0, y: 0, width: sideWidth, height: sideHeight)
        leftImageView.center = CGPoint(x: centerX - horizontalOffset, y: centerY + 10)
        leftImageView.contentMode = .scaleAspectFill
        leftImageView.clipsToBounds = true
        leftImageView.layer.cornerRadius = 5
        leftImageView.transform = CGAffineTransform(rotationAngle: -.pi / 12)

        // Right
        rightImageView = UIImageView(image: rightImage)
        rightImageView.frame = CGRect(x: 0, y: 0, width: sideWidth, height: sideHeight)
        rightImageView.center = CGPoint(x: centerX + horizontalOffset, y: centerY + 10)
        rightImageView.contentMode = .scaleAspectFill
        rightImageView.clipsToBounds = true
        rightImageView.layer.cornerRadius = 5
        rightImageView.transform = CGAffineTransform(rotationAngle: .pi / 12)

        view.addSubview(leftImageView)
        view.addSubview(rightImageView)
        view.addSubview(centerImageView)
    }
    
    
    private func configureCollageImages() {

        let placeholder = UIImage(named: "photo_placeholder")

        let allImages = LocalImageStore.shared.fetchAllImages()
            .sorted { $0.createdAt > $1.createdAt }

        guard !allImages.isEmpty else {
            portraitImage = placeholder
            leftImage     = placeholder
            rightImage    = placeholder
            setupCollage()
            return
        }

        let allSessions = ImageSessionStore.shared.allSessions()
            .sorted { $0.startedAt > $1.startedAt }

        // Count play count per image
        let playCountByImage: [UUID: Int] = allImages.reduce(into: [:]) { counts, image in
            counts[image.wid] = allSessions.filter { $0.wid == image.wid }.count
        }

        let minPlayCount = allImages.map { playCountByImage[$0.wid, default: 0] }.min() ?? 0

        // Images not yet played in the current round
        let currentRoundUnplayed = allImages.filter {
            (playCountByImage[$0.wid] ?? 0) == minPlayCount
        }

        // Center = next to play
        let centerWI = currentRoundUnplayed.first

        // Left = most recently played (by session date)
        let leftWI = allSessions.first.flatMap {
            LocalImageStore.shared.fetchImageModel(by: $0.wid)
        }

        // Right = one after center, circular within allImages
        let rightWI: WholeImage?
        if let center = centerWI,
           let centerIndex = allImages.firstIndex(where: { $0.wid == center.wid }) {
            let nextIndex = (centerIndex + 1) % allImages.count
            rightWI = nextIndex != centerIndex ? allImages[nextIndex] : nil
        } else {
            rightWI = nil
        }

        portraitImage = centerWI.flatMap { LocalImageStore.shared.fetchImage(by: $0.wid) } ?? placeholder
        leftImage     = leftWI.flatMap   { LocalImageStore.shared.fetchImage(by: $0.wid) } ?? placeholder
        rightImage    = rightWI.flatMap  { LocalImageStore.shared.fetchImage(by: $0.wid) } ?? placeholder

        setupCollage()
    }

    // MARK: - Navigation

    private func navigateToPictureIntro(
        wholeImage: WholeImage,
        faces: [Face],
        questions: [String: [Question]],
        portraitImage: UIImage
    ) {
        let storyboard = UIStoryboard(name: "MemoryLane", bundle: nil)

        guard let nextVC = storyboard.instantiateViewController(
            withIdentifier: "MemoryLaneIntroSilentViewController"
        ) as? MemoryLaneIntroSilentViewController else {
            print("❌ Could not instantiate MemoryLaneIntroSilentViewController")
            return
        }

        nextVC.wholeImage = wholeImage
        nextVC.faces = faces
        nextVC.questionsByPerson = questions
        nextVC.portraitImage = portraitImage

        navigationController?.pushViewController(nextVC, animated: true)
    }
}
