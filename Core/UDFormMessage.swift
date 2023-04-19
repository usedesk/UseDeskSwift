//
//  UDFormMessage.swift
//  UseDesk_SDK_Swift

import Foundation

enum StatusForm: Int {
    case inputable = 1
    case loading = 2
    case sended = 3
}

public enum UDFormMessageAssociateType: String, Codable {
    case email = "email"
    case phone = "phone"
    case name = "name"
    case note = "note"
    case position = "position"
    case additionalField = "additionalField"
}

public class UDFormMessage: NSObject, Codable {
    
    @objc public var name = ""
    @objc public var associate: String = ""
    public var type: UDFormMessageAssociateType!
    @objc public var idAdditionalField: Int = 0
    @objc public var field: UDField? = nil
    @objc public var value = ""
    @objc public var isRequired = false
    @objc public var isErrorState = false
    
    init(name: String = "", type: UDFormMessageAssociateType!, value: String = "", field: UDField? = nil) {
        self.name = name
        self.associate = type.rawValue
        self.type = type
        self.value = value
        self.field = field
        idAdditionalField = field?.id ?? 0
    }
    
    // MARK: - Codable methods
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(associate, forKey: .associate)
//        try container.encode(type, forKey: .type)
        try container.encode(idAdditionalField, forKey: .idAdditionalField)
        try container.encode(field, forKey: .field)
        try container.encode(value, forKey: .value)
        try container.encode(isRequired, forKey: .isRequired)
        try container.encode(isErrorState, forKey: .isErrorState)
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        associate = try container.decode(String.self, forKey: .associate)
        type = UDFormMessageAssociateType(rawValue: associate)//try container.decode(UDFormMessageAssociateType.self, forKey: .type)
        idAdditionalField = try container.decode(Int.self, forKey: .idAdditionalField)
        field = try container.decode(UDField?.self, forKey: .field)
        value = try container.decode(String.self, forKey: .value)
        isRequired = try container.decode(Bool.self, forKey: .isRequired)
        isErrorState = try container.decode(Bool.self, forKey: .isErrorState)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case associate
//        case type
        case idAdditionalField
        case field
        case value
        case isRequired
        case isErrorState
    }
}

public class UDFormMessageManager: NSObject {
    
    private static let kFormKey = "{{form;"
    
    public class func parseForms(from message: String) -> (String, [UDFormMessage]) {
        var text = message
        var forms: [UDFormMessage] = []
        let stringsForms = parseFormsFrom(text: message) // get strings that are possibly form
        for stringForm in stringsForms {
            if let form = formFromString(stringForm) {
                forms.append(form)
                text = text.replacingOccurrences(of: stringForm, with: "")
            }
        }
        return (text, forms)
    }
    
    public class func isForm(string: String) -> Bool {
        return UDFormMessageManager.formFromString(string) != nil
    }
    
    private class func parseFormsFrom(text: String) -> [String] {
        var isAddingForm: Bool = false // flag process adding form symbols
        var stringFromForm = "" // form symbols
        var stringsFromForm = [String]() // forms string
        var countSymbol = text.count - 1 // count symbol. If the rest of the string does not contain a form, then countSymbol = 0 and end for cycle
        if text.count > 10 && text.range(of: kFormKey) != nil {
            for index in 0..<countSymbol {
                if isAddingForm {
                    let indexString = text.index(text.startIndex, offsetBy: index)
                    let secondIndexString = text.index(text.startIndex, offsetBy: index + 1)
                    stringFromForm += String(text[indexString])
                    if (text[indexString] == "}") && (text[secondIndexString] == "}") {
                        stringFromForm += String(text[secondIndexString])
                        isAddingForm = false
                        stringsFromForm.append(stringFromForm)
                        stringFromForm = ""
                        if text[secondIndexString...text.index(before: text.endIndex)].range(of: kFormKey) == nil {
                            countSymbol = 0  // the rest of the string does not contain a form
                        }
                    }
                } else {
                    if index < text.count - 10,
                       let searchStartIndex = text.index(text.startIndex, offsetBy: index, limitedBy: text.endIndex),
                       let searchEndIndex = text.index(searchStartIndex, offsetBy: 6, limitedBy: text.endIndex) {
                            if text[searchStartIndex...searchEndIndex] == kFormKey {
                                if kFormKey.count > 0 {
                                    stringFromForm = String(kFormKey.first!)
                                }
                                isAddingForm = true
                            }
                    }
                }
            }
        }
        return stringsFromForm
    }
    
    private class func formFromString(_ string: String) -> UDFormMessage? {
        var stringsParameters = [String]()
        var charactersFromParameter = [Character]()
        guard let searchStartIndex = string.index(string.startIndex, offsetBy: 0, limitedBy: string.endIndex),
           let searchEndIndex = string.index(searchStartIndex, offsetBy: 6, limitedBy: string.endIndex),
           string[searchStartIndex...searchEndIndex] == kFormKey else {
            return nil
        }
        var index = 7
        while (index < string.count - 2) {
            let indexString = string.index(string.startIndex, offsetBy: index)
            if string[indexString] != ";" {
                charactersFromParameter.append(string[indexString])
                index += 1
            } else {
                stringsParameters.append(String(charactersFromParameter))
                charactersFromParameter = []
                index += 1
            }
            if index == string.count - 2 {
                stringsParameters.append(String(charactersFromParameter))
            }
        }

        if stringsParameters.count > 1 {
            let name = stringsParameters[0]
            guard name.count > 0 else { // name valid
                return nil
            }
            guard stringsParameters[1] != UDFormMessageAssociateType.additionalField.rawValue else {return nil}
            var type = UDFormMessageAssociateType(rawValue: stringsParameters[1])
            var idAdditionalField = 0
            if type == nil, let id = Int(stringsParameters[1]) {
                type = .additionalField
                idAdditionalField = id
            }
            guard type != nil else {return nil}
            let form = UDFormMessage(name: name, type: type!)
            if type == .additionalField {
                form.idAdditionalField = idAdditionalField
            }
            if stringsParameters.count > 2 {
                if stringsParameters[2] == "true" {
                    form.isRequired = true
                }
            }
            return form
        } else {
            return nil
        }
    }
}


