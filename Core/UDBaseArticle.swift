//
//  UDBaseArticle.swift

import Foundation

@objc public enum TypeArticle: Int {
    case all = 0
    case open = 1
    case close = 2
}

@objc public enum SortArticle: Int {
    case id
    case title
    case category_id
    case created_at
    case open
}

@objc public enum OrderArticle: Int {
    case asc
    case desc 
}

@objc public class UDArticle: NSObject {
    var title: String = ""
    var id: Int = 0
    var text: String = ""
    var open: Bool = true
    var category_id: Int = 0
    var collection_id: Int = 0
    var category_title: String = ""
    var section_title: String = ""
    var views: Int = 0
    var created_at: String = ""
    
    init?(json: [String: Any]) {
        
        guard
            let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let text = json["text"] as? String,
            let open = json["public"] as? Int,
            let category_id = json["category_id"] as? Int,
            let collection_id = json["collection_id"] as? Int,
            let category_title = json["category_title"] as? String,
            let section_title = json["collection_title"] as? String,
            let views = json["views"] as? Int,
            let created_at = json["created_at"] as? String
            else { return nil }
        
        self.id = id
        self.title = title
        self.text = text
        self.category_id = category_id
        self.collection_id = collection_id
        self.category_title = category_title
        self.section_title = section_title
        self.views = views
        self.created_at = created_at
        if open == 1 {
            self.open = true
        } else {
            self.open = false
        }
    }
    
    static func get(from jsonObject: Any) -> UDArticle? {
        guard let jsonObject = jsonObject as? [String: Any] else { return nil }
        if let article = UDArticle(json: jsonObject) {
            return article
        } else { return nil }
    }
}

@objc public class UDSearchArticle: NSObject {
    var page: Int = 0
    var last_page: Int = 0
    var count: Int = 0
    var total_count: Int = 0
    var articles: [UDArticle] = []
    
    init?(from: Any) {
        guard let json = from as? [String: Any] else { return nil }
        guard
            let page = json["page"] as? Int,
            let last_page = json["last-page"] as? Int,
            let count = json["count"] as? Int,
            let total_count = json["total-count"] as? Int,
            let articlesArray = json["articles"] as? Array<[String: Any]>
            else { return nil }
        self.page = page
        self.last_page = last_page
        self.count = count
        self.total_count = total_count

        for atricleObject in articlesArray {
            if let article = UDArticle(json: atricleObject) {
                self.articles.append(article)
            }
        }
    }
}
