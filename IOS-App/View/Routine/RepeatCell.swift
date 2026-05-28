import UIKit

class RepeatCell: UITableViewCell {

    @IBOutlet weak var repeatSwitch: UISwitch!

    var onSwitchChanged: ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        repeatSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }

    @objc private func switchValueChanged() {
        onSwitchChanged?(repeatSwitch.isOn)
    }

}
