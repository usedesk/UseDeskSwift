//
//  UDChatHostingController.swift
//  UseDesk_SDK_Swift

import SwiftUI

final class UDChatHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        super.viewDidLoad()
        disableKeyboardAvoidance()
    }

    private func disableKeyboardAvoidance() {
        guard let viewClass = object_getClass(view) else { return }

        let subclassName = String(cString: class_getName(viewClass)).appending("_UDNoKeyboard")
        if let existing = NSClassFromString(subclassName) {
            object_setClass(view, existing)
            return
        }

        guard let subclassNameUtf8 = (subclassName as NSString).utf8String,
              let subclass = objc_allocateClassPair(viewClass, subclassNameUtf8, 0) else { return }

        let noop: @convention(block) (AnyObject, AnyObject) -> Void = { _, _ in }
        for selectorName in ["keyboardWillShowWithNotification:", "keyboardWillHideWithNotification:"] {
            let selector = NSSelectorFromString(selectorName)
            if let method = class_getInstanceMethod(viewClass, selector) {
                class_addMethod(subclass, selector, imp_implementationWithBlock(noop), method_getTypeEncoding(method))
            }
        }

        objc_registerClassPair(subclass)
        object_setClass(view, subclass)
    }
}
