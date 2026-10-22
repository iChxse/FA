import Foundation

struct Quote: Codable, Identifiable, Hashable {
    let id: String
    let text: String
    let author: String
}

struct Word: Codable, Identifiable, Hashable {
    let id: String
    let word: String
    let partOfSpeech: String
    let definition: String
    let example: String
}

enum ContentKind: String, Codable {
    case quote
    case word
}
