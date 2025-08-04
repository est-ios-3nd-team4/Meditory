import SwiftData

@Model
class Nutrient {
    @Attribute(.unique) var id: String
    var name: String
    var hashtag: String
    var desc: String
    var title: String
    var content: String
    var positiveKeywords: [String]
    var negativeKeywords: [String]

    init(id: String, name: String, hashtag: String, description: String, title: String, content: String, positiveKeywords: [String], negativeKeywords: [String]) {
        self.id = id
        self.name = name
        self.hashtag = hashtag
        self.desc = description
        self.title = title
        self.content = content
        self.positiveKeywords = positiveKeywords
        self.negativeKeywords = negativeKeywords
    }
}
