//  Assignment_s
//
//  Created by Ajeet on 02/12/19.
//  . All rights reserved.
//
import Foundation
/*
 This class contains all network call and data handling.
 */
final class NetworkManager {
    
    private let apiHandler: APIHandler!
    
    init(apiHandler: APIHandler) {
        self.apiHandler = apiHandler
    }
    
    /// Method to Hit API with Date_time and Date parameter
    func getPSIListForDateNTime(urlString: String, completion: @escaping ((Result<JsonForSwiftBase>) -> Void)) {
        
        let resource = Resource(url: URL(string: urlString)!)
        APIHandler.sharedInstance.load(resource) { (result) in
            switch result {
                
            case .success(let data):
                do {
                    let items = try JSONDecoder().decode(JsonForSwiftBase.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(items))
                    }
                }catch{
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
