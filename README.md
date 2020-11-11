# UseDesk_SDK_Swift

- [Образец](#образец)
- [Добавление библиотеки в проект](#добавление-библиотеки-в-проект)
- [Классы базы знаний](#классы-базы-знаний)
- [Методы базы знаний](#методы-базы-знаний)
- [Методы чата](#методы-чата)
- [CallBack](#CallBack)
- [Кастомизация интерфейса](#Кастомизация-интерфейса)

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
| isUseBase | Bool | использовать базу знаний |
| Account ID | String | идентификатор базы знаний (опциональный) |
| UrlAPI | String | адрес  - devsecure.usedesk.ru/uapi|
| API Token | String | личный API ключ |
| Email | String | почта клиента |
| Phone | String | телефон клиента (опционально) |
| Url | String | адрес сервера в формате - dev.company.ru|
| Port | String | порт сервера |
| Name | String | имя клиента (опционально) |
| NameChat | String | имя чата (опционально). Отображается в шапке|
| FirstMessage | String | автоматическое сообщение (опционально). Отправиться сразу после иницилизации от имени клиента|
| PresentIn | UIViewController | в каком контроллере открывать (опционально)|

### Блок возвращает следующие параметры:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Success | Bool | статус подключения к серверу |
| Error | String | описание ошибки при неудачном подключении |

#### Пример c использованием базы знаний:
``` swift
let usedesk = UseDeskSDK()
usedesk.start(withCompanyID: "1234567", isUseBase: true, account_id: "1", api_token: "143ed59g90ef093s", email: "lolo@yandex.ru", phone: "89000000000", url: "dev.company.ru", port: "213", name: "Name", nameChat: "NameChat", firstMessage: "message", presentIn: self, connectionStatus: { success, error in

})
```

#### Пример без использования базы знаний:
``` swift
let usedesk = UseDeskSDK()
usedesk.start(withCompanyID: "1234567", isUseBase: false, api_token: "143ed59g90ef093s", email: "lolo@yandex.ru", phone: "89000000000", url: "dev.company.ru", port: "213", name: "Name", nameChat: "NameChat", firstMessage: "message",  connectionStatus: { success, error in

})
```

## Подключение SDK без графического интерфейса

- Подключаем библиотеку import UseDesk

- Выполняем операцию инициализации чата параметрами без GUI:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| CompanyID | String | идентификатор компании |
| isUseBase | Bool | использовать базу знаний |
| Account ID | String | идентификатор базы знаний (опциональный) |
| API Token | String | личный API ключ |
| Email | String | почта клиента |
| Phone | String | телефон клиента (опционально) |
| URL | String | адрес сервера адрес сервера в формате - dev.company.ru |
| Port | String | порт сервера |
| Name | String | имя клиента (опционально) |
| NameChat | String | имя чата (опционально). Отображается в шапке|
| FirstMessage | String | автоматическое сообщение (опционально). Отправиться сразу после иницилизации от имени клиента|

#### Пример:
```swift
let usedesk = UseDeskSDK()
usedesk.startWithoutGUICompanyID(companyID: "1234567", isUseBase: true, account_id: "1", api_token: "143ed59g90ef093s", email: "lolo@yandex.ru", phone: "89000000000", url: "dev.company.ru", port: "213", name: "Name", nameChat: "NameChat", firstMessage: "message", connectionStatus: { (success, error) in

})
```

### Блок возвращает следующие параметры:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Success | Bool| статус подключения к серверу |
| Error | String | описание ошибки при неудачном подключении |

Если тип ошибки noOperators то нет доступных операторов в данный момент времени

# Классы базы знаний:

### Класс раздела - BaseCollection :

| Свойство  | Тип | Описание |
| -------------| ------------- | ------------- |
| title | String | название раздела |
| id | Int | идентификатор раздела |
| open | Bool | публичный или закрытый раздел |
| image | String | адрес изображения раздела |
| сategories | [BaseCategory] | массив  категорий |

### Класс категории - BaseCategory :

| Свойство  | Тип | Описание |
| -------------| ------------- | ------------- |
| title | String | название категории |
| id | Int | идентификатор категории |
| open | Bool | публичная или закрытая категория |
| articlesTitles | [ArticleTitle] | массив названий статей |

### Класс названия статьи - ArticleTitle :

| Свойство  | Тип | Описание |
| -------------| ------------- | ------------- |
| title | String | название статьи |
| id | Int | идентификатор статьи |
| views | Int | количество просмотров статьи |

### Класс статьи - Article :

| Свойство  | Тип | Описание |
| -------------| ------------- | ------------- |
| title | String | название статьи |
| id | Int | идентификатор статьи |
| open | Bool | публичная или закрытая статья |
| text | String | тект статьи |
| category_id | Int | идентификатор категории статьи |
| collection_id | Int | идентификатор категории раздела |
| views | Int | количество просмотров статьи|
| created_at | String | дата создания статьи |

### Класс результата поиска статьи - SearchArticle :

| Свойство  | Тип | Описание |
| -------------| ------------- | ------------- |
| page | Int | страница |
| last_page | Int | количество страниц |
| count | Int | количество статей на страницу |
| total_count | Int | общее количество статей |
| articles | [Article] | массив статей |

# Методы базы знаний:

### Внимание: если при инициализации не был передан account_id или isUseBase указан false, следующие методы не будут работать. 

## Получение разделов базы знаний:

возвращает массив разделов - [BaseCollection]

#### Пример:
```swift
usedesk.getCollections(connectionStatus: {success, collections, error in
})
```
## Получение статьи:

возвращает класс статьи - Article

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| articleID | Int | идентификатор статьи |

#### Пример:
```swift
usedesk?.getArticle(articleID: id, connectionStatus: { success, article, error in
})
```
## Получение результатов поиска статьи:

возвращает класс результата поиска - SearchArticle

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| collection_ids | [Int] | id разделов через запятую |
| category_ids | [Int] | id категорий через запятую |
| article_ids | [Int] | id статей через запятую |
| count | Int | Количество статей на страницу (максимум: 100, по умолчанию: 20) |
| page | Int | Страница (по умолчанию 1) |
| query | String | Поисковая строка запроса, которая ищет по заголовку и тексту статьи |
| type | TypeArticle(.all .open .close) | выводятся все статьи. Если статья публичная, но находится в приватной категории, то при запросе с type=open она не выведется, т.к будет считаться приватной из-за родительской категории |
| sort | SortArticle (.id .title .category_id .public .created_at) | Параметр, по которому сортируются статьи |
| order | OrderArticle (.asc .desc) | Порядок сортировки по параметру sort. по умолчанию: asc Варианты: asc - по возрастанию, desc - по убыванию |


#### Пример:
```swift
usedesk.getSearchArticles(collection_ids: [collection_ids], category_ids: [category_ids], article_ids: [], query: searchText, type: .all, sort: .title, order: .asc) { (success, searchArticle, error) in
})
```

## Добавление просмотра статье:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| articleID | Int | идентификатор статьи |
| count | Int | количество просмотров |

#### Пример:
```swift
usedesk.addViewsArticle(articleID: id, count: 1, connectionStatus: { success, error in

})
```

# Методы чата

## Отправка сообщения:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Message | String | тест сообщения |


#### Пример:
```swift
usedesk.sendMessage("привет как дела?")
```

## Отправка сообщения с вложением:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Message | String | тест сообщения |
| FileName | String | имя файла |
| fileType | String | тип файла (MIMO) |
| contentBase64 | Base64 | данные |

Несколько файлов отправляются отдельными сообщениями

#### Пример:

```swift
usedesk.sendMessage(text, withFileName: "file", fileType: "image/png", contentBase64: content)
```

## Отправка оффлайн формы на сервер:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Message | String | тест сообщения |

#### Пример:
```swift
usedesk.sendOfflineForm(withMessage message: "привет") { (result, error) in

}
```

#### Блок возвращает следующие параметры:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Success | Bool | статус отправки |
| Error | String | тип ошибки |

## История сообщений в текущем чате:

История сообщений доступна после инициализации чата в параметре historyMess = [RCMessage]
RCMessage - объект хранящий всю информацию о сообщении

#### Пример:
```swift
usedesk.historyMess
```
### Максимальное количество прикрепленных файлов:

Можно изменять максимальное количество прикрепленных файлов с помощью переменной maxCountAssets

#### Пример:
```swift
usedesk.maxCountAssets = 5
```
# CallBack – уведомления о действиях

### Статус соединия:

#### Пример:

```swift
usedesk.connectBlock = { success, error in
}
```
#### Блок возвращает следующие параметры:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Success | Bool | статус соединения |
| Error | String | тип ошибки |


### Новое входящее сообщение:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| incoming | Bool | флаг входящего сообщения |
| outgoing | Bool | флаг исходящего сообщения |
| text | String | текст сообщения |
| picture_image | UIImage | изображение |
| rcButtons | [RCMessageButton] | массив объектов с параметрами кнопки |
| Error | String | тип ошибки |


#### Пример:

```swift
usedesk.newMessageBlock { success, message in
}
```

### Отправление оценки CSI:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| status | Bool | true - like, false - dislike |

#### Пример:

```swift
usedesk!.sendMessageFeedBack(true)
```

### Блок возвращающий ошибку соединения:

#### Пример:

```swift
usedesk.errorBlock = {errors in
}
```

### Конец сессии:

```swift
usedesk.releaseChat()
```

### Операторы завершили разговор

#### Блок возвращает следующие параметры:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Message | RCMessage | сообщение с type 4 – пользователь завершил разговор |


#### Пример:

```swift
usedesk.feedbackMessageBlock = { message in
}
```
## Настройки

#### Можно ограничить отправляемые клиентом типы контента, например запретить отправку видео или фото или и то и другое.
Для этого нужно выбрать значение переменной supportedAttachmentTypes в классе [Settings](https://github.com/usedesk/UseDeskSwift/blob/master/UseDesk/Classes/Settings.swift)

#### Можно скрыть аватар у входящих или исходящих сообщений. 
Для этого нужно задать соответствующее значение переменным avatarIncomingHidden (для входящих сообщений) и avatarOutgoingHidden (для исходящих сообщений) в классе [RCMessages](https://github.com/usedesk/UseDeskSwift/blob/master/UseDesk/Classes/RCMessages.swift) 

## Список ошибок 

### При работе с базой знаний:
| Код  | Ошибка | Описание |
| -------------| ------------- | ------------- |
| 111 | Server error | Ошибка на сервере |
| 112 | Invalid token | В запросе передан не правильный токен |
| 115 | Access error | Ошибка доступа |
| 121 | Request limits | Превышен лимит запросов |
| - | Could not connect to the server | Не удалось подключиться к серверу |

### При работе с чатом:
| Код  | Ошибка | Описание |
| -------------| ------------- | ------------- |
| 500 | Check server logs | Непредвиденная ошибка сервера |
| 403 | @@server/chat/INIT First | Не проведена инициализация |
| 400 | ID of company is not defined | Не передали company_id |
| 400 | Email is not defined | Не передали email |
| 400 | Data is not defined | Не передали data в set-действии |
| 400 | Message is not defined | Не передали message |
| 403 | Your token is fake | Передали несуществующий токен |

| Ошибка | Описание |
| ------------- | ------------- |
| emailError | Введен не корректный email |
| urlError | Введен не корректный параметр url |
| urlAPIError | Введен не корректный параметр urlAPI |
| phoneError | Введен не корректный номер телефона |

# Кастомизация интерфейса
Для кастомизации NavigationBar и SearchBar можно переопределить соответствующие переменные в классе [Settings](https://github.com/usedesk/UseDeskSwift/blob/master/UseDesk/Classes/Settings.swift)

Для кастомизации сообщений можно переопределить соответствующие переменные в классе [RCMessages](https://github.com/usedesk/UseDeskSwift/blob/master/UseDesk/Classes/RCMessages.swift)

Так же для таблицы чата, базы знаний и отдельных ячеек можете использовать файлы .xib расположенных в папке UseDesk_SDK_Swift/Resources/Classes

## Author

Сергей, kon.sergius@gmail.com

Максим, ixotdog@gmail.com

## License

UseDesk_SDK_Swift is available under the MIT license. See the LICENSE file for more info.

