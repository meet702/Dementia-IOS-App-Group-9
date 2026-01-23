
import Foundation

enum QuestionType {
    case text
    case mcq
}

struct Question {
    let relation: String
    let type: QuestionType
    let question: String
    let options: [String]?
    let placeholder: String?
    let symbol: String
}

class QuestionBank {
    static let shared = QuestionBank()

    private let textQuestions: [Question] = [

        // Family
        Question(relation: "Family", type: .text,
                 question: "What is one of your favorite memories with this family member?",
                 options: nil, placeholder: "Add response", symbol: "heart"),
        Question(relation: "Family", type: .text,
                 question: "How would you describe your relationship with them?",
                 options: nil, placeholder: "Add response", symbol: "link"),
//        Question(relation: "Family", type: .text,
//                 question: "What is something they always used to say to you?",
//                 options: nil, placeholder: "Add response", symbol: "link"),
        Question(relation: "Family", type: .text,
                 question: "What family traditions do you remember involving them?",
                 options: nil, placeholder: "Add response", symbol: "figure.2.and.child.holdinghands"),
        Question(relation: "Family", type: .text,
                 question: "What makes this person special to you?",
                 options: nil, placeholder: "Add response", symbol: "star"),

        // Friends
        Question(relation: "Friends", type: .text,
                 question: "What do you remember doing together with this friend?",
                 options: nil, placeholder: "Add response", symbol: "pencil.and.scribble"),
        Question(relation: "Friends", type: .text,
                 question: "How did you first meet them?",
                 options: nil, placeholder: "Add response", symbol: "hand.wave"),
//        Question(relation: "Friends", type: .text,
//                 question: "What qualities did you admire in this friend?",
//                 options: nil, placeholder: "Add response", symbol: "link"),
        Question(relation: "Friends", type: .text,
                 question: "What is a memorable moment you shared with them?",
                 options: nil, placeholder: "Add response", symbol: "heart"),
        Question(relation: "Friends", type: .text,
                 question: "What made your friendship unique?",
                 options: nil, placeholder: "Add response", symbol: "star"),

        // Work
        Question(relation: "Work", type: .text,
                 question: "What kind of work did you do with this colleague?",
                 options: nil, placeholder: "Add response", symbol: "briefcase"),
        Question(relation: "Work", type: .text,
                 question: "How would you describe your working relationship?",
                 options: nil, placeholder: "Add response", symbol: "link"),
        Question(relation: "Work", type: .text,
                 question: "What is something memorable you achieved together?",
                 options: nil, placeholder: "Add response", symbol: "star"),
        Question(relation: "Work", type: .text,
                 question: "What did you learn from working with them?",
                 options: nil, placeholder: "Add response", symbol: "brain.head.profile"),
        Question(relation: "Work", type: .text,
                 question: "What was your daily routine like with this coworker?",
                 options: nil, placeholder: "Add response", symbol: "list.clipboard")
    ]


    private let mcqQuestions: [Question] = [

        // Family MCQs
        Question(relation: "Family", type: .mcq,
                 question: "What role does this person play in your family?",
                 options: ["Parent","Sibling","Child","Cousin","Grandparent","Aunt/Uncle"], placeholder: nil, symbol: "person"),

        Question(relation: "Family", type: .mcq,
                 question: "How often did you meet them?",
                 options: ["Daily","Weekly","Monthly","Rarely","On holidays","Special occasions"], placeholder: nil, symbol: "link"),

        Question(relation: "Family", type: .mcq,
                 question: "What type of activities did you do together?",
                 options: ["Eating meals","Celebrations","Trips","Cooking","Watching TV","Religious events"], placeholder: nil, symbol: "pencil.and.scribble"),

        Question(relation: "Family", type: .mcq,
                 question: "How close were you to this person emotionally?",
                 options: ["Very close","Somewhat close","Not very close","Not close at all","Can't say","Varied over time"], placeholder: nil, symbol: "heart"),

        // Friends MCQs
        Question(relation: "Friends", type: .mcq,
                 question: "Where did you usually meet this friend?",
                 options: ["School","College","Neighborhood","Workplace","Club","Online"], placeholder: nil, symbol: "location"),

        Question(relation: "Friends", type: .mcq,
                 question: "What kind of activities did you enjoy together?",
                 options: ["Sports","Travel","Conversations","Games","Eating out","Hobbies"], placeholder: nil, symbol: "pencil.and.scribble"),

        Question(relation: "Friends", type: .mcq,
                 question: "How would you describe your bond?",
                 options: ["Strong","Casual","Distant","Friendly","Like family","Complicated"], placeholder: nil, symbol: "heart"),

        // Work MCQs
//        Question(relation: "Work", type: .mcq,
//                 question: "What was their role relative to yours?",
//                 options: ["Senior","Junior","Peer","Manager","Support staff","Client"], placeholder: nil, symbol: "link"),

        Question(relation: "Work", type: .mcq,
                 question: "What type of work did you collaborate on?",
                 options: ["Projects","Reports","Meetings","Training","Events","Day-to-day tasks"], placeholder: nil, symbol: "long.text.page.and.pencil"),

        Question(relation: "Work", type: .mcq,
                 question: "How often did you interact at work?",
                 options: ["Daily","Weekly","Occasionally","Rarely","Every few hours","During meetings"], placeholder: nil, symbol: "person.2")
    ]


    func getQuestions(for relation: String) -> (text: [Question], mcq: [Question]) {

        let filteredText = textQuestions.filter { $0.relation.caseInsensitiveCompare(relation) == .orderedSame }
        let selectedText = Array(filteredText.shuffled().prefix(2))

        let filteredMCQ = mcqQuestions.filter { $0.relation.caseInsensitiveCompare(relation) == .orderedSame }
        let selectedMCQ = Array(filteredMCQ.shuffled().prefix(2))

        return (selectedText, selectedMCQ)
    }
}

