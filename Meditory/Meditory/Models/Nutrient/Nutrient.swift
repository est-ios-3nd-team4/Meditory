import SwiftData

@Model
class Nutrient {
    @Attribute(.unique) var id: String
    var name: String
    var hashtags: [String]
    var desc: String
    var title: String
    var content: String
    var positiveKeywords: [String]
    var negativeKeywords: [String]

    init(id: String, name: String, hashtags: [String], description: String, title: String, content: String, positiveKeywords: [String], negativeKeywords: [String]) {
        self.id = id
        self.name = name
        self.hashtags = hashtags
        self.desc = description
        self.title = title
        self.content = content
        self.positiveKeywords = positiveKeywords
        self.negativeKeywords = negativeKeywords
    }
}
