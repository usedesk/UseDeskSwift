# UseDesk_SDK_Swift

- [Образец](#образец)
- [Добавление библиотеки в проект](#добавление-библиотеки-в-проект)
- [Классы базы знаний](#классы-базы-знаний)
- [Методы базы знаний](#методы-базы-знаний)
- [Методы чата](#методы-чата)
- [CallBack](#CallBack)

# Образец
Чтобы запустить пример проекта, клонируйте репозиторий и сначала запустите `pod install` из каталога примера.

## Тестовое приложение

Для запуска тестового приложения нужно:

-Клонировать репозиторий

-Запустить терминал

-Перейти в скаченную дирректорию (в папку Example)

-Выполнить команду `pod install`

## Скриншоты Тестового приложения
<a href="https://imgur.com/qVKFEi2"><img src="https://i.imgur.com/qVKFEi2.png?1" title="source: imgur.com" /></a>
<a href="https://imgur.com/BmvNVGc"><img src="https://i.imgur.com/BmvNVGc.png?1" title="source: imgur.com" /></a>

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
| Email | String | почта клиента |
| URL | String | адрес сервера с номером порта |
| Account ID | String | идентификатор аккаунта |
| API Token | String | личный API ключ |

### Блок возвращает следующие параметры:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Success | Bool | статус подключения к серверу |
| Error | String | описание ошибки при неудачном подключении |

#### Пример:
``` swift
let usedesk = UseDeskSDK()
usedesk.start(withCompanyID: "1234567", account_id: "1", api_token: "143ed59g90ef093s", email: "lolo@yandex.ru", url: "https:dev.company.ru", port: "213", connectionStatus: { success, error in

})
```

## Подключение SDK без графического интерфейса

- Подключаем библиотеку import UseDesk

- Выполняем операцию инициализации чата параметрами без GUI:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| CompanyID | String | идентификатор компании |
| Email | String | почта клиента |
| URL | String | адрес сервера |
| Port | String | порт сервера |
| Account ID | String | идентификатор аккаунта |
| API Token | String | личный API ключ |

#### Пример:
```swift
let usedesk = UseDeskSDK()
usedesk.startWithoutGUICompanyID(companyID: "1234567", account_id: "1", api_token: "143ed59g90ef093s", email: "lolo@yandex.ru", url: "https:dev.company.ru", port: "213", connectionStatus: { (success, error) in

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
usedesk.getArticle(articleID: 1, connectionStatus baseBlock: @escaping UDSArticleBlock)
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
| order | OrderArticle (.asc .desc) | Порядок сортировки по параметру sort. по умолчанию: asc
Варианты: asc - по возрастанию, desc - по убыванию |


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

## Отправка тестового сообщения:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Message | String | тест сообщения |


#### Пример:
```swift
usedesk.sendMessage("привет как дела?")
```

## Отправка тестового сообщения с вложением:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Message | String | тест сообщения |
| FileName | String | имя файла |
| fileType | String | тип файла (MIMO) |
| contentBase64 | Base64 | данные |

#### Пример:

```swift
usedesk.sendMessage(text, withFileName: "file", fileType: "image/png", contentBase64: content)
```

## Отправка оффлайн формы на сервер:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Message | String | тест сообщения |
| URL | String | адрес отправки |


#### Пример:
```swift
usedesk.sendMessage(withMessage: "привет", url: "https:dev.cany.ru"){ (success, error) in
}
```

#### Блок возвращает следующие параметры:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Success | Bool | статус отправки |
| Error | String | тип ошибки |

# CallBack – уведомления о действиях

### Статус соединия:

#### Пример:

```swift
self.usedesk.connectBlock = (success, error){
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
| Error | String | тип ошибки |


#### Пример:

```swift
self.usedesk.newMessageBlock = (success, message){
}
```


### Статус соединия:

```swift
self.usedesk.errorBlock = (errors){
    if(errors.count > 0) {
        hudErrorConnection.label.text = errors[0]
        hudErrorConnection.showAnimated = true
    }
}
```

- Операторы завершили разговор

#### Блок возвращает следующие параметры:

| Переменная  | Тип | Описание |
| -------------| ------------- | ------------- |
| Message | RCMessage | сообщение с type 4 – пользователь завершил разговор |


#### Пример:

```swift
self.usedesk.feedbackMessageBlock = (message){
}
```

## Author

Сергей, kon.sergius@gmail.com
Максим, ixotdog@gmail.com

## License

UseDesk_SDK_Swift is available under the MIT license. See the LICENSE file for more info.

