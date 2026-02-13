import UIKit

class MemoryLaneHomeViewController: UIViewController {

    @IBOutlet weak var collageImageView: UIImageView!
    
    // MARK: - Properties
    var portraitImage: UIImage!
    var leftImage: UIImage!
    var rightImage: UIImage!

    private var detectedFaces: [Face] = []
    private var mockPeople: [Person] = []
    private var questionsByPerson: [UUID: [Question]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let center = UIImage(named: "portrait"),
              let left = UIImage(named: "photo_3"),
              let right = UIImage(named: "image 68") else {
            fatalError("One of the images is missing")
        }

        portraitImage = center
        leftImage = left
        rightImage = right
        
        setupCollage()
    }

    @IBAction func newSessionButtonTapped(_ sender: UIButton) {
        // Show loading indicator
        showLoadingIndicator()
        
        // Detect faces, then navigate
        detectFacesAndNavigate()
    }
    
    private func setupCollage() {
            
        let screenWidth = view.bounds.width
        let centerX = view.center.x
        let centerY = collageImageView.center.y
        
        // Slightly smaller sizes
        let centerWidth = screenWidth * 0.32
        let centerHeight = centerWidth
        
        let sideWidth = screenWidth * 0.30
        let sideHeight = sideWidth
        
        let horizontalOffset = screenWidth * 0.23
        
        // MARK: CENTER IMAGE
        
        let centerImageView = UIImageView(image: portraitImage)
        centerImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: centerWidth,
            height: centerHeight
        )
        centerImageView.center = CGPoint(x: centerX, y: centerY - 5)
        centerImageView.contentMode = .scaleAspectFill
        centerImageView.clipsToBounds = true
        centerImageView.layer.cornerRadius = 5
        centerImageView.layer.borderWidth = 2
        centerImageView.layer.borderColor = UIColor.white.cgColor
        
        // MARK: LEFT IMAGE
        
        let leftImageView = UIImageView(image: leftImage)
        leftImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: sideWidth,
            height: sideHeight
        )
        leftImageView.center = CGPoint(
            x: centerX - horizontalOffset,
            y: centerY + 10
        )
        leftImageView.contentMode = .scaleAspectFill
        leftImageView.clipsToBounds = true
        leftImageView.layer.cornerRadius = 5
        leftImageView.transform = CGAffineTransform(rotationAngle: -.pi / 12)
        
        // MARK: RIGHT IMAGE
        
        let rightImageView = UIImageView(image: rightImage)
        rightImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: sideWidth,
            height: sideHeight
        )
        rightImageView.center = CGPoint(
            x: centerX + horizontalOffset,
            y: centerY + 10
        )
        rightImageView.contentMode = .scaleAspectFill
        rightImageView.clipsToBounds = true
        rightImageView.layer.cornerRadius = 5
        rightImageView.transform = CGAffineTransform(rotationAngle: .pi / 12)
        
        // Add in correct order (back → front)
        view.addSubview(leftImageView)
        view.addSubview(rightImageView)
        view.addSubview(centerImageView)
    }




    // MARK: - Face Detection
    
    private func detectFacesAndNavigate() {

        // 1️⃣ Ensure portraitImage exists
        guard let portraitImage = portraitImage else {
            fatalError("❌ portraitImage not set")
        }

        // 2️⃣ Create WholeImage FIRST
        let wholeImage = createWholeImage()

        print("🔍 Starting face detection...")

        // 3️⃣ Call Vision detection WITH completion
        FaceDetectionServiceMemoryLane.detectFaces(
            in: portraitImage,
            imageID: wholeImage.wid
        ) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.hideLoadingIndicator()

                switch result {

                case .success(let faces):
                    print("✅ Face detection successful!")
                    print("   Detected \(faces.count) faces")

                    self.detectedFaces = faces
                    self.createMockPeopleAndQuestions(for: faces)

                    self.navigateToPictureIntro(
                        wholeImage: wholeImage,
                        faces: self.detectedFaces,
                        people: self.mockPeople,
                        questions: self.questionsByPerson,
                        portraitImage: portraitImage   // 🔥 SAME IMAGE
                    )

                case .failure(let error):
                    print("❌ Face detection failed:", error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Mock Data Creation
    private func createWholeImage() -> WholeImage {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageURL = documentsPath.appendingPathComponent("portrait.jpg")
        
        // Save portrait image to disk for testing
        if let portraitImage = UIImage(named: "portrait"),
           let imageData = portraitImage.jpegData(compressionQuality: 0.8) {
            try? imageData.write(to: imageURL)
        }
        
        if let audioURL = Bundle.main.url(
            forResource: "memory_lane_audio",
            withExtension: "mp3"
        ) {
            return WholeImage(
                wid: UUID(),
                imageURL: imageURL,
                action: .text("We met at Priyamani's house for lunch since it was her birthday party!"),
                createdAt: Date()
            )
        }

        // Fallback if audio not found
        return WholeImage(
            wid: UUID(),
            imageURL: imageURL,
            action: .text("sdfgyuiuyfdsdfghyuioiuytfdfgtyuioiuytfdfgh"),
            createdAt: Date()
        )
    }
    
    private func createMockPeopleAndQuestions(for faces: [Face]) {

        mockPeople = []
        questionsByPerson = [:]
        
        var updatedFaces = faces
        let dataStore = AppDataStore.shared

        // ✅ Sample Names
        let sampleNames = ["Priyadarshan", "Priyamani", "Priya"]

        for (index, face) in faces.enumerated() {

            let personName = index < sampleNames.count
                ? sampleNames[index]
                : "Someone Special"


            let person = Person(
                pid: UUID(),
                name: personName,
                relationLabel: nil
            )


            mockPeople.append(person)

            updatedFaces[index] = Face(
                fid: face.fid,
                faceImageURL: face.faceImageURL,
                boundingBox: face.boundingBox,
                orderIndex: face.orderIndex,
                imageID: face.imageID,
                personID: person.pid
            )

            if let mcq = dataStore.randomMCQ(),
               let textQ = dataStore.randomTextQuestion() {

                questionsByPerson[person.pid] = [mcq, textQ]
                print("✅ \(personName): Assigned MCQ + Text question")

            } else {
                print("❌ Failed to get questions for \(personName)")
            }
        }

        detectedFaces = updatedFaces

        print("\n👥 People Created:")
        for person in mockPeople {
            print("   👤 \(person.name ?? "Unknown") - \(person.pid)")

        }

        print("\n📋 Questions Summary:")
        for (personID, questions) in questionsByPerson {
            print("   Person \(personID):")
            for (idx, q) in questions.enumerated() {
                print("      [\(idx)] \(q.type) - \(q.prompt)")
            }
        }
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

        // Pass all data
        nextVC.wholeImage = wholeImage
        nextVC.faces = faces
        nextVC.people = people
        nextVC.questionsByPerson = questions
        nextVC.portraitImage = portraitImage
        print("✅ Passing to SilentVC:")
        print("   WholeImage: \(wholeImage.wid)")
        print("   Faces: \(faces.count)")
        print("   People: \(people.count)")

        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    // MARK: - Loading Indicator
    
    private var loadingIndicator: UIActivityIndicatorView?
    
    private func showLoadingIndicator() {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = view.center
        indicator.startAnimating()
        view.addSubview(indicator)
        loadingIndicator = indicator
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoadingIndicator() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
        loadingIndicator = nil
        view.isUserInteractionEnabled = true
    }
}
