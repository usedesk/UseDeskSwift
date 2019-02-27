//
//  UDBaseCollection.swift


import Foundation
import UIKit

@objc public class BaseCategory: NSObject {
    var title: String = ""
    var id: Int = 0
    var articlesTitles: [ArticleTitle] = []
    var open: Bool = true
    
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let open = json["public"] as? Int,
            let articlesTitlesArray = json["articles"] as? Array<[String: Any]>
            else { return nil }
        self.id = id
        self.title = title
        if open == 1 {
            self.open = true
        } else {
            self.open = false
        }
        for atricleTitleObject in articlesTitlesArray {
            if let articleTitle = ArticleTitle(json: atricleTitleObject) {
                self.articlesTitles.append(articleTitle)
            }
        }
    }
}

@objc public class ArticleTitle: NSObject {
    var title: String = ""
    var id: Int = 0
    var views: Int = 0
    
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let views = json["views"] as? Int
            else { return nil }
        self.id = id
        self.title = title
        self.views = views
    }
}

@objc public class BaseCollection: NSObject {
    var title: String = ""
    var id: Int = 0
    var image: String = ""
    var сategories: [BaseCategory] = []
    var open: Bool = true
    
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let image = json["image"] as? String,
            let open = json["public"] as? Int,
            let categoriesArray = json["categories"] as? Array<[String: Any]>
            else { return nil }
        self.id = id
        self.title = title
        self.image = image
        if open == 1 {
            self.open = true
        } else {
            self.open = false
        }
        for categoryObject in categoriesArray {
            if let category = BaseCategory(json: categoryObject) {
                self.сategories.append(category)
            }
        }
    }
    
    static func getArray(from jsonArray: Any) -> [BaseCollection]? {
        
        guard let jsonArray = jsonArray as? Array<[String: Any]> else { return nil }
        var collections: [BaseCollection] = []
        
        for jsonObject in jsonArray {
            if let collection = BaseCollection(json: jsonObject) {
                collections.append(collection)
            }
        }
        return collections
    }
}


