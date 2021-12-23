//
//  UDBaseCollection.swift


import Foundation
import UIKit

@objc public class UDBaseCategory: NSObject {
    public var title: String = ""
    public var descriptionCategory: String = ""
    public var id: Int = 0
    public var articlesTitles: [UDArticleTitle] = []
    public var open: Bool = true
    
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let descriptionCategory = json["description"] as? String,
            let open = json["public"] as? Int,
            let articlesTitlesArray = json["articles"] as? Array<[String: Any]>
            else { return nil }
        self.id = id
        self.title = title
        self.descriptionCategory = descriptionCategory
        if open == 1 {
            self.open = true
        } else {
            self.open = false
        }
        for atricleTitleObject in articlesTitlesArray {
            if let articleTitle = UDArticleTitle(json: atricleTitleObject) {
                self.articlesTitles.append(articleTitle)
            }
        }
    }
}

@objc public class UDArticleTitle: NSObject {
    public var title: String = ""
    public var id: Int = 0
    public var views: Int = 0
    
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

@objc public class UDBaseCollection: NSObject {
    public var title: String = ""
    public var id: Int = 0
    public var imageUrl: String = ""
    public var image: UIImage? = nil
    public var сategories: [UDBaseCategory] = []
    public var open: Bool = true
    
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let open = json["public"] as? Int,
            let categoriesArray = json["categories"] as? Array<[String: Any]>
            else { return nil }
        self.id = id
        self.title = title
        if (json["image"] as? String) != nil {
            self.imageUrl = json["image"] as! String
        }
        if open == 1 {
            self.open = true
        } else {
            self.open = false
        }
        for categoryObject in categoriesArray {
            if let category = UDBaseCategory(json: categoryObject) {
                self.сategories.append(category)
            }
        }
    }
    
    static func getArray(from jsonArray: Any) -> [UDBaseCollection]? {
        
        guard let jsonArray = jsonArray as? Array<[String: Any]> else { return nil }
        var collections: [UDBaseCollection] = []
        
        for jsonObject in jsonArray {
            if let collection = UDBaseCollection(json: jsonObject) {
                collections.append(collection)
            }
        }
        return collections
    }
}


