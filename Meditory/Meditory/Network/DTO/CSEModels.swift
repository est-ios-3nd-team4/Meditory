import Foundation

struct CSEResponse: Decodable { let items: [CSEItem]? }

struct CSEItem: Decodable { let title: String; let displayLink: String?; let pagemap: Pagemap? }

struct Pagemap: Decodable {
  let product: [CSEProduct]?; let cseImage: [CSEImage]?; let metatags: [[String:String]]?
  enum CodingKeys: String, CodingKey { case product; case cseImage = "cse_image"; case metatags }
}

struct CSEProduct: Decodable {
  let name: String?; let brand: BrandValue?
  struct BrandValue: Decodable {
    let value: String
    init(from decoder: Decoder) throws {
      let c = try decoder.singleValueContainer()
      if let s = try? c.decode(String.self) { value = s; return }
      if let d = try? c.decode([String:String].self), let n = d["name"] { value = n; return }
      if let a = try? c.decode([[String:String]].self), let n = a.first?["name"] { value = n; return }
      value = ""
    }
  }
}

struct CSEImage: Decodable { let src: String? }
