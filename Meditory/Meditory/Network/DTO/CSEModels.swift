import Foundation

struct CSEResponse: Decodable { let items: [CSEItem]? }

struct CSEItem: Decodable {
  let title: String?
  let displayLink: String?
  let link: String?
  let pagemap: Pagemap?
}

struct Pagemap: Decodable {
  let product: [CSEProduct]?
  let cseImage: [CSEImage]?
  let cseThumbnail: [CSEImage]?
  let imageObject: [ImageObject]?
  let metatags: [[String:String]]?

  enum CodingKeys: String, CodingKey {
    case product
    case cseImage = "cse_image"
    case cseThumbnail = "cse_thumbnail"
    case imageObject = "imageobject"
    case metatags
  }
}

struct ImageObject: Decodable {
  let url: String?
}

struct CSEProduct: Decodable {
  let name: String?
  let brand: BrandValue?

  struct BrandValue: Decodable {
    let value: String
    init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if let string = try? container.decode(String.self) {
        value = string; return
      }
      if let dictionary = try? container.decode([String:String].self), let name = dictionary["name"] {
        value = name; return
      }
      if let array = try? container.decode([[String:String]].self), let name = array.first?["name"] {
        value = name; return
      }
      value = ""
    }
  }
}

struct CSEImage: Decodable {
  let src: String?
}
