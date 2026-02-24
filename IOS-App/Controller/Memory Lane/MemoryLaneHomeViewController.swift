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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureCollageImages()

    }

    // MARK: - Start Session

    @IBAction func newSessionButtonTapped(_ sender: UIButton) {

        let images = LocalImageStore.shared.fetchAllImages()
            .sorted { $0.createdAt > $1.createdAt }

        guard let wholeImage = images.first else {
            print("❌ No caregiver images available")
            return
        }

        guard let uiImage = LocalImageStore.shared.fetchImage(by: wholeImage.wid) else {
            print("❌ Could not load image from LocalImageStore")
            return
        }

        let faces = FaceStore.shared.loadFaces(for: wholeImage.wid)

        // ⚠️ Optional: If no faces, still allow reflection flow
        if faces.isEmpty {
            print("⚠️ No faces saved for this image")
        }

        // Resolve people from faces
        let people: [Person] = faces.compactMap { face in
            guard let pid = face.personID else { return nil }
            return PersonStore.shared.person(by: pid)
        }

        let questions = buildQuestions(for: people)

        navigateToPictureIntro(
            wholeImage: wholeImage,
            faces: faces,
            people: people,
            questions: questions,
            portraitImage: uiImage
        )
    }

    // MARK: - Question Builder

    private func buildQuestions(for people: [Person]) -> [UUID: [Question]] {

        var questionsByPerson: [UUID: [Question]] = [:]
        let dataStore = AppDataStore.shared

        for person in people {
            if let mcq = dataStore.randomMCQ(),
               let textQ = dataStore.randomTextQuestion() {

                questionsByPerson[person.pid] = [mcq, textQ]
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
    
    private func latestThreeMemoryImages() -> [UIImage] {

        let images = LocalImageStore.shared.fetchAllImages()
            .sorted { $0.createdAt > $1.createdAt }
        
        return images.prefix(3).compactMap {
            LocalImageStore.shared.fetchImage(by: $0.wid)
        }
    }
    
    private func configureCollageImages() {

        let memoryImages = latestThreeMemoryImages()

        // Safe fallback images
        let placeholder = UIImage(named: "photo_placeholder")

        portraitImage = memoryImages.count > 0 ? memoryImages[0] : placeholder
        leftImage     = memoryImages.count > 1 ? memoryImages[1] : placeholder
        rightImage    = memoryImages.count > 2 ? memoryImages[2] : placeholder

        setupCollage()
    }

    // MARK: - Navigation

    private func navigateToPictureIntro(
        wholeImage: WholeImage,
        faces: [Face],
        people: [Person],
        questions: [UUID: [Question]],
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
        nextVC.people = people
        nextVC.questionsByPerson = questions
        nextVC.portraitImage = portraitImage

        navigationController?.pushViewController(nextVC, animated: true)
    }
}
