//
//  UDMessageFormView.swift
//  UseDesk_SDK_Swift

import SwiftUI

struct UDMessageFormView: View {
    let message: UDMessage
    @ObservedObject var viewModel: UDChatMessagesViewModel

    @State private var previousStatus: StatusForm?
    @State private var showSendError = false
    @State private var fieldTexts: [Int: String] = [:]
    @FocusState private var focusedFormIndex: Int?

    private var style: MessageFormStyle {
        viewModel.configurationStyle.messageFormStyle
    }

    private var isInputable: Bool {
        message.statusForms == .inputable
    }

    private var isLoading: Bool {
        message.statusForms == .loading
    }

    private var isLoadingFields: Bool {
        message.forms.contains { $0.type == .additionalField && $0.field == nil }
    }

    private var sendTitle: String {
        let model = viewModel.usedesk?.model

        switch message.statusForms {
        case .sended: 
            return model?.stringFor("Sended") ?? "Sended"
        default: 
            return model?.stringFor("Send") ?? "Send"
        }
    }

    private var sendButtonColor: UIColor {
        if showSendError {
            return style.sendFormButtonErrorColor
        }
        return isInputable || isLoading ? style.sendFormButtonColor : style.sendFormButtonUnavailableColor
    }

    var body: some View {
        if isLoadingFields {
            loadingFieldsView
        } else {
            formView
        }
    }

    private var loadingFieldsView: some View {
        HStack {
            Spacer(minLength: 0)
            
            UDActivityIndicator(style: style.formLoaderActivityIndicatorStyle)

            Spacer(minLength: 0)
        }
        .frame(minHeight: style.textFormHeight)
        .padding(style.margin.udSwiftUIInsets)
    }

