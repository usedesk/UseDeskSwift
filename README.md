# UseDesk_SDK_Swift
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/UseDesk_SDK_Swift.svg?style=flat-square)](https://img.shields.io/cocoapods/v/UseDesk_SDK_Swift.svg)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

- [Образец](#образец)
- [Добавление библиотеки в проект](#добавление-библиотеки-в-проект)
- [Классы базы знаний](#классы-базы-знаний)
- [Документация](#Документация)

# Образец
Чтобы запустить пример проекта, клонируйте репозиторий и сначала запустите `pod install` из каталога примера.

## Тестовое приложение

Для запуска тестового приложения нужно:

-Клонировать репозиторий

-Запустить терминал

-Перейти в скаченную дирректорию (в папку Example)

-Выполнить команду `pod install`

# Добавление библиотеки в проект:

####  CocoaPods

Полный функционал с нашим GUI доступен через [CocoaPods](http://cocoapods.org).

-Добавьте строчку в Podfile вашего приложения

```ruby
pod 'UseDesk_SDK_Swift'
```

-Выполните команду в терминале `pod update`

-Подключаем библиотеку import UseDesk`

#### Swift Package Manager

```swift
.package(url: "https://github.com/usedesk/UseDeskSwift.git", from: "2.1.0")
```

## ВАЖНЫЕ ОБНОВЛЕНИЯ: 
Начиная с версии 2.0.0 мы заменяем параметр signature на token. Токен выдается в коллбэке после инициализации чата и привязывается к связке почта-телефон-имя пользователя. Для идентификации различных пользователей на одном устройстве вы должны хранить и передавать полученный токен в метод инициализации.

В параметре Url вместо `pubsub.usedesk.ru` нужно указывать `pubsubsec.usedesk.ru`

## Выполняем операцию инициализации чата параметрами:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| CompanyID\* | String | идентификатор компании. Как найти описано в [документации](https://docs.usedesk.ru/article/61) |
| ChanelId\* | String | идентификатор канала (добавлен  в v1.1.5). Как найти описано в [документации](https://docs.usedesk.ru/article/10167) |
| UrlAPI\* | String | Адрес API. Стандартное значение `secure.usedesk.ru/` |
| Knowledge Base ID | String | идентификатор базы знаний. Если не указан, база знаний не используется |
| API Token\* | String | личный API ключ |
| Email | String | почта клиента |
| Phone | String | телефон клиента |
| Url\* | String | адрес сервера в формате - pubsubsec.usedesk.ru |
| UrlToSendFile | String | Адрес для отправки файлов. Стандартное значение `https://secure.usedesk.ru/uapi/v1/send_file`  |
| Port | String | порт сервера |
| Name | String | имя клиента |
| NameOperator | String | имя оператора |
| NameChat | String | имя чата. Отображается в шапке |
| FirstMessage | String | автоматическое сообщение. Отправиться сразу после иницилизации от имени клиента |
| Note | String | текст заметки |
| Token | String | подпись, однозначно идентифицирующая пользователя и его чат на любых устройствах для сохранения истории переписки. (генерирует наша система,  ограничение не меньше 64 символа) |
| LocaleIdentifier | String | идентификатор языка. Доступные языки: русский ("ru"), английский ("en"), португальский ("pt"), испанский ("es"). Если переданный идентификатор не поддерживается, будет выбран русский язык. |
| CustomLocale | [String : String] | Можно передать свой словарь переводов |
| Storage | UDStorage | хранилище поддерживающее протокол [UDStorage](https://github.com/usedesk/UseDeskSwift/blob/master/UseDesk/Core/UseDeskSDK.swift). Для каждого отдельного чата нужно передавать свое отдельное хранилище. |
| isCacheMessagesWithFile | Bool | Сохранять ли сообщения содержащие файлы |
| PresentIn | UIViewController | в каком контроллере открывать |
| isUseBase | Bool | Начиная с версии 0.3.19 не используется |
| Signature | String | Начиная с версии 2.0.0 не используется |

\* - обязательный параметр

### Блок возвращает следующие параметры:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Success | Bool | статус подключения к серверу |
| Error | String | описание ошибки при неудачном подключении |
| Token | String | токен пользователя |

#### Пример c использованием базы знаний:
``` swift
let usedesk = UseDeskSDK()
usedesk.start(withCompanyID: "1234567", chanelId: "1234", knowledgeBaseID: "1", api_token: "143ed59g90ef093s", email: "lolo@yandex.ru", phone: "89000000000", url: "pubsubsec.usedesk.ru", urlToSendFile: "https://secure.usedesk.ru/uapi/v1/send_file", port: "213", name: "Name", operatorName: "NameOperator", nameChat: "NameChat", firstMessage: "message", note: "Note text", token: "Token", localeIdentifier: "en", customLocale: customLocaleDictionary, presentIn: self, connectionStatus: { success, error in

})
```

#### Пример без использования базы знаний:
``` swift
let usedesk = UseDeskSDK()
usedesk.start(withCompanyID: "1234567", chanelId: "1234", api_token: "143ed59g90ef093s", email: "lolo@yandex.ru", phone: "89000000000", url: "pubsubsec.usedesk.ru", urlToSendFile: "https://secure.usedesk.ru/uapi/v1/send_file", port: "213", name: "Name", operatorName: "NameOperator", nameChat: "NameChat", firstMessage: "message", note: "Note text", token: "Token", localeIdentifier: "en", customLocale: customLocaleDictionary, connectionStatus: { success, error in

})
```

## Подключение SDK без графического интерфейса

- Выполняем операцию инициализации чата параметрами без GUI:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| CompanyID\* | String | идентификатор компании. Как найти описано в [документации](https://docs.usedesk.ru/article/61) |
| ChanelId\* | String | идентификатор канала (добавлен  в v1.1.5). Как найти описано в [документации](https://docs.usedesk.ru/article/10167) |
| UrlAPI\* | String | адрес  - devsecure.usedesk.ru/uapi |
| API Token\* | String | личный API ключ |
| Url\* | String | адрес сервера в формате - pubsubsec.usedesk.ru |
| Knowledge Base ID | String | идентификатор базы знаний. Если не указан, база знаний не используется |
| Email | String | почта клиента |
| Phone | String | телефон клиента |
| UrlToSendFile | String | Адрес для отправки файлов. Стандартное значение `https://secure.usedesk.ru/uapi/v1/send_file`  |
| Port | String | порт сервера  |
| Name | String | имя клиента |
| NameOperator | String | имя оператора |
| NameChat | String | имя чата. Отображается в шапке |
| FirstMessage | String | автоматическое сообщение. Отправиться сразу после иницилизации от имени клиента |
| Note | String | текст заметки |
| Token | String | подпись, однозначно идентифицирующая пользователя и его чат на любых устройствах для сохранения истории переписки. (генерирует наша система,  ограничение не меньше 64 символа) |
| isUseBase | Bool | Начиная с версии 0.3.19 не используется |
| Signature | String | Начиная с версии 2.0.0 не используется |

\* - обязательный параметр

#### Пример:
```swift
let usedesk = UseDeskSDK()
usedesk.startWithoutGUICompanyID(companyID: "1234567", chanelId: "1234", knowledgeBaseID: "1", api_token: "143ed59g90ef093s", email: "lolo@yandex.ru", phone: "89000000000", url: "pubsubsec.usedesk.ru", urlToSendFile: "https://secure.usedesk.ru/uapi/v1/send_file", port: "213", name: "Name", operatorName: "NameOperator", nameChat: "NameChat", firstMessage: "message", note: "Note text", token: "Token", connectionStatus: { (success, error) in

})
```

### Блок возвращает следующие параметры:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Success | Bool| статус подключения к серверу |
| Error | String | описание ошибки при неудачном подключении |
| Token | String | токен пользователя |

Если тип ошибки noOperators то нет доступных операторов в данный момент времени


# Документация:

Документация находится по адресу - http://sdk.usedocs.ru/

## Author

Сергей, kon.sergius@gmail.com

Максим, ixotdog@gmail.com

## License

UseDesk_SDK_Swift is available under the MIT license. See the LICENSE file for more info.

