//
//  APIClient.swift
//  Assignment_s
//
//  Created by Ajeet on 02/12/19.
//  . All rights reserved.
//

/*
 This class initiate HTTP calls, formation of all parameters, handling of result.
 */
import Foundation

struct Resource {
    let url: URL
    let method: String = "GET"
}

enum Result<T> {
    case success(T)
    case failure(Error)
}

enum APIHandlerError: Error {
    case noData
    case invalidDataFormat
}

extension URLRequest {
    
    init(_ resource: Resource) {
        self.init(url: resource.url)
        self.httpMethod = resource.method
    }
    
}

final class APIHandler {
    
    static let sharedInstance = APIHandler()
    
    /// Make private initializer
    private init(){}
    
    func load(_ resource: Resource, result: @escaping ((Result<Data>) -> Void)) {
        let request = URLRequest(resource)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let `data` = data else {
                result(.failure(APIHandlerError.noData))
                return
            }
            if let `error` = error {
                result(.failure(error))
                return
            }
            else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    result(.success(data))
                } else {
                    result(.failure(APIHandlerError.invalidDataFormat))
                }
            }
            result(.success(data))
        }
        task.resume()
    }
    
}
