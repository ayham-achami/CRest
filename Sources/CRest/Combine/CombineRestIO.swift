//
//  CombineRestIO.swift
//

#if canImport(Combine)
import Combine
import Foundation

/// Http клиент с использованием Combine
public protocol CombineRestIO: AnyObject {
    
    typealias Source = URL
    typealias Destination = URL
    typealias ProgressHandler = (Progress) -> Void
    
    /// Инициализация
    /// - Parameter configuration: Общие настройки REST клиента
    init(_ configuration: RestIOConfiguration)
    
    /// Выполняет REST http запроса
    /// - Parameters:
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    /// - Returns: ответ на запрос
    func perform<Response>(_ request: DynamicRequest,
                           response: Response.Type) -> AnyPublisher<Response, Error> where Response: CRest.Response
    
    /// Выполняет REST http запроса
    /// - Parameters:
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    /// - Returns: `DynamicResponse` c ответом на запрос
    func dynamicPerform<Response>(_ request: DynamicRequest,
                                  response: Response.Type) -> AnyPublisher<DynamicResponse<Response>, Error> where Response: CRest.Response
    
    /// Скачает данные и сохраняет их на диске
    /// - Parameters:
    ///   - destination: Куда сохранить
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    /// - Returns: ответ на запрос
    func download<Response>(into destination: Destination,
                            with request: DynamicRequest,
                            response: Response.Type) -> ProgressPublisher<Response> where Response: CRest.Response
    
    /// Выгружает данные на сервер из указанного источника
    /// - Parameters:
    ///   - source: Откуда брать данные
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    /// - Returns: ответ на запрос
    func upload<Response>(from source: Source,
                          with request: DynamicRequest,
                          response: Response.Type) -> ProgressPublisher<Response> where Response: CRest.Response
}

/// Протокол конфигурации общих запросов
public protocol CombineRestIOSendable {
    
    /// Получает данные из сервера по логике `APIResponse`
    /// - Parameters:
    ///   - request: Запрос
    ///   - parameters: Параметры запроса
    ///   - response: Тип ответа
    ///   - method: метод запроса `Http.Method`
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    func send<Response, Parameters>(for request: Request,
                                    parameters: Parameters?,
                                    response: Response.Type,
                                    method: Http.Method,
                                    encoding: Http.Encoding) -> AnyPublisher<Response, Error> where Response: CRest.Response, Parameters: CRest.Parameters
}

// MARK: - CombineRestIOSendable + Default
public extension CombineRestIOSendable {
    
    /// Отправить Get запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - parameters: Параметры запроса
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    func fetch<Response, Parameters>(for request: Request,
                                     parameters: Parameters = Empty.value,
                                     response: Response.Type = Empty.self,
                                     encoding: Http.Encoding) -> AnyPublisher<Response, Error> where Response: CRest.Response, Parameters: CRest.Parameters {
        send(for: request, parameters: parameters, response: response, method: .get, encoding: encoding)
    }
    
    /// Отправить Post запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - parameters: Параметры запроса
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    func submit<Response, Parameters>(for request: Request,
                                      parameters: Parameters = Empty.value,
                                      response: Response.Type = Empty.self,
                                      encoding: Http.Encoding = .JSON) -> AnyPublisher<Response, Error> where Response: CRest.Response, Parameters: CRest.Parameters {
        send(for: request, parameters: parameters, response: response, method: .post, encoding: encoding)
    }
    
    /// Отправить Put запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - parameters: Параметры запроса
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    func update<Response, Parameters>(for request: Request,
                                      parameters: Parameters = Empty.value,
                                      response: Response.Type = Empty.self,
                                      encoding: Http.Encoding = .JSON) -> AnyPublisher<Response, Error> where Response: CRest.Response, Parameters: CRest.Parameters {
        send(for: request, parameters: parameters, response: response, method: .put, encoding: encoding)
    }
    
    /// Отправить Patch запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - parameters: Параметры запроса
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    func change<Response, Parameters>(for request: Request,
                                      parameters: Parameters = Empty.value,
                                      response: Response.Type = Empty.self,
                                      encoding: Http.Encoding = .JSON) -> AnyPublisher<Response, Error> where Response: CRest.Response, Parameters: CRest.Parameters {
        send(for: request, parameters: parameters, response: response, method: .patch, encoding: encoding)
    }
    
    /// Отправить Delete запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - response: Тип ответа
    ///   - parameters: Параметры запроса
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    func delete<Response>(for request: Request,
                          parameters: Parameters = Empty.value,
                          response: Response.Type = Empty.self,
                          encoding: Http.Encoding = .URL(.default)) -> AnyPublisher<Response, Error> where Response: CRest.Response {
        send(for: request, parameters: parameters, response: response, method: .delete, encoding: encoding)
    }
    
    /// Отправить head запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - encoding: Енкоденг запроса `Http.Method`
    func prepare(for request: Request, encoding: Http.Encoding = .URL(.default)) -> AnyPublisher<Empty, Error> {
        send(for: request, parameters: Empty.value, response: Empty.self, method: .head, encoding: encoding)
    }
    
    /// Отправить Options запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    func setup<Response>(for request: Request,
                         response: Response.Type = Empty.self,
                         encoding: Http.Encoding = .URL(.default)) -> AnyPublisher<Response, Error> where Response: CRest.Response {
        send(for: request, parameters: Empty.value, response: response, method: .options, encoding: encoding)
    }
}

// MARK: - Publisher + Empty
public extension Publisher where Self.Output == Empty {
    
    /// Этот метод создает подписчика и немедленно запрашивает неограниченное количество значений перед возвратом подписчика.
    /// Возвращаемое значение должно сохраняться, иначе поток будет отменен.
    /// - Parameters:
    ///   - receiveCompletion: Замыкание, выполняемое по завершении.
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    /// - Returns: `AnyCancellable`
    func response(receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void), receiveValue: @escaping (() -> Void)) -> AnyCancellable {
        sink { completion in
            receiveCompletion(completion)
        } receiveValue: { _ in
            receiveValue()
        }
    }
}

// MARK: - Publisher + Response
public extension Publisher where Self.Output: CRest.Response {
    
    /// Этот метод создает подписчика и немедленно запрашивает неограниченное количество значений перед возвратом подписчика.
    /// Возвращаемое значение должно сохраняться, иначе поток будет отменен.
    /// - Parameter receiveValue: Замыкание, выполняемое при получении значения.
    /// - Returns: `AnyCancellable`
    func response(receiveValue: @escaping ((Result<Self.Output, Self.Failure>) -> Void)) -> AnyCancellable {
        sink { completion in
            guard case let .failure(error) = completion else { return }
            receiveValue(.failure(error))
        } receiveValue: { output in
            receiveValue(.success(output))
        }
    }
}
#endif
