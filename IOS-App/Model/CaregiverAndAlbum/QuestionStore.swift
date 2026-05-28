import Foundation

final class QuestionStore {

    static let shared = QuestionStore()
    private init() {}

    func prompt(for id: UUID) -> String {
        AppDataStore.shared
            .mcqQuestions
            .first { $0.qid == id }?
            .prompt
        ?? AppDataStore.shared
            .textQuestions
            .first { $0.qid == id }?
            .prompt
        ?? "Reflection"
    }
}