    private var formView: some View {
        VStack(alignment: .leading, spacing: style.spacing) {
            ForEach(Array(message.forms.enumerated()), id: \.offset) { index, form in
                formRow(form: form, index: index)
            }

            Button {
                guard isInputable else { return }
                viewModel.onSendForm?(message)
            } label: {
                ZStack {
                    Text(showSendError ? (viewModel.usedesk?.model.stringFor("Error") ?? "Error") : sendTitle)
                        .font(Font(style.sendFormButtonFont))
                        .opacity(isLoading ? 0 : 1)
                    
                    if isLoading {
                        UDActivityIndicator(style: style.sendFormActivityIndicatorStyle)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: style.sendFormButtonHeight)
                .background(
                    RoundedRectangle(cornerRadius: style.sendFormButtonCornerRadius)
                        .fill(Color(sendButtonColor))
                )
            }
            .buttonStyle(UDFormSendButtonStyle(titleColor: style.sendFormButtonTitleColor, titleTouchedColor: style.sendFormButtonTitleTouchedColor))
            .disabled(!isInputable)
            .padding(style.sendFormButtonMargin.udSwiftUIInsets)
        }
        .padding(style.margin.udSwiftUIInsets)
        .onChange(of: message.statusForms) { newStatus in
            if previousStatus == .loading && newStatus == .inputable {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSendError = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSendError = false
                    }
                }
            }
            previousStatus = newStatus
        }
        .onAppear {
            previousStatus = message.statusForms
        }
        .onChange(of: focusedFormIndex) { (newValue: Int?) in
            guard let index = newValue else { return }
            viewModel.focusedFormFieldId = fieldId(index: index)
        }
    }

    private func fieldId(index: Int) -> String {
        "formfield_\(ObjectIdentifier(message).hashValue)_\(index)"
    }

    @ViewBuilder
    private func formRow(form: UDFormMessage, index: Int) -> some View {
        let borderColor = form.isErrorState ? Color(UIColor(cgColor: style.textFormBorderErrorColor)) : Color(UIColor(cgColor: style.textFormBorderColor))
        
        if form.type == .additionalField, form.field?.type == .checkbox {
            Button {
                guard isInputable else { return }
                viewModel.onToggleFormCheckbox?(message, index)
            } label: {
                HStack(alignment: .top, spacing: 0) {
                    Image(uiImage: checkboxImage(for: form))
                        .resizable()
                        .frame(width: style.checkboxFormImageSize.width, height: style.checkboxFormImageSize.height)
                        .padding(style.checkboxFormImageMargin.udSwiftUIInsets)
                    
                    Text(form.name)
                        .font(Font(style.textFormTextFont))
                        .foregroundColor(Color(isInputable ? style.textFormTextColor : style.textFormTextUnavailableColor))
                        .padding(style.checkboxFormTextMargin.udSwiftUIInsets)
                    
                    Spacer(minLength: 0)
                }
            }
            .disabled(!isInputable)
        } else if form.type == .additionalField, form.field?.type == .list {
            let isEnabledForSelect = isFormListEnableForSelect(form: form)
            
            Button {
                guard isInputable, isEnabledForSelect else { return }
                viewModel.onSelectFormField?(message, index)
            } label: {
                formListView(form: form, borderColor: borderColor)
            }
            .disabled(!isInputable || !isEnabledForSelect)
        } else {
            let placeholder = form.name
            let currentText = fieldTexts[index] ?? form.value

            HStack {
                ZStack(alignment: .leading) {
                    if currentText.isEmpty {
                        (Text(placeholder).foregroundColor(Color(style.textFormPlaceholderColor))
                            + (form.isRequired ? Text("*").foregroundColor(Color(style.textFormTextRequiredColor)) : Text(""))
                        )
                        .font(Font(style.textFormTextFont))
                    }
                    
                    TextField("", text: textBinding(for: form, index: index))
                        .font(Font(style.textFormTextFont))
                        .foregroundColor(Color(isInputable ? style.textFormTextColor : style.textFormTextUnavailableColor))
                        .keyboardType(keyboardType(for: form))
                        .disabled(!isInputable)
                        .focused($focusedFormIndex, equals: index)
                }
            }
            .padding(style.textFormMargin.udSwiftUIInsets)
            .frame(minHeight: style.textFormHeight)
            .background(
                RoundedRectangle(cornerRadius: style.textFormCornerRadius)
                    .fill(Color(isInputable ? style.textFormBackgroundColor : style.textFormUnavailableBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: style.textFormCornerRadius)
                    .stroke(borderColor, lineWidth: style.textFormBorderWidth)
            )
            .id(fieldId(index: index))
        }
    }

    private func textBinding(for form: UDFormMessage, index: Int) -> Binding<String> {
        Binding(
            get: { fieldTexts[index] ?? form.value },
            set: { newValue in
                fieldTexts[index] = newValue
                form.value = newValue
                form.field?.value = newValue
                viewModel.onChangeFormText?(message, index, newValue)
            }
        )
    }

    private func keyboardType(for form: UDFormMessage) -> UIKeyboardType {
        switch form.type {
        case .email:
            return .emailAddress
        case .phone:
            return .phonePad
        default:
            return .default
        }
    }

    private func checkboxImage(for form: UDFormMessage) -> UIImage {
        if form.isErrorState { return style.checkboxFormImageError }
        let selected = form.value == "1" || form.field?.value == "1"
        if selected {
            return isInputable ? style.checkboxFormImageSelected : style.checkboxFormImageSelectedUnavailable
        }
        return style.checkboxFormImageNotSelected
    }

    private func isFormListEnableForSelect(form: UDFormMessage) -> Bool {
        guard let idParentField = form.field?.idParentField else { return false }
        if idParentField > 0 {
            if let parentForm = message.forms.filter({ $0.field?.id ?? 0 == idParentField }).first, parentForm.field?.selectedOption != nil {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }

    @ViewBuilder
    private func formListView(form: UDFormMessage, borderColor: Color) -> some View {
        let isPlaceholder = form.field?.selectedOption == nil
        let text = form.field?.selectedOption?.value ?? form.name
        let colorText = isFormListEnableForSelect(form: form)
            ? Color(isInputable ? style.textFormTextColor : style.textFormTextUnavailableColor)
            : Color(style.textFormPlaceholderColor)

        HStack {
            (Text(text).foregroundColor(colorText)
                + (form.isRequired && isPlaceholder ? Text("*").foregroundColor(Color(style.textFormTextRequiredColor)) : Text(""))
            )
            .font(Font(style.textFormTextFont))
            .lineLimit(1)
            
            Spacer(minLength: 0)
            
            Image(uiImage: style.textFormIconSelect)
                .resizable()
                .scaledToFit()
                .frame(width: style.textFormIconSelectSize.width, height: style.textFormIconSelectSize.height)
                .padding(style.textFormIconMargin.udSwiftUIInsets)
        }
        .padding(style.textFormMargin.udSwiftUIInsets)
        .frame(minHeight: style.textFormHeight)
        .background(
            RoundedRectangle(cornerRadius: style.textFormCornerRadius)
                .fill(Color(isInputable ? style.textFormBackgroundColor : style.textFormUnavailableBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: style.textFormCornerRadius)
                .stroke(borderColor, lineWidth: style.textFormBorderWidth)
        )
    }
}

private struct UDFormSendButtonStyle: ButtonStyle {
    let titleColor: UIColor
    let titleTouchedColor: UIColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color(configuration.isPressed ? titleTouchedColor : titleColor))
    }
}
