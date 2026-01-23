import Foundation

class MemoryGame {
    private(set) var cards: [Card] = []
    private(set) var matchedPairs = 0
    private var indexOfFirstSelected: Int?

    init(pairsCount: Int, imageNamePrefix: String = "card_") {
        reset(pairsCount: pairsCount, imageNamePrefix: imageNamePrefix)
    }

    func reset(pairsCount: Int, imageNamePrefix: String = "card_") {
        var deck: [Card] = []
        for i in 1...pairsCount {
            let name = "\(imageNamePrefix)\(i)"
            deck.append(Card(pairId: i, imageName: name))
            deck.append(Card(pairId: i, imageName: name))
        }
        deck.shuffle()
        self.cards = deck
        matchedPairs = 0
        indexOfFirstSelected = nil
    }

    func chooseCard(at index: Int) -> (changed: [Int], matched: Bool) {
        guard index >= 0 && index < cards.count else { return ([], false) }
        if cards[index].isFaceUp || cards[index].isMatched { return ([], false) }

        var changed: [Int] = []
        if let first = indexOfFirstSelected {
            cards[index].isFaceUp = true
            changed.append(index)
            if cards[first].pairId == cards[index].pairId {
                cards[first].isMatched = true
                cards[index].isMatched = true
                matchedPairs += 1
                indexOfFirstSelected = nil
                changed.append(first)
                return (changed, true)
            } else {
                changed.append(first)
                indexOfFirstSelected = nil
                return (changed, false)
            }
        } else {
            cards[index].isFaceUp = true
            indexOfFirstSelected = index
            changed.append(index)
            return (changed, false)
        }
    }

    func flipBack(indices: [Int]) {
        for i in indices {
            if i >= 0 && i < cards.count && !cards[i].isMatched {
                cards[i].isFaceUp = false
            }
        }
    }

    var isWin: Bool {
        return matchedPairs == cards.count / 2
    }
}
