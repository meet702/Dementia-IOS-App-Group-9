import UIKit

class DatePickerCell: UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    var onDateChanged: ((Date) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        datePicker.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    func configure(date: Date) {
        datePicker.date = date
    }

    @objc func valueChanged(_ sender: UIDatePicker) {
        onDateChanged?(sender.date)
    }
}
