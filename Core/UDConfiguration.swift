//
//  UDConfiguration.swift
//  UseDesk_SDK_Swift
//
//



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

public typealias UDSStartBlock = (Bool, UDFeedbackStatus, String) -> Void
public typealias UDSBaseBlock = (Bool, [UDBaseCollection]?) -> Void
public typealias UDSArticleBlock = (Bool, UDArticle?) -> Void
public typealias UDSArticleSearchBlock = (Bool, UDSearchArticle?) -> Void
public typealias UDSConnectBlock = (Bool) -> Void
public typealias UDSNewMessageBlock = (UDMessage?) -> Void
public typealias UDSErrorSocketBlock = ([Any]?) -> Void
public typealias UDSErrorBlock = (UDError, String?) -> Void
public typealias UDSFeedbackMessageBlock = (UDMessage?) -> Void
public typealias UDSFeedbackAnswerMessageBlock = (Bool) -> Void
public typealias UDSVoidBlock = () -> Void

protocol UDUISetupable {
    func setupUI()
}

@objc public protocol UDStorage {
    func getMessages() -> [UDMessage]
    func saveMessages(_ messages: [UDMessage])
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
    var api_token = ""
    var port = ""
    var name = ""
    var operatorName = ""
    var nameChat = ""
    var firstMessage = ""
    var note = ""
    var token = ""
    var additionalFields: [Int : String] = [:]
    var additionalNestedFields: [[Int : String]] = []
    var isPresentDefaultControllers = true
    var idLoadingMessages: [String] = []
    var isSaveTokensInUserDefaults = true
    // Lolace
    var locale: [String:String] = [:]
    
    var isOpenKnowledgeBase: Bool {
        return knowledgeBaseID != ""
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
