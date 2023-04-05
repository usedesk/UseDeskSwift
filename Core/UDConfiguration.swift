//
//  UDConfiguration.swift
//  UseDesk_SDK_Swift
//
//

import Alamofire
import Foundation

let UD_TYPE_TEXT = 1
let UD_TYPE_EMOJI = 2
let UD_TYPE_PICTURE = 3
let UD_TYPE_VIDEO = 4
let UD_TYPE_File = 5
let UD_TYPE_Feedback = 6

let UD_STATUS_LOADING = 1
let UD_STATUS_SUCCEED = 2
let UD_STATUS_OPENIMAGE = 3

let UD_STATUS_SEND_FAIL = 1
let UD_STATUS_SEND_DRAFT = 2
let UD_STATUS_SEND_SUCCEED = 3

let UD_AUDIOSTATUS_STOPPED = 1
let UD_AUDIOSTATUS_PLAYING = 2

let UD_LIMIT_PAGINATION_DEFAULT = 20

public typealias UDStartBlock = (Bool, UDFeedbackStatus, String) -> Void
public typealias UDBaseBlock = (Bool, [UDBaseCollection]?) -> Void
public typealias UDArticleBlock = (Bool, UDArticle?) -> Void
public typealias UDArticleSearchBlock = (Bool, UDSearchArticle?) -> Void
public typealias UDConnectBlock = (Bool) -> Void
public typealias UDMessageBlock = (UDMessage?) -> Void
public typealias UDNewMessagesBlock = ([UDMessage]) -> Void
public typealias UDErrorBlock = (UDError, String?) -> Void
public typealias UDFeedbackMessageBlock = (UDMessage?) -> Void
public typealias UDFeedbackAnswerMessageBlock = (Bool) -> Void
public typealias UDVoidBlock = () -> Void
public typealias UDProgressUploadBlock = (Progress) -> Void
public typealias UDValidModelBlock = (UseDeskModel) -> Void

@objc public protocol UDStorage {
    func getMessages() -> [UDMessage]
    func saveMessages(_ messages: [UDMessage])
    func removeMessage(_ messages: [UDMessage])
}

public struct UseDeskModel {
    var companyID = ""
    var chanelId = ""
    var email = ""
    var phone = ""
    var url = ""
    var urlToSendFile = ""
    var urlWithoutPort = ""
    var urlAPI = ""
    var knowledgeBaseID = ""
    var knowledgeBaseSectionId: Int = 0
    var knowledgeBaseCategoryId: Int = 0
    var knowledgeBaseArticleId: Int = 0
    var isReturnToParentFromKnowledgeBase = false
    var baseSections: [UDBaseCollection] = [] {
        didSet {
            if knowledgeBaseArticleId > 0 {
                if let baseSection = baseSections.filter({$0.categories.filter({$0.articlesTitles.filter({$0.id == knowledgeBaseArticleId}).count > 0}).count > 0}).first,
                   let category = baseSection.categories.filter({$0.articlesTitles.filter({$0.id == knowledgeBaseArticleId}).count > 0}).first {
                    knowledgeBaseCategoryId = category.id
                }
            }
            if knowledgeBaseCategoryId > 0 {
                if let baseSection = baseSections.filter({$0.categories.filter({$0.id == knowledgeBaseCategoryId}).count > 0}).first {
                    knowledgeBaseSectionId = baseSection.id
                }
            } 
        }
    }
    var api_token = ""
    var port = ""
    var name = ""
    var avatar: Data? = nil
    var avatarUrl: URL? = nil
    var nameOperator = ""
    var nameChat = ""
    var firstMessage = ""
    var countMessagesOnInit = 0
    var note = ""
    var token = ""
    var additional_id = ""
    var localeIdentifier = ""
    var additionalFields: [Int : String] = [:]
    var additionalNestedFields: [[Int : String]] = []
    var isPresentDefaultControllers = true
    var idLoadingMessages: [String] = []
    var isSaveTokensInUserDefaults = true
    var isOnlyKnowledgeBase = false
    // Lolace
    var locale: [String:String] = [:]
    
    var isOpenKnowledgeBase: Bool {
        return knowledgeBaseID != ""
    }
    
    var isLoadedKnowledgeBase: Bool {
        return baseSections.count > 0
    }
    
    var selectedKnowledgeBaseSection: UDBaseCollection? {
        if knowledgeBaseSectionId > 0 {
            if let index = baseSections.firstIndex(where: {$0.id == knowledgeBaseSectionId}) {
                return baseSections[index]
            }
        } else if knowledgeBaseCategoryId > 0 {
            if let index = baseSections.firstIndex(where: {$0.categories.contains(where: {$0.id == knowledgeBaseCategoryId}) }) {
                return baseSections[index]
            }
        } else if knowledgeBaseArticleId > 0 {
            if let index = baseSections.firstIndex(where: {$0.categories.contains(where: {$0.articlesTitles.contains(where: {$0.id == knowledgeBaseArticleId}) }) }) {
                return baseSections[index]
            }
        }
        return nil
    }
    
    var selectedKnowledgeBaseCategory: UDBaseCategory? {
        if knowledgeBaseCategoryId > 0 {
            if let index = selectedKnowledgeBaseSection?.categories.firstIndex(where: {$0.id == knowledgeBaseCategoryId}) {
                return selectedKnowledgeBaseSection?.categories[index]
            }
        } else if knowledgeBaseArticleId > 0 {
            if let index = selectedKnowledgeBaseSection?.categories.firstIndex(where: {$0.articlesTitles.contains(where: {$0.id == knowledgeBaseArticleId}) }) {
                return selectedKnowledgeBaseSection?.categories[index]
            }
        }
        return nil
    }
    
    func stringFor(_ key: String) -> String {
        if let word = locale[key] {
            return word
        } else {
            return key
        }
    }
    
    func isEmpty() -> Bool {
        return companyID == ""
    }
}
