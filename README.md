# UseDesk_SDK_Swift
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/UseDesk_SDK_Swift.svg?style=flat-square)](https://img.shields.io/cocoapods/v/UseDesk_SDK_Swift.svg)

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

###  CocoaPods

Полный функционал с нашим GUI доступен через [CocoaPods](http://cocoapods.org).

-Добавьте строчку в Podfile вашего приложения

```ruby
pod 'UseDesk_SDK_Swift'
```

-Выполните команду в терминале `pod update`

-Подключаем библиотеку import UseDesk`

## ВАЖНЫЕ ОБНОВЛЕНИЯ: 
Начиная с версии 2.0.0 мы заменяем параметр signature на token. Токен выдается в коллбэке после инициализации чата и привязывается к связке почта-телефон-имя пользователя. Для идентификации различных пользователей на одном устройстве вы должны хранить и передавать полученный токен в метод инициализации.

В параметре Url вместо `pubsub.usedesk.ru` нужно указывать `pubsubsec.usedesk.ru`

## Выполняем операцию инициализации чата параметрами:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| CompanyID\* | String | Идентификатор компании. Как найти описано в [документации](https://docs.usedesk.ru/article/61) |
| ChanelId\* | String | Идентификатор канала (добавлен  в v1.1.5). Как найти описано в [документации](https://docs.usedesk.ru/article/10167) |
| UrlAPI\* | String | Адрес API. Стандартное значение `secure.usedesk.ru/uapi` |
| Knowledge Base ID | String | Идентификатор базы знаний. Если не указан, база знаний не используется |
| API Token\* | String | Личный API ключ |
| Email | String | Почта клиента |
| Phone | String | Телефон клиента |
| Url\* | String | Адрес сервера в формате - pubsubsec.usedesk.ru |
| UrlToSendFile | String | Адрес для отправки файлов. Стандартное значение `https://secure.usedesk.ru/uapi/v1/send_file`  |
| Port | String | Порт сервера |
| Name | String | Имя клиента |
| NameOperator | String | Имя оператора |
| NameChat | String | Имя чата. Отображается в шапке |
| FirstMessage | String | Автоматическое сообщение. Отправиться сразу после иницилизации от имени клиента |
| Note | String | Текст заметки |
| AdditionalFields | [Int : String] | Массив дополнительный полей в формате - id : "значение". Для текстовых полей значение - строка, для списка - строка с точно совпадающим значением списка, для флага - строка "false" или "true" |
| AdditionalNestedFields | [[Int : String]] | Массив допл полей типа вложенный список. Каждый подмассив представляет один вложенный список. Формат фложенного списка - [id1: "значение", id2 : "значение", id3 : "значение"], где id1, id2, id3 идентификаторы значений по уровням вложенности |
| AdditionalId | String | Дополнительный идентификатор клиента |
| Token | String | Подпись, однозначно идентифицирующая пользователя и его чат на любых устройствах для сохранения истории переписки. (генерирует наша система,  ограничение не меньше 64 символа) |
| LocaleIdentifier | String | Идентификатор языка. Доступные языки: русский ("ru"), английский ("en"), португальский ("pt"), испанский ("es"). Если переданный идентификатор не поддерживается, будет выбран русский язык. |
| CustomLocale | [String : String] | Можно передать свой словарь переводов |
| Storage | UDStorage | Хранилище поддерживающее протокол [UDStorage](https://github.com/usedesk/UseDeskSwift/blob/master/Core/UseDeskSDK.swift). Для каждого отдельного чата нужно передавать свое отдельное хранилище. |
| isCacheMessagesWithFile | Bool | Сохранять ли сообщения содержащие файлы |
| PresentIn | UIViewController | В каком контроллере открывать | 
| isSaveTokensInUserDefaults | Bool | Сохранять ли токен юзера ("Token", смотреть выше) в UserDefaults приложения. При занчении "True" позволяет не хранить токены в ваших системах, но он будет храниться только в текущем устройстве. Для доступа к переписке клиента с других устройств и платформ необходимо хранить токен в вашей системе и передавать его при инициализации. В этом случае значение параметра должно быть "False" |
| isPresentDefaultControllers | Bool | Показывать ли контроллеры автоматически в указанном родительском контроллере |
| isUseBase | Bool | Начиная с версии 0.3.19 не используется |
| Signature | String | Начиная с версии 2.0.0 не используется |

\* - обязательный параметр

### Блок возвращает следующие параметры:

#### СonnectionStatus:

| Тип | Описание |
| ------------- | ------------- |
| Bool | Успешность подключения к чату |
| UDFeedbackStatus | Статус показа формы обратной связи |
| String | Токен пользователя |

#### ErrorStatus:

| Тип | Описание |
| ------------- | ------------- |
| UDError | Задокументированый тип ошибки |
| UDFeedbackStatus | Описание ошибки |


#### Пример c использованием базы знаний:
``` swift
let usedesk = UseDeskSDK()
usedesk.start(withCompanyID: "1234567", chanelId: "1234", knowledgeBaseID: "1", api_token: "143ed59g90ef093s", email: "lolo@yandex.ru", phone: "89000000000", url: "pubsubsec.usedesk.ru", urlToSendFile: "https://secure.usedesk.ru/uapi/v1/send_file", port: "213", name: "Name", operatorName: "NameOperator", nameChat: "NameChat", firstMessage: "message", note: "Note text", additionalFields: [1 : "value"], additionalNestedFields: [[1 : "value1", 2 : "value2", 3 : "value3"]], additional_id: "additional_id", token: "Token", localeIdentifier: "en", customLocale: customLocaleDictionary, presentIn: self, isSaveTokensInUserDefaults: true, isPresentDefaultControllers: true, connectionStatus: { success, error in

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
| CompanyID\* | String | Идентификатор компании. Как найти описано в [документации](https://docs.usedesk.ru/article/61) |
| ChanelId\* | String | Идентификатор канала (добавлен  в v1.1.5). Как найти описано в [документации](https://docs.usedesk.ru/article/10167) |
| UrlAPI\* | String | Адрес API. Стандартное значение `secure.usedesk.ru/uapi` |
| API Token\* | String | Личный API ключ |
| Url\* | String | Адрес сервера в формате - pubsubsec.usedesk.ru |
| Knowledge Base ID | String | Идентификатор базы знаний. Если не указан, база знаний не используется |
| Email | String | Почта клиента |
| Phone | String | Телефон клиента |
| UrlToSendFile | String | Адрес для отправки файлов. Стандартное значение `https://secure.usedesk.ru/uapi/v1/send_file`  |
| Port | String | Порт сервера  |
| Name | String | Имя клиента |
| NameOperator | String | Имя оператора |
| NameChat | String | Имя чата. Отображается в шапке |
| FirstMessage | String | Автоматическое сообщение. Отправиться сразу после иницилизации от имени клиента |
| Note | String | Текст заметки |
| AdditionalFields | [Int : String] | Массив дополнительный полей в формате - id : "значение". Для текстовых полей значение - строка, для списка - строка с точно совпадающим значением списка, для флага - строка "false" или "true" |
| AdditionalNestedFields | [[Int : String]] | Массив допл полей типа вложенный список. Каждый подмассив представляет один вложенный список. Формат фложенного списка - [id1: "значение", id2 : "значение", id3 : "значение"], где id1, id2, id3 идентификаторы значений по уровням вложенности |
| AdditionalId | String | Дополнительный идентификатор клиента |
| Token | String | Подпись, однозначно идентифицирующая пользователя и его чат на любых устройствах для сохранения истории переписки. (генерирует наша система,  ограничение не меньше 64 символа) |
| isSaveTokensInUserDefaults | Bool | Сохранять ли токен юзера ("Token", смотреть выше) в UserDefaults приложения. При занчении "True" позволяет не хранить токены в ваших системах, но он будет храниться только в текущем устройстве. Для доступа к переписке клиента с других устройств и платформ необходимо хранить токен в вашей системе и передавать его при инициализации. В этом случае значение параметра должно быть "False" |
| isUseBase | Bool | Начиная с версии 0.3.19 не используется |
| Signature | String | Начиная с версии 2.0.0 не используется |

\* - обязательный параметр

#### Пример:
```swift
let usedesk = UseDeskSDK()
usedesk.startWithoutGUICompanyID(companyID: "1234567", chanelId: "1234", knowledgeBaseID: "1", api_token: "143ed59g90ef093s", email: "lolo@yandex.ru", phone: "89000000000", url: "pubsubsec.usedesk.ru", urlToSendFile: "https://secure.usedesk.ru/uapi/v1/send_file", port: "213", name: "Name", operatorName: "NameOperator", nameChat: "NameChat", firstMessage: "message", note: "Note text", additionalFields: [1 : "value"], additionalNestedFields: [[1 : "value1", 2 : "value2", 3 : "value3"]], additional_id: "additional_id", token: "Token", isSaveTokensInUserDefaults: true, connectionStatus: { (success, error) in

})
```

### Блок возвращает следующие параметры:

#### СonnectionStatus:

| Тип | Описание |
| ------------- | ------------- |
| Bool | Успешность подключения к чату |
| UDFeedbackStatus | Статус показа формы обратной связи |
| String | Токен пользователя |

#### ErrorStatus:

| Тип | Описание |
| ------------- | ------------- |
| UDError | Задокументированый тип ошибки |
| UDFeedbackStatus | Описание ошибки |


# Документация:

Документация находится по адресу - http://sdk.usedocs.ru/

## Author

Сергей, kon.sergius@gmail.com

Максим, ixotdog@gmail.com

## License

UseDesk_SDK_Swift is available under the MIT license. See the LICENSE file for more info.

