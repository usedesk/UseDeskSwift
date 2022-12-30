//
//  UDField.swift
//  UseDesk_SDK_Swift


import Foundation

public enum UDFormMessageAdditionalFieldType: Int {
    case text = 1
    case list = 2
    case checkbox = 3
}

public class UDField: NSObject, Codable {
    
    @objc public var id: Int = 0
    @objc public var idTypeField: Int = 0 // 1 - text, 2 - list, 3 - checkbox
    @objc public var idParentField: Int = 0
    @objc public var name = ""
    @objc public var value = ""
    @objc public var options = [FieldOption]()
    @objc public var selectedOption: FieldOption? = nil
    
    override init() {
        super.init()
    }
    
    public var type: UDFormMessageAdditionalFieldType {
        switch idTypeField {
        case 1:
            return .text
        case 2, 4:
            return .list
        case 3:
            return .checkbox
        default:
            return .text
        }
    }
    
    public class func parse(from json: Any, ids: [Int]) -> [UDField] {
        guard let responseJson = json as? [String:Any] else {
            return []
        }
        guard let fieldsJson = responseJson["fields"] as? [String:Any] else {
            return []
        }
        var fields: [UDField] = []
        for id in ids {
            if let fieldJson = fieldsJson["\(id)"] as? [String:Any] {
                if fieldJson["list"] != nil {
                    guard let list = fieldJson["list"] as? [String:Any] else {
                        break
                    }
                    var fieldsList: [UDField] = []
                    for fieldList in list {
                        if let fieldJsonItem = fieldList.value as? [String:Any] {
                            let field = parseField(json: fieldJsonItem)
                            fieldsList.append(field)
                        }
                    }
                    fieldsList = fieldsList.sorted{$0.id < $1.id}
                    fields += fieldsList
                } else {
                    fields.append(parseField(json: fieldJson))
                }
            }
        }
        return fields
    }
    
    private class func parseField(json: [String:Any]) -> UDField {
        let field = UDField()
        field.idTypeField = json["ticket_field_type_id"] as? Int ?? 0
        field.id = json["id"] as! Int
        field.name = json["name"] as! String
        if let value = json["value"] as? String {
            field.value = value
        }
        if let parent_field_id = json["parent_field_id"] as? Int {
            field.idParentField = parent_field_id
        }
        let fieldOptionsJson = json["children"] as? [Any] ?? []
        if fieldOptionsJson.count > 0 {
            for fieldOptionJsonItem in fieldOptionsJson {
                let fieldOptionJson = fieldOptionJsonItem as! [String:Any]
                let fieldOption = FieldOption()
                fieldOption.id = fieldOptionJson["id"] as! Int
                fieldOption.value = fieldOptionJson["value"] as! String
                if let parent_option_ids = fieldOptionJson["parent_option_id"] as? [Int] {
                    for parent_option_id in parent_option_ids {
                        fieldOption.idsParentOption.append(parent_option_id)
                    }
                }
                field.options.append(fieldOption)
            }

        }
        return field
    }
    
    // MARK: - Codable methods
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(idTypeField, forKey: .idTypeField)
        try container.encode(idParentField, forKey: .idParentField)
        try container.encode(name, forKey: .name)
        try container.encode(value, forKey: .value)
        try container.encode(options, forKey: .options)
        try container.encode(selectedOption, forKey: .selectedOption)
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        idTypeField = try container.decode(Int.self, forKey: .idTypeField)
        idParentField = try container.decode(Int.self, forKey: .idParentField)
        name = try container.decode(String.self, forKey: .name)
        value = try container.decode(String.self, forKey: .value)
        options = try container.decode([FieldOption].self, forKey: .options)
        selectedOption = try container.decode(FieldOption?.self, forKey: .selectedOption)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case idTypeField
        case idParentField
        case name
        case value
        case options
        case selectedOption
    }
}

@objc public class FieldOption: NSObject, Codable {
    @objc public var id: Int = 0
    @objc public var value = ""
    @objc public var idsParentOption = [Int]()
    
    override init() {
        super.init()
    }
    
    init(id: Int, value: String) {
        self.id = id
        self.value = value
    }
    
    // MARK: - Codable methods
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(value, forKey: .value)
        try container.encode(idsParentOption, forKey: .idsParentOption)
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        value = try container.decode(String.self, forKey: .value)
        idsParentOption = try container.decode([Int].self, forKey: .idsParentOption)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case value
        case idsParentOption
    }
}
