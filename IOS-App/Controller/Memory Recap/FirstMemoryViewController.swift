import UIKit

class FirstMemoryViewController: UIViewController {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var summaryLabel: UILabel!
    
    let memoryRecapObj: [MemoryRecapModel] = [
        MemoryRecapModel(title: "You revisited this moment!", summary: "You remembered being with Priyamani at Shalimar Bagh", imageName: "priyamani"),
        MemoryRecapModel(title: "You also looked back at ...", summary: "That lovely day at The Rajabai Clock Tower brought a smile 😊", imageName: "photo2"),
        MemoryRecapModel(title: "Each memory you revisited keeps your story alive", summary: "You’ve done beautifully this week. Let’s make next week just as bright.", imageName: "collectionphoto1")
    ]

    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        showCurrentMemory()
    }

    func showCurrentMemory() {
        let memoryRecapObj2 = memoryRecapObj[currentIndex]
        setupView(memoryRecap: memoryRecapObj2)
    }

    func setupView(memoryRecap: MemoryRecapModel) {
        topLabel.text = memoryRecap.title
        imageView.image = UIImage(named: memoryRecap.imageName)
        summaryLabel.text = memoryRecap.summary
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if currentIndex < memoryRecapObj.count - 1 {
            currentIndex += 1
            showCurrentMemory()
        } else {
            performSegue(withIdentifier: "goToFinalScreen", sender: self)
        }
    }
}
