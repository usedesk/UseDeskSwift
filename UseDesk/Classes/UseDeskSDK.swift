//
//  File.swift
//  
//
//  Created by Leonid Liadveikin on 27.08.2021.
//

import Foundation

let RootView = UIApplication.shared.keyWindow?.rootViewController

extension UseDeskSDK {
    var loader: UDLoader? = nil
    var navController = UDNavigationController()
    private var dialogflowVC: DialogflowView = DialogflowView()
    private var offlineVC: UDOfflineForm = UDOfflineForm()

    @objc public func start(withCompanyID _companyID: String, chanelId _chanelId: String, urlAPI _urlAPI: String? = nil, knowledgeBaseID _knowledgeBaseID: String? = nil, api_token _api_token: String, email _email: String? = nil, phone _phone: String? = nil, url _url: String, urlToSendFile _urlToSendFile: String? = nil, port _port: String? = nil, name _name: String? = nil, operatorName _operatorName: String? = nil, nameChat _nameChat: String? = nil, firstMessage _firstMessage: String? = nil, note _note: String? = nil, token _token: String? = nil, localeIdentifier: String? = nil, customLocale: [String : String]? = nil, presentIn parentController: UIViewController? = nil, connectionStatus startBlock: @escaping UDSStartBlock) {

        closure = startBlock

        let parentController: UIViewController? = parentController ?? RootView

        loader = UDLoader(view: parentController?.view ?? UIView(), colorBackView: configurationStyle.chatStyle.backgroundColorLoaderView, alphaBackView: configurationStyle.chatStyle.alphaLoaderView)
        loader?.show()

        companyID = _companyID
        guard _chanelId.trimmingCharacters(in: .whitespaces).count > 0 && Int(_chanelId) != nil else {
            startBlock(false, "chanelIdError", "")
            return
        }
        chanelId = _chanelId
        api_token = _api_token

        if _port != nil {
            if _port != "" {
                port = _port!
            }
        }

        guard isValidSite(path: _url) else {
            startBlock(false, "urlError", "")
            return
        }
        urlWithoutPort = _url

        if isExistProtocol(url: _url) {
            url = "\(_url):\(port)"
        } else {
            url = "https://" + "\(_url):\(port)"
        }


        if _email != nil {
            if _email != "" {
                email = _email!
                if !email.udIsValidEmail() {
                    startBlock(false, "emailError", "")
                    loader?.hide(animated: true)
                    return
                }
            }
        }

        if _urlToSendFile != nil {
            if _urlToSendFile != "" {
                guard isValidSite(path: _urlToSendFile!) else {
                    startBlock(false, "urlToSendFileError", "")
                    return
                }
                if isExistProtocol(url: _urlToSendFile!) {
                    urlToSendFile = _urlToSendFile!
                } else {
                    urlToSendFile = "https://" + _urlToSendFile!
                }
            }
        }

        if _knowledgeBaseID != nil {
            knowledgeBaseID = _knowledgeBaseID!
        }

        if _urlAPI != nil {
            if _urlAPI != "" {
                if isExistProtocol(url: _urlAPI!) {
                    urlAPI = _urlAPI!
                } else {
                    urlAPI = "https://" + _urlAPI!
                }
                guard isValidSite(path: urlAPI) else {
                    startBlock(false, "urlAPIError", "")
                    return
                }
            }
        }

        if _name != nil {
            if _name != "" {
                name = _name!
            }
        }
        if _operatorName != nil {
            if _operatorName != "" {
                operatorName = _operatorName!
            }
        }
        if _phone != nil {
            if _phone != "" {
                phone = _phone!
                guard isValidPhone(phone: _phone!) else {
                    startBlock(false, "phoneError", "")
                    loader?.hide(animated: true)
                    return
                }
            }
        }
        if _nameChat != nil {
            if _nameChat != "" {
                nameChat = _nameChat!
            } else {
                nameChat = stringFor("OnlineChat")

            }
        } else {
            nameChat = stringFor("OnlineChat")
        }
        if _firstMessage != nil {
            if _firstMessage != "" {
                firstMessage = _firstMessage!
            }
        }
        if _note != nil {
            if _note != "" {
                note = _note!
            }
        }
        if _token != nil {
            if _token != "" {
                if !_token!.udIsValidToken() {
                    startBlock(false, "tokenError", "")
                    loader?.hide(animated: true)
                    return
                }
                token = _token!
            }
        }
//        if _additional_id != nil {
//            if _additional_id != "" {
//                additional_id = _additional_id!
//            }
//        }
        if customLocale != nil {
            locale = customLocale!
        } else if localeIdentifier != nil {
            if let getLocale = UDLocalizeManager().getLocaleFor(localeId: localeIdentifier!) {
                locale = getLocale
            } else {
                locale = UDLocalizeManager().getLocaleFor(localeId: "ru")!
            }
        } else {
            locale = UDLocalizeManager().getLocaleFor(localeId: "ru")!
        }

        isOpenSDKUI = true
        if knowledgeBaseID != "" {
            let baseView = UDBaseSectionsView()
            baseView.usedesk = self
            baseView.url = self.url
            navController = UDNavigationController(rootViewController: baseView)
            navController.configurationStyle = configurationStyle
            navController.setProperties()
            navController.setTitleTextAttributes()
            navController.modalPresentationStyle = .fullScreen
            parentController?.present(navController, animated: true)
            loader?.hide(animated: true)
        } else {
            startWithoutGUICompanyID(companyID: companyID, chanelId: chanelId, knowledgeBaseID: knowledgeBaseID, api_token: api_token, email: email, phone: _phone, url: urlWithoutPort, port: port, name: _name, operatorName: operatorName, nameChat: _nameChat, connectionStatus: { [weak self] success, error, token in
                guard let wSelf = self else {return}
                startBlock(success, error, token)
                if success {
                    wSelf.dialogflowVC.usedesk = wSelf
                    if wSelf.navController.presentingViewController == nil {
                        wSelf.navController = UDNavigationController(rootViewController: wSelf.dialogflowVC)
                        wSelf.navController.configurationStyle = wSelf.configurationStyle
                        wSelf.navController.setProperties()
                        wSelf.navController.setTitleTextAttributes()
                        wSelf.navController.modalPresentationStyle = .fullScreen
                        parentController?.present(wSelf.navController, animated: true)
                    } else {
                        wSelf.dialogflowVC.reloadHistory()
                    }
                } else {
                    if error == "feedback_form" || error == "feedback_form_and_chat" {
                        if wSelf.offlineVC.presentingViewController == nil {
                            wSelf.dialogflowVC.dismiss(animated: true)
                            wSelf.offlineVC = UDOfflineForm()
                            wSelf.offlineVC.url = wSelf.url
                            wSelf.offlineVC.usedesk = wSelf
                            wSelf.navController = UDNavigationController(rootViewController: wSelf.offlineVC)
                            wSelf.navController.configurationStyle = wSelf.configurationStyle
                            wSelf.navController.setProperties()
                            wSelf.navController.setTitleTextAttributes()
                            wSelf.navController.modalPresentationStyle = .fullScreen
                            parentController?.present(wSelf.navController, animated: true)
                        }
                        wSelf.loader?.hide(animated: true)
                    }
                }
            })
        }
    }
}
