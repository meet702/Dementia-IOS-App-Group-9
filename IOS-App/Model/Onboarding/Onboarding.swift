import Foundation

struct RoleModel {
    let title: String
    let subtitle: String
}
struct InputField {
    let title: String
    let placeholder: String
    let type: InputType
}

enum InputType {
    case text
    case phone
    case picker
}
