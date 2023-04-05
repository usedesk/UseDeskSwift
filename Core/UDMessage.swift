//
//  UDMessage.swift

import Foundation
import Photos

public class UDMessage: NSObject, Codable {
    // MARK: - Properties
    @objc public var type: Int = 0
    @objc public var typeSenderMessageString = ""
    @objc public var incoming = false
    @objc public var feedbackActionInt: Int = -1
    @objc public var text = ""
    @objc public var buttons = [UDMessageButton]()
    @objc public var date = Date()
    @objc public var status: Int = 0
    @objc public var statusSend: Int = 0
    @objc public var idStatusForm: Int = 1
    @objc public var id: Int = 0
    @objc public var loadingMessageId = ""
    @objc public var ticket_id: Int = 0
    @objc public var name = ""
    @objc public var operatorId: Int = 0
    @objc public var operatorName = ""
    @objc public var avatar = ""
    @objc public var avatarImage: UIImage? = nil
    @objc public var file = UDFile()
    @objc public var forms = [UDFormMessage]()
    
    var outgoing: Bool {
        return !incoming
    }
    
    var feedbackAction: Bool? {
        switch feedbackActionInt {
        case 0:
            return false
        case 1:
            return true
        default:
            return nil
        }
    }
    
    var typeSenderMessage: TypeSenderMessage {
        switch typeSenderMessageString {
        case "operator_to_client":
            return .operator_to_client
        case "client_to_operator":
            return .client_to_operator
        case "client_to_bot":
            return .client_to_bot
        case "bot_to_client":
            return .bot_to_client
        default:
            return .service
        }
    }
    
    var statusForms: StatusForm {
        get {
            return StatusForm(rawValue: idStatusForm) ?? .inputable
        }
        set {
            idStatusForm = newValue.rawValue
        }
    }
    
    // MARK: - Initialization methods
    init(text: String = "", incoming: Bool = false) {
        super.init()
        type = UD_TYPE_TEXT
        statusSend = UD_STATUS_SEND_DRAFT
        self.incoming = incoming
        self.text = text
    }
    
    init(urlMovie: URL, sort: Int = 0, isCacheFile: Bool = true) {
        super.init()
        statusSend = UD_STATUS_SEND_DRAFT
        autoreleasepool {
            if let videoData = try? Data(contentsOf: urlMovie) {
                let content = "data:video/mp4;base64,\(videoData)"
                var fileName = String(format: "%ld", content.hash)
                fileName += ".mp4"
                type = UD_TYPE_VIDEO
                incoming = false
                typeSenderMessageString = "client_to_operator"
                file.path = FileManager.default.udWriteDataToCacheDirectory(data: videoData, fileExtension: "mp4") ?? ""
                let previewImage = UDFileManager.videoPreview(fileURL: urlMovie)
                if let previewData = previewImage.udToData() {
                    file.previewPath = FileManager.default.udWriteDataToCacheDirectory(data: previewData, fileExtension: "mp4") ?? ""
                }
                let asset = AVURLAsset(url: urlMovie)
                file.duration = Double(CMTimeGetSeconds(asset.duration))
                file.name = fileName
                file.sort = sort
                file.sourceTypeString = UDTypeSourceFile.PHAsset.rawValue
                status = UD_STATUS_SUCCEED
            }
        }
    }
    
    init(image: UIImage, sort: Int = 0, isCacheFile: Bool = true) {
        super.init()
        statusSend = UD_STATUS_SEND_DRAFT
        autoreleasepool {
            if let imageData = image.udToData() {
                let content = "data:image/png;base64,\(imageData)"
                var fileName = String(format: "%ld", content.hash)
                fileName += ".png"
                type = UD_TYPE_PICTURE
                incoming = false
                typeSenderMessageString = "client_to_operator"
                file.path = FileManager.default.udWriteDataToCacheDirectory(data: imageData, fileExtension: "png") ?? ""
                file.name = fileName
                file.sort = sort
                file.sourceTypeString = UDTypeSourceFile.UIImage.rawValue
                status = UD_STATUS_SUCCEED
            }
        }
    }
    
    init(urlFile: URL, sort: Int = 0, isCacheFile: Bool = true) {
        super.init()
        statusSend = UD_STATUS_SEND_DRAFT
        let fileName = urlFile.lastPathComponent
        let dataFile = try? Data(contentsOf: urlFile)
        if dataFile != nil {
            type = UD_TYPE_File
            incoming = false
            typeSenderMessageString = "client_to_operator"
            file.name = fileName
            file.sizeInt = dataFile!.count
            file.defaultPath = urlFile.path
            if isCacheFile {
                file.path = FileManager.default.udWriteDataToCacheDirectory(data: dataFile!, fileExtension: urlFile.pathExtension) ?? ""
            }
            file.sort = sort
            file.sourceTypeString = UDTypeSourceFile.URL.rawValue
            status = UD_STATUS_SUCCEED
        }
    }
    
    
    
    // MARK: - Methods
    public func copyMessage() -> UDMessage {
        let message = UDMessage()
        message.type = type
        message.typeSenderMessageString = typeSenderMessageString
        message.incoming = incoming
        message.feedbackActionInt = feedbackActionInt
        message.text = text
        message.buttons = buttons
        message.date = date
        message.status = status
        message.statusSend = statusSend
        message.idStatusForm = idStatusForm
        message.id = id
        message.loadingMessageId = loadingMessageId
        message.ticket_id = ticket_id
        message.name = name
        message.operatorId = operatorId
        message.operatorName = operatorName
        message.avatar = avatar
        message.avatarImage = avatarImage
        message.file = file
        message.forms = forms
        return message
    }
    
