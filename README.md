# UseDesk_SDK_Swift

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

Библиотека UseDesk_SDK_Swift доступна через систему управления зависимостями [CocoaPods](http://cocoapods.org).

-Добавьте строчку в Podfile вашего приложения

```ruby
pod 'UseDesk_SDK_Swift'
```

-Выполните команду в терминале `pod update`

-Подключаем библиотеку import UseDesk`

### Выполняем операцию инициализации чата параметрами:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| CompanyID | String | идентификатор компании |
| UrlAPI | String | адрес  - devsecure.usedesk.ru/uapi |
| Knowledge Base ID | String | идентификатор базы знаний (опциональный). Если не указан, база знаний не используется |
| API Token | String | личный API ключ |
| Email | String | почта клиента (опционально) |
| Phone | String | телефон клиента (опционально) |
| Url | String | адрес сервера в формате - dev.company.ru |
| Port | String | порт сервера (опционально) |
| Name | String | имя клиента (опционально) |
| NameOperator | String | имя оператора (опционально) |
| NameChat | String | имя чата (опционально). Отображается в шапке |
| FirstMessage | String | автоматическое сообщение (опционально). Отправиться сразу после иницилизации от имени клиента |
| Note | String | текст заметки (опционально) |
| Signature | String | подпись, однозначно идентифицирующая пользователя и его чат на любых устройствах (опционально). Для сохранения истории переписки. Сигнатура должна быть уникальной для клиента-чата. Если клиент меняет имя, номер телефона или емэйл, то это не должно влиять на сигнатуру. Если сигнатура не указана, то будет всегда открываться один и тот же чат для конкретного приложения, пока оно не будет удалено. |
| PresentIn | UIViewController | в каком контроллере открывать (опционально) |

(Начиная с версии 0.3.19 параметр isUseBase не используется)

### Блок возвращает следующие параметры:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Success | Bool | статус подключения к серверу |
| Error | String | описание ошибки при неудачном подключении |

#### Пример c использованием базы знаний:
``` swift
let usedesk = UseDeskSDK()
usedesk.start(withCompanyID: "1234567", knowledgeBaseID: "1", api_token: "143ed59g90ef093s", email: "lolo@yandex.ru", phone: "89000000000", url: "dev.company.ru", port: "213", name: "Name", operatorName: "NameOperator", nameChat: "NameChat", firstMessage: "message", note: "Note text", signature: "SignatureString", presentIn: self, connectionStatus: { success, error in

})
```

#### Пример без использования базы знаний:
``` swift
let usedesk = UseDeskSDK()
usedesk.start(withCompanyID: "1234567", api_token: "143ed59g90ef093s", email: "lolo@yandex.ru", phone: "89000000000", url: "dev.company.ru", port: "213", name: "Name", operatorName: "NameOperator", nameChat: "NameChat", firstMessage: "message", note: "Note text", signature: "SignatureString", connectionStatus: { success, error in

})
```

## Подключение SDK без графического интерфейса

- Подключаем библиотеку import UseDesk

- Выполняем операцию инициализации чата параметрами без GUI:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| CompanyID | String | идентификатор компании |
| UrlAPI | String | адрес  - devsecure.usedesk.ru/uapi |
| Knowledge Base ID | String | идентификатор базы знаний (опциональный). Если не указан, база знаний не используется |
| API Token | String | личный API ключ |
| Email | String | почта клиента (опционально) |
| Phone | String | телефон клиента (опционально) |
| Url | String | адрес сервера в формате - dev.company.ru |
| Port | String | порт сервера (опционально) |
| Name | String | имя клиента (опционально) |
| NameOperator | String | имя оператора (опционально) |
| NameChat | String | имя чата (опционально). Отображается в шапке |
| FirstMessage | String | автоматическое сообщение (опционально). Отправиться сразу после иницилизации от имени клиента |
| Note | String | текст заметки (опционально) |
| Signature | String | подпись, однозначно идентифицирующая пользователя и его чат на любых устройствах (опционально). Для сохранения истории переписки. Сигнатура должна быть уникальной для клиента-чата. Если клиент меняет имя, номер телефона или емэйл, то это не должно влиять на сигнатуру |

(Начиная с версии 0.3.19 параметр isUseBase не используется)

#### Пример:
```swift
let usedesk = UseDeskSDK()
usedesk.startWithoutGUICompanyID(companyID: "1234567", knowledgeBaseID: "1", api_token: "143ed59g90ef093s", email: "lolo@yandex.ru", phone: "89000000000", url: "dev.company.ru", port: "213", name: "Name", operatorName: "NameOperator", nameChat: "NameChat", firstMessage: "message", note: "Note text", signature: "SignatureString", connectionStatus: { (success, error) in

})
```

### Блок возвращает следующие параметры:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Success | Bool| статус подключения к серверу |
| Error | String | описание ошибки при неудачном подключении |

Если тип ошибки noOperators то нет доступных операторов в данный момент времени


# Документация:

Документация находится по адресу - http://sdk.usedocs.com/

## Author

Сергей, kon.sergius@gmail.com

Максим, ixotdog@gmail.com

## License

UseDesk_SDK_Swift is available under the MIT license. See the LICENSE file for more info.

