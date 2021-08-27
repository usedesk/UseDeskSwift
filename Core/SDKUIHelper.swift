//
//  File.swift
//  
//
//  Created by Leonid Liadveikin on 27.08.2021.
//

import Foundation

public protocol SDKUIHelper {
    func resetUI()
    func start(withCompanyID _companyID: String, chanelId _chanelId: String, urlAPI _urlAPI: String?, knowledgeBaseID _knowledgeBaseID: String?, api_token _api_token: String, email _email: String?, phone _phone: String?, url _url: String, urlToSendFile _urlToSendFile: String?, port _port: String?, name _name: String?, operatorName _operatorName: String?, nameChat _nameChat: String?, firstMessage _firstMessage: String?, note _note: String?, token _token: String?, localeIdentifier: String?, customLocale: [String : String]?, presentIn parentController: UIViewController?, connectionStatus startBlock: @escaping UDSStartBlock)
}