    func setAsset(asset: PHAsset, isCacheFile: Bool = true, successBlock: @escaping () -> Void) {
        statusSend = UD_STATUS_SEND_DRAFT
        if asset.mediaType == .video {
            DispatchQueue.global(qos: .background).async {
                let options = PHVideoRequestOptions()
                options.version = .current
                options.isNetworkAccessAllowed = true
                PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: options){ [weak self] avasset, _, _ in
                    guard let wSelf = self else {return}
                    if let avassetURL = avasset as? AVURLAsset {
                        if let videoData = try? Data(contentsOf: avassetURL.url) {
                            let content = "data:video/mp4;base64,\(videoData.base64EncodedString())"
                            var fileName = String(format: "%ld", content.hash)
                            fileName += ".mp4"
                            wSelf.type = UD_TYPE_VIDEO
                            wSelf.incoming = false
                            wSelf.typeSenderMessageString = "client_to_operator"
                            wSelf.file.defaultPath = avassetURL.url.path
                            if isCacheFile {
                                wSelf.file.path = FileManager.default.udWriteDataToCacheDirectory(data: videoData, fileExtension: "mp4") ?? ""
                            }
                            let previewImage = UDFileManager.videoPreview(fileURL: avassetURL.url)
                            if let previewData = previewImage.udToData() {
                                wSelf.file.previewPath = FileManager.default.udWriteDataToCacheDirectory(data: previewData, fileExtension: "mp4") ?? ""
                            }
                            wSelf.file.duration = asset.duration
                            wSelf.file.name = fileName
                            wSelf.file.sourceTypeString = UDTypeSourceFile.PHAsset.rawValue
                            wSelf.status = UD_STATUS_SUCCEED
                            successBlock()
                        }
                    }
                }
            }
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.isNetworkAccessAllowed = true
                PHCachingImageManager.default().requestImageData(for: asset, options: options, resultHandler: { [weak self] data, dataUTI, _, info in
                    guard let wSelf = self else {return}
                    if data != nil {
                        let content = "data:image/png;base64,\(data!)"
                        var fileName = String(format: "%ld", content.hash)
                        fileName += ".png"
                        wSelf.type = UD_TYPE_PICTURE
                        wSelf.incoming = false
                        wSelf.typeSenderMessageString = "client_to_operator"
                        if let image = UIImage(data: data!) {
                            autoreleasepool {
                                if let imageData = image.udResizeImage()?.udToData() {
                                    wSelf.file.path = FileManager.default.udWriteDataToCacheDirectory(data: imageData, fileExtension: "png") ?? ""
                                }
                            }
                        } else {
                            wSelf.file.path = FileManager.default.udWriteDataToCacheDirectory(data: data!, fileExtension: "png") ?? ""
                        }
                        wSelf.file.name = fileName
                        wSelf.file.sourceTypeString = UDTypeSourceFile.PHAsset.rawValue
                        wSelf.status = UD_STATUS_SUCCEED
                        successBlock()
                    }
                })
            }
        }
    }
    
    // MARK: - Codable methods
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(typeSenderMessageString, forKey: .typeSenderMessageString)
        try container.encode(incoming, forKey: .incoming)
        try container.encode(feedbackActionInt, forKey: .feedbackActionInt)
        try container.encode(text, forKey: .text)
        try container.encode(buttons, forKey: .buttons)
        try container.encode(date, forKey: .date)
        try container.encode(status, forKey: .status)
        try container.encode(statusSend, forKey: .statusSend)
        try container.encode(idStatusForm, forKey: .statusForm)
        try container.encode(id, forKey: .id)
        try container.encode(loadingMessageId, forKey: .loadingMessageId)
        try container.encode(ticket_id, forKey: .ticket_id)
        try container.encode(name, forKey: .name)
        try container.encode(operatorId, forKey: .operatorId)
        try container.encode(operatorName, forKey: .operatorName)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(file, forKey: .file)
        try container.encode(forms, forKey: .forms)
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(Int.self, forKey: .type)
        typeSenderMessageString = try container.decode(String.self, forKey: .typeSenderMessageString)
        incoming = try container.decode(Bool.self, forKey: .incoming)
        feedbackActionInt = try container.decode(Int.self, forKey: .feedbackActionInt)
        text = try container.decode(String.self, forKey: .text)
        buttons = try container.decode([UDMessageButton].self, forKey: .buttons)
        date = try container.decode(Date.self, forKey: .date)
        status = try container.decode(Int.self, forKey: .status)
        statusSend = try container.decode(Int.self, forKey: .statusSend)
        idStatusForm = try container.decode(Int.self, forKey: .statusForm)
        id = try container.decode(Int.self, forKey: .id)
        loadingMessageId = try container.decode(String.self, forKey: .loadingMessageId)
        ticket_id = try container.decode(Int.self, forKey: .ticket_id)
        name = try container.decode(String.self, forKey: .name)
        operatorId = try container.decode(Int.self, forKey: .operatorId)
        operatorName = try container.decode(String.self, forKey: .operatorName)
        avatar = try container.decode(String.self, forKey: .avatar)
        file = try container.decode(UDFile.self, forKey: .file)
        forms = try container.decode([UDFormMessage].self, forKey: .forms)
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case typeSenderMessageString
        case incoming
        case feedbackActionInt
        case text
        case buttons
        case date
        case status
        case statusSend
        case statusForm
        case id
        case loadingMessageId
        case ticket_id
        case name
        case operatorId
        case operatorName
        case avatar
        case file
        case forms
    }
}
