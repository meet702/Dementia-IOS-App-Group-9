import Foundation

struct Card: Identifiable {
    let id: UUID = UUID()
    let pairId: Int
    let imageName: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}
