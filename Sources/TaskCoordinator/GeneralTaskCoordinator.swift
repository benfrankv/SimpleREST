//
//  GeneralTaskCoordinator.swift
//  HDS - EB
//
//  Created by Ben Frank V. on 24/03/24.
//

import Foundation

public class GeneralTaskCoordinator: GeneralTaskCoordinatorProtocol{
    public var urlBase: String = ""
    public var urlPath: String = ""
    public var params: [URLQueryItem] = []
    public var queryValue: String = ""
    
    public var session: URLSessionProtocol
    
    public init(session: URLSessionProtocol) {
        self.session = session
    }
    
    public func get<T: Decodable>(callback: @escaping (Result<T,Error>) -> Void) {
        
        let urlString: String = "\(urlBase)\(urlPath)"
        
        guard let url = addQueryParams(url: URL(string: urlString), newParams: params) else {return}
        
        let finalURL = URLRequest(url: url)
        print("URL to Request: \(finalURL)")
        DispatchQueue.global().async {
            let task = self.session.performDataTask(with: finalURL) { (data, response, error) in

                if let error: Error = error {
                    callback(.failure(error))
                    return
                }

                guard let data: Data = data else {
                    callback(.failure(ServiceError.noData))
                    return
                }

                guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                    callback(.failure(ServiceError.response))
                    return
                }

                guard (200 ... 299) ~= response.statusCode else {
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    callback(.failure(ServiceError.internalServer))
                    return
                }

                do {
                    let debugJSONPrinteable = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
                    print(debugJSONPrinteable)
                    let decodedData: T = try JSONDecoder().decode(T.self, from: data)
                    callback(.success(decodedData))
                } catch {
                    callback(.failure(ServiceError.parsingData))
                }
            }
            task.resume()
        }
        
    }
    
    public func fetchImageData(posterBasePath: String, posterPath: String, completion: @escaping (Data?) -> Void) {
        
        let urlString = posterBasePath + posterPath
        
        guard let url = URL(string: urlString) else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in

            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }
    
    public func addQueryParams(url: URL?, newParams: [URLQueryItem]) -> URL? {
        guard let url = url else {return nil}
        let urlComponents = NSURLComponents.init(url: url , resolvingAgainstBaseURL: false)
        guard urlComponents != nil else { return nil; }
        if (urlComponents?.queryItems == nil) {
            urlComponents!.queryItems = [];
        }
        urlComponents!.queryItems!.append(contentsOf: newParams);
        return urlComponents?.url;
    }
    
    public func makeQuery(name: String, value: String){
        params.append(URLQueryItem(name: name, value: value))
    }
}
