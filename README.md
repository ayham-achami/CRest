# CRest

[![Platforms](https://img.shields.io/badge/Platform-iOS-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-iOS-Green?style=flat-square)
[![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg)](https://swift.org)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

## Требования

- iOS 11+
- Swift 5.0

## Установка

### Cocoapods

Чтобы установить CRest, добавьте следующую строку в свой Podfile:

```ruby
pod 'CRest'
```

### Swift Package Manager

В XCode добавьте пакет - File> Swift Packages> Add Package Dependency.

```swift
dependencies: [
    .package(name: "CRest", url: "https://github.com/ayham-achami/CRest.git", .upToNextMajor(from: "1.0.0"))
]
```

___

## Обработка файлов по записям

Для `ChunkedStreamMultipartParameter` адаптер должен реализовать `adapt(_:chunkSize:completion:)`
и вернуть `BodyStream`: ещё не открытый поток с точной длиной данных после адаптации.
Multipart-кодировщик открывает и закрывает поток; повторная адаптация требует нового потока.
Если поток не подготовлен, запрос завершается с `ChunkedStreamMultipartParameter.StreamError.streamNotFound`
до отправки; исходный файл вместо потока не подставляется.

Для `.chunkedBody(chunkSize:expectedSize:)` сериализатор должен реализовать файловый
`serialize(_:_:_:_:_:)`, проверить размер исходных данных и сохранить результат по исходному URL.
Обе новые реализации по умолчанию возвращают ошибку `NetworkError.io`.

## Компоненты

- [📁 Sources](#📁-Sources)
  - [📁 Errors](#📁-Errors)
    - [📝 NetworkError](#networkerror)
    - [📝 BuildingError](#buildingerror)
    - [📝 SerializationError](#serializationerror)
  - [📁 Logging](#logging)
    - [📝 LogProtocols](#logprotocols)
    - [📝 NetworkInformant](#networkinformant)
  - [📁 Alamofire](#alamofire)
    - [📝 AF+Trust](#af+trust)
    - [📝 AF+Error](#af+error)
    - [📝 AF+Extensions](#af+extensions)
    - [📝 AF+Interceptor](#af+interceptor)
    - [📝 AF+Reachability](#af+reachability)
    - [📝 AF+DynamicRequest](#af+dynamicrequest)
  - [📁 Observing](#observing)
    - [📝 Observer](#observer)
    - [📝 Invocation](#invocation)
    - [📝 ObserverSource](#observersource)
    - [📝 ObserverProtocol](#observerprotocol)  
    - [📝 ProgressObserver](#progressobserver)
    - [📝 ProgressController](#progresscontroller)
  - [📁 Networking](#networking)
    - [📝 Models](#models)
    - [📝 UIImage](#uiimage)
    - [📝 Multipart](#multipart)
    - [📁 Http](#http)
      - [📝 Http](#http)
      - [📝 DynamicURL](#dynamicurl)
      - [📝 RestInterceptor](#restinterceptor)
      - [📝 TrustEvaluating](#trustevaluating)
      - [📝 DynamicHeaders](#dynamicheaders)
      - [📝 DynamicRequest](#dynamicrequest)
      - [📝 DynamicResponse](#dynamicresponse)
      - [📝 Request+EndPoint](#endpoint)
      - [📝 RestIOConfiguration](#restiioconfiguration)
  - [📁 Reachability](#reachability)
    - [📝 ReachabilityListener](#reachabilitlistener)
  -[📁 Async](#async)
    - [📝 AsyncRestIO](#asyncrestio)
    - [📝 AsyncAlamofireRestIO](#asyncalamofirerestio)
  - [📁 Combine](#combine)
    - [📝 AF+Combine](#af+combine)  
    - [📝 ProgressPublisher](#progresspublisher)
    - [📝 CombineRestIO](#combinerestio)
    - [📝 CombineAlamofireRestIO](#combinealamofirerestio)

___

> ### 📁 Errors

#### NetworkError

Ошибки сервера

#### BuildingError

Ошибка инициализации объекта моделей через билдер

#### SerializationError

Ошибка сериализации объекта

> ### 📁 Logging

#### LogProtocols

Различные протоколы, необходимые для логгирования

#### NetworkInformant

Объект, реализующий логирование сетевого клиента

> ### 📁 Alamofire

#### AF+Trust

Объект, выполняющий различные проверки. Например, проверку сертификата или публичных ключей.

#### AF+Error

Конвертирует ошибки `AFError` в `NetworkError`.

#### AF+Extensions

Содержит различные расширения для запросов с использованием `Alamofire`. Например, запрос на скачивание.

#### AF+Interceptor

Обеспечивает функциональность контроля запроса.

#### AF+Reachability

Прослушивает изменения состояния сети.

#### AF+DynamicRequest

Содержит различные расширения для HTTP.

> ### 📁 Observing

#### Observer

Наблюдатель

#### Invocation

Представляет собой исполняемый объект

#### ObserverSource

Представляет собой источник контроля

#### ObserverProtocol

Протокол и расширение наблюдателя

#### ProgressObserver

Наблюдатель прогресса скачивания

#### ProgressController

Контроль прогресса скачивания

> ### 📁 Networking

#### Models

Содержит различные модели для запроса

#### UIImage

Расширения для изображения для сериализации в байты

#### Multipart

Содержит мультипартпараметр, содержащий любые данные

> ### 📁 Http

#### Http

Содержит HTTP-namespace

#### DynamicURL

Содержит динамическую рестовую ссылку

#### RestInterceptor

Наблюдатель запроса

#### TrustEvaluating

Логика оценки доверия

#### DynamicHeaders

Содержит HTTP-заголовки

#### DynamicRequest

Содержит динамический HTTP-запрос

#### DynamicResponse

Содержит динамический ответ на HTTP-запрос

#### Request+EndPoint

Содержит базовую ссылку на бэкенд, endpoint, рестовый запрос

#### RestIOConfiguration

Общие настройки REST клиента

> ### 📁 Reachability

#### ReachabilityListener

> ### Async

### AsyncRestIO

Протокол для HTTP-клиента с использованием `async/await`
### AsyncAlamofireRestIO

Имплементация RestIO с Alamofire и async/await

> ### 📁 Combine

### AF+Combine

Расширения Alamofire для работы с `Combine`

### ProgressPublisher

Publisher прогресса

### CombineRestIO

Протокол для HTTP-клиента с использованием `Combine`
### CombineAlamofireRestIO

Имплементация RestIO с Alamofire и Combine

Представляеит собой наблюдателя за состоянием сети
