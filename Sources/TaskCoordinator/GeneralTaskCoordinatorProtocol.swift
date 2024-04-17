//
//  GeneralTaskCoordinatorProtocol.swift
//  HDS - EB
//
//  Created by Ben Frank V. on 17/03/24.
//

import Foundation

//ServiceProtocols
public protocol GeneralTaskCoordinatorProtocol{
    var session: URLSessionProtocol { get }
    var urlBase: String {get}
    var urlPath: String {get set}
    func get<T: Decodable>(callback: @escaping (Result<T,Error>) -> Void)
    func makeQuery(name: String, value: String)
    func addQueryParams(url: URL?, newParams: [URLQueryItem]) -> URL?
    
}

public protocol URLSessionDataTaskProtocol {
    func resume()
}

public protocol URLSessionProtocol { typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    func performDataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}

//ServiceError
enum ServiceError: Error {
    case noData
    case response
    case parsingData
    case internalServer
}

//Services

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

extension URLSession: URLSessionProtocol {
    public func performDataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTaskProtocol
    }
}
