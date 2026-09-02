# UseDesk_SDK_Swift

![https://img.shields.io/cocoapods/v/UseDesk_SDK_Swift.svg?style=flat-square](https://img.shields.io/cocoapods/v/UseDesk_SDK_Swift.svg?style=flat-square)

## This manual in other languages

Also available in [Russian](README_RU.md)

## Demo app

The "Example" folder of this repository contains a demo project that serves as an example of embedding the Usedesk chat SDK into a client application. You can use it to get acquainted with the basic functionality of the application and test the SDK. 

### Launching a demo project

To launch a demo project you need to:

- Clone repository
- Start terminal
- Go to the **Example** folder of the cloned repository
- Execute a command `pod install`

## Adding a library to the project

### CocoaPods

When you add an SDK to a project with CocoaPods, both GUI and non-GUI functionality is available. To install: 

- Add a Podfile entry to your application

```ruby
pod 'UseDesk_SDK_Swift'
```

- Run a command in the terminal `pod update`
- Import library:

```swift
import UseDesk
```

### Swift Package Manager (SPM)

The SDK implementation for installation using SPM is placed in a separate [repository](https://github.com/usedesk/UseDeskSPM). Please note that GUI is not available when installing with SPM. 

## Initializing a Chat or Knowledge Base with Chat using the GUI

### Parameters used in the configuration SDK with GUI

Where * — required parameter

| **Parameter** | **Type** | **Description** |
| --- | --- | --- |
| **CompanyID*** | String | **Company ID in Usedesk**<br/>[How to find a company ID](https://en.usedocs.com/article/6396) |
| **ChannelID*** | String | **ID of the chat channel through which messages from the application will be placed at Usedesk**<br/>[How to create and set up a channel](https://en.usedocs.com/article/16616) |
| **Url*** | String | **Server URL for SDK chats**<br/>By default: `pubsubsec.usedesk.ru`<br/>If you use server version of Usedesk on your own server, value may be different for you. Check with support for valid URL — support@usedesk.com |
| **Port** | String | **Server port for SDK chats**<br/>By default: `443` |
| **UrlAPI*** | String | **URL to work with Usedesk API**<br/>By default: `secure.usedesk.ru/uapi`<br/>If you use server version of Usedesk on your own server, value may be different for you. Check with support for valid URL — support@usedesk.com |
| **API_token** | String | **Usedesk API Token**<br/>[How to get API Token](https://en.usedocs.com/article/10169) |
| **UrlToSendFile** | String | **URL for sending files**<br/>By default: `https://secure.usedesk.ru/uapi/v1/send_file` |
| **KnowledgeBaseID** | String | **Knowledge Base ID**<br/>[How to create a Knowledge Base](https://en.usedocs.com/article/7182)<br/>**If ID is not provided, Knowledge Base will not be used** |
| **KnowledgeBaseSectionId** | String | **Knowledge Base section ID**<br/>This ID can be found in the URL of your Knowledge Base section<br/>If this parameter is specified, the specified section will be opened when opening the knowledge base|
| **knowledgeBaseCategoryId** | String | **Knowledge Base category ID**<br/>This ID can be found in the URL of your Knowledge Base category<br/>If this parameter is specified, the specified category will be opened when opening the knowledge base|
| **knowledgeBaseArticleId** | String | **Knowledge Base article ID**<br/>This ID can be found in the URL of your Knowledge Base article<br/>If this parameter is specified, the specified article will be opened when opening the knowledge base|
| **isReturnToParentFromKnowledgeBase** | Bool | **Flag which specifies the behaviour of the “Back” button of Knowledge Base if an individual category, section or article is specified**<br/>Default value: `false`<br/>If `true`, pressing the “Back” button will close the entire Knowledge Base|
| **Name** | String | **Client name** |
| **Email** | String | **Client email** |
| **Phone** | String | **Client phone** |
| **Avatar** | Data? | **Client avatar** |
| **AvatarUrl** | URL? | **URL of client avatar image**<br/>Avatar parameter has higher priority|
| **Token** | String | **A unique token that uniquely identifies the user and his conversation**<br/>The token is provided in the callback after the initialization of the chat and is linked to the mail-phone-user name.<br/>To identify different users on the same device, you must store and pass the received token to the initialization method |
| **AdditionalId** | String | **Additional customer ID** |
| **Note** | String | **Text of note** |
| **AdditionalFields** | Int : String | **Array of ticket additional fields**<br/>Format: `id : "value"`<br/>For text fields the value is a string, for a list the value is a string with the exact list value, for a flag the value is a string `false` or `true` |
| **AdditionalNestedFields** | Int : String | **Array of additional fields of nested list type**<br/>Each subarray represents one nested list. <br/>Format of nested list: `[id1: "value", id2 : "value", id3 : "value"]`, where `id1`, `id2`, `id3` — value identifiers by nesting levels |
| **NameOperator** | String | **Name of agent**<br/>If specified, the string will be displayed instead of the agent's name in the conversation |
| **NameChat** | String | **Chat name**<br/>Displays in the header |
| **FirstMessage** | String | **Automatic message**<br/>Sent immediately after initialization on behalf of the client |
| **CountMessagesOnInit** | Int | **Number of loaded messages when starting the chat**<br/>When client open a chat, a specified number of messages are loaded. As client scrolls chat, 20 more messages are loaded |
| **LocaleIdentifier** | String | **Language Identifier**<br/>Available languages: Russian (`ru`), English (`en`), Portugiese (`pt`), Spanish (`es`). <br/>If passed identifier is not supported, the Russian language will be used |
| **CustomLocale** | String : String | **Your own translation dictionary**<br/>If the SDK needs to be displayed in a language we do not support, you can create a translation dictionary yourself and use it |
| **Storage** | UDStorage | **Storage that supports UDStorage protocol**<br/> Each individual chat must be given its own separate storage |
| **isCacheMessagesWithFile** | Bool | **Flag to store messages with files in cache**<br/>By default: `true`<br/>If `true`, files will be stored in the cache. If `false`, files won't be stored in the cache |
| **isSaveTokensInUserDefaults** | Bool | **Flag to store user token in UserDefaults of the application**<br/>By default: `true`<br/>If `true`, the token will be stored in the current device. The disadvantages of this approach are that if you reinstall the application, change device or platform, access to your correspondence will be lost. <br/>To preserve access to client conversations from other devices and platforms, the token must be stored on your system and transferred during initialization. In this case, you must use the value of the parameter `false` |
| **isPresentDefaultControllers** | Bool | **The flag of automatic display of the controller in the specified parent controller**<br/>By default: `true` |
| **PresentIn** | UIViewController | **Controller in which the SDK must be opened** |

### Initializing chat and chat with the Knowledge Base (GUI)

Do not initialize the library in the `viewDidLoad()` method

```swift
let usedesk = UseDeskSDK()
usedesk.start(
    withCompanyID: "1234567", 
    chanelId: "1234", 
    url: "pubsubsec.usedesk.ru", 
    port: "443",
    urlAPI: "secure.usedesk.ru", 
    api_token: "143ed59g90ef093s",
    urlToSendFile: "https://secure.usedesk.ru/uapi/v1/send_file", 
    knowledgeBaseID: "12", 
    knowledgeBaseSectionId: "0",
    knowledgeBaseCategoryId: "0",
    knowledgeBaseArticleId: "0",
    isReturnToParentFromKnowledgeBase: true,
    name: "Name", 
    email: "lolo@yandex.ru", 
    phone: "89000000000", 
    avatar: avatarData,
    token: "Token", 
    additional_id: "additional_id",
    note: "Note text", 
    additionalFields: [1 : "value"], 
    additionalNestedFields: [[1 : "value1", 2 : "value2", 3 : "value3"]],
    nameOperator: "NameOperator", 
    nameChat: "NameChat", 
    firstMessage: "message",
    сountMessagesOnInit: 30,
    localeIdentifier: "en", 
    customLocale: customLocaleDictionary, 
    storage: UDStorage(),
    isCacheMessagesWithFile: false,
    isSaveTokensInUserDefaults: true, 
    isPresentDefaultControllers: true, 
    presentIn: self,
    connectionStatus: { success, feedbackStatus, token in },
    errorStatus: { udError, description in }
)
```

### Parameters returned by the block

****СonnectionStatus****

| Type | Description |
| --- | --- |
| Bool | Successful connection to the chat |
| UDFeedbackStatus | Feedback form display status |
| String | User token |

****ErrorStatus****

| Type | Description |
| --- | --- |
| UDError | Documented error type |
| String? | Error description |

## Initializing the Knowledge Base without chat using the GUI

The SDK allows you to implement the Knowledge Base in your application without embedding chat. 

In the selected method, in addition to the other required parameters, you can pass the identifier of the section, category or article. In this case, after SDK initialization, the specified section, category or article will open, from which you can go back according to the hierarchy of the Knowledge Base. If you specify the identifier of the section, category and/or article at the same time, we will show the deepest entity.

### Parameters used in SDK configuration with GUI

Where * — required parameter
| **Parameter** | **Type** | **Description** |
| --- | --- | --- |
| **UrlAPI*** | String | **URL to work with Usedesk API**<br/>By default: `secure.usedesk.ru/uapi`<br/>If you use server version of Usedesk on your own server, value may be different for you. Check with support for valid URL — support@usedesk.com |
| **API_token** | String | **Usedesk API Token**<br/>[How to get API Token](https://en.usedocs.com/article/10169) ||
| **KnowledgeBaseID** | String | **Knowledge Base ID**<br/>[How to create a Knowledge Base](https://en.usedocs.com/article/7182)<br/>**If ID is not provided, Knowledge Base will not be used** |
| **KnowledgeBaseSectionId** | String | **Knowledge Base section ID**<br/>This ID can be found in the URL of your Knowledge Base section<br/>If this parameter is specified, the specified section will be opened when opening the knowledge base|
| **knowledgeBaseCategoryId** | String | **Knowledge Base category ID**<br/>This ID can be found in the URL of your Knowledge Base category<br/>If this parameter is specified, the specified category will be opened when opening the knowledge base|
| **knowledgeBaseArticleId** | String | **Knowledge Base article ID**<br/>This ID can be found in the URL of your Knowledge Base article<br/>If this parameter is specified, the specified article will be opened when opening the knowledge base|
| **isReturnToParentFromKnowledgeBase** | Bool | **Flag which specifies the behaviour of the “Back” button of Knowledge Base if an individual category, section or article is specified**<br/>Default value: `false`<br/>If `true`, pressing the “Back” button will close the entire Knowledge Base|
| **Name** | String | **Client name** |
| **Email** | String | **Client email** |
| **Phone** | String | **Client phone** |
| **LocaleIdentifier** | String | **Language Identifier**<br/>Available languages: Russian (`ru`), English (`en`), Portugiese (`pt`), Spanish (`es`). <br/>If passed identifier is not supported, the Russian language will be used |
| **CustomLocale** | String : String | **Your own translation dictionary**<br/>If the SDK needs to be displayed in a language we do not support, you can create a translation dictionary yourself and use it |
| **isPresentDefaultControllers** | Bool | **The flag of automatic display of the controller in the specified parent controller**<br/>By default: `true` |
| **PresentIn** | UIViewController | **Controller in which the SDK must be opened** |

### Initializing the SDK with the GUI, Knowledge Base only

```swift
let usedesk = UseDeskSDK()
usedesk.startKnowledgeBase(
    urlAPI: "pubsubsec.usedesk.ru", 
    api_token: "143ed59g90ef093s",
    knowledgeBaseID: "12", 
    knowledgeBaseSectionId: "0",
    knowledgeBaseCategoryId: "0",
    knowledgeBaseArticleId: "0",
    isReturnToParentFromKnowledgeBase: true,
    name: "Name", 
    email: "lolo@yandex.ru", 
    phone: "89000000000", 
    localeIdentifier: "en", 
    customLocale: customLocaleDictionary, 
    isPresentDefaultControllers: true, 
    presentIn: self,
    connectionStatus: { success in },
    errorStatus: { udError, description in }
)
```

### Parameters returned by the block

****СonnectionStatus****

| Type | Description |
| --- | --- |
| Bool | The success of opening a Knowledge Base |

****ErrorStatus****

| Type | Description |
| --- | --- |
| Bool | Successful connection to the chat |
| UDFeedbackStatus | Feedback form display status |

## Initializing SDK without GUI

### Parameters used in the SDK configuration without GUI

Where * — required parameter
| **Parameter** | **Type** | **Description** |
| --- | --- | --- |
| **CompanyID*** | String | **Company ID in Usedesk**<br/>[How to find a company ID](https://en.usedocs.com/article/6396) |
| **ChannelID*** | String | **ID of the chat channel through which messages from the application will be placed at Usedesk**<br/>[How to create and set up a channel](https://en.usedocs.com/article/16616) |
| **Url*** | String | **Server URL for SDK chats**<br/>By default: `pubsubsec.usedesk.ru`<br/>If you use server version of Usedesk on your own server, value may be different for you. Check with support for valid URL — support@usedesk.com |
| **Port** | String | **Server port for SDK chats**<br/>By default: `443` |
| **UrlAPI*** | String | **URL to work with Usedesk API**<br/>By default: `secure.usedesk.ru/uapi`<br/>If you use server version of Usedesk on your own server, value may be different for you. Check with support for valid URL — support@usedesk.com |
| **API_token** | String | **Usedesk API Token**<br/>[How to get API Token](https://en.usedocs.com/article/10169) |
| **UrlToSendFile** | String | **URL for sending files**<br/>By default: `https://secure.usedesk.ru/uapi/v1/send_file` |
| **KnowledgeBaseID** | String | **Knowledge Base ID**<br/>[How to create a Knowledge Base](https://en.usedocs.com/article/7182)<br/>**If ID is not provided, Knowledge Base will not be used** |
| **Name** | String | **Client name** |
| **Email** | String | **Client email** |
| **Phone** | String | **Client phone** |
| **Avatar** | Data? | **Client avatar** |
| **AvatarUrl** | URL? | **URL of client avatar image**<br/>Avatar parameter has higher priority|
| **Token** | String | **A unique token that uniquely identifies the user and his conversation**<br/>The token is provided in the callback after the initialization of the chat and is linked to the mail-phone-user name.<br/>To identify different users on the same device, you must store and pass the received token to the initialization method |
| **AdditionalId** | String | **Additional customer ID** |
| **Note** | String | **Text of note** |
| **AdditionalFields** | Int : String | **Array of ticket additional fields**<br/>Format: `id : "value"`<br/>For text fields the value is a string, for a list the value is a string with the exact list value, for a flag the value is a string `false` or `true` |
| **AdditionalNestedFields** | Int : String | **Array of additional fields of nested list type**<br/>Each subarray represents one nested list. <br/>Format of nested list: `[id1: "value", id2 : "value", id3 : "value"]`, where `id1`, `id2`, `id3` — value identifiers by nesting levels |
| **FirstMessage** | String | **Automatic message**<br/>Sent immediately after initialization on behalf of the client |
| **CountMessagesOnInit** | Int | **Number of loaded messages when starting the chat**<br/>When client open a chat, a specified number of messages are loaded. As client scrolls chat, 20 more messages are loaded |
| **LocaleIdentifier** | String | **Language Identifier**<br/>Available languages: Russian (`ru`), English (`en`), Portugiese (`pt`), Spanish (`es`). <br/>If passed identifier is not supported, the Russian language will be used |
| **CustomLocale** | String : String | **Your own translation dictionary**<br/>If the SDK needs to be displayed in a language we do not support, you can create a translation dictionary yourself and use it |
| **isSaveTokensInUserDefaults** | Bool | **Flag to store user token in UserDefaults of the application**<br/>By default: `true`<br/>If `true`, the token will be stored in the current device. The disadvantages of this approach are that if you reinstall the application, change device or platform, access to your correspondence will be lost. <br/>To preserve access to client conversations from other devices and platforms, the token must be stored on your system and transferred during initialization. In this case, you must use the value of the parameter `false` |

### Initializing  SDK without a GUI

```swift
let usedesk = UseDeskSDK()
usedesk.startWithoutGUICompanyID(
    companyID: "1234567",
    chanelId: "1234", 
    url: "pubsubsec.usedesk.ru", 
    port: "443",
    urlAPI: "secure.usedesk.ru", 
    api_token: "143ed59g90ef093s",
    urlToSendFile: "https://secure.usedesk.ru/uapi/v1/send_file", 
    knowledgeBaseID: "12",
    name: "Name", 
    email: "lolo@yandex.ru", 
    phone: "89000000000", 
    avatar: avatarData,
    token: "Token", 
    additional_id: "additional_id",
    note: "Note text", 
    additionalFields: [1 : "value"], 
    additionalNestedFields: [[1 : "value1", 2 : "value2", 3 : "value3"]], 
    firstMessage: "message",
    сountMessagesOnInit: 30,
    localeIdentifier: "en", 
    customLocale: customLocaleDictionary,
    isSaveTokensInUserDefaults: true,
    connectionStatus: { success, feedbackStatus, token in },
    errorStatus: { udError, description in }
)
```

### Parameters returned by the block

****СonnectionStatus****

| Type | Description |
| --- | --- |
| Bool | Successful connection to the chat |
| UDFeedbackStatus | Feedback form display status |
| String | User token |

****ErrorStatus****

| Type | Description |
| --- | --- |
| UDError | Documented error type |
| String? | Error description |

## Documentation

Methods for working with the SDK, customization of elements, and errors are described in our documentation: [http://sdk.usedocs.com](http://sdk.usedocs.com/)

## Authors

Sergey, [kon.sergius@gmail.com](mailto:kon.sergius@gmail.com)

Maksim, [ixotdog@gmail.com](mailto:ixotdog@gmail.com)

## ****License****

UseDesk_SDK_Swift is available under the MIT license. See the LICENSE file for more info
