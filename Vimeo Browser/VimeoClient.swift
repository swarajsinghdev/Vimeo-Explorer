//
//  VimeoClient.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 30/06/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import Foundation

class VimeoClient: BaseClient {
    
    var authenticated = false
    var accessToken: String?
    
    override class func sharedInstance() -> VimeoClient {
        struct Singleton {
            static let sharedInstance = VimeoClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // Reference used for base64 encoding: http://stackoverflow.com/questions/29365145/how-to-encode-string-to-base64-in-swift
    lazy private var getDefaultHeaders: [String: String] = {
        var baseString = "\(VimeoAPI.ClientIdentifier):\(VimeoAPI.ClientSecrets)".data(using: .utf8)!
        
        let base64EncodedString = baseString.base64EncodedString(options: [])
        
        var headers = [String: String]()
        headers["Content-Type"] = "application/json"
        
        if VimeoClient.sharedInstance().authenticated {
            if let accessToken = self.accessToken {
                headers["Authorization"] = "Bearer \(accessToken)"
            }
        } else {
            headers["Authorization"] = "Basic \(base64EncodedString)"
        }
        
        return headers
    }()
    
    func authenticate(completionHandler: @escaping (Bool, Error?) -> Void) {
        
        if authenticated {
            completionHandler(true, nil)
            return
        }
        
        let params = [
            Keys.VimeoGrantType: VimeoAPI.VimeoTokenGrantType
        ]
        
        let task = VimeoClient.sharedInstance().post(urlString: VimeoAPI.UnauthorizedAccessTokenUrl, parameters: params, headers: getDefaultHeaders) { result in
            
            switch result {
            case .failure(let error):
                print("Authentication failed with error: \(error)")
                completionHandler(false, error)
                
            case .success(let res):
                guard let dict = res as? [String:Any],let accessToken = dict[Keys.VimeoAccessToken] as? String else {
                    print("No access token was found when authenticating")
                    completionHandler(false, nil)
                    return
                }
                
                self.authenticated = true
                self.accessToken = accessToken
                
                completionHandler(true, nil)
            }
        }
        
        task.resume()
    }
    
    func getCategories(completionHandler: @escaping CompletionHandlerType<Any>) {
        
        let urlString = "\(VimeoAPI.BaseUrl)\(Methods.CategoriesMethod)"
        
        let params = [
            "fields": "uri,name,link,resource_key,top_level,pictures"
        ]
        
        let task = VimeoClient.sharedInstance().fetch(urlString: urlString, parameters: params, headers: getDefaultHeaders) { result in
            
            switch result {
            case .failure(let error):
                print("Fetching categories failed with error: \(error)")
                completionHandler(result)
                
            case .success(let res):
                guard let dict = res as? [String:Any],let data = dict["data"] as? [[String: AnyObject]] else {
                    print("Category data not found")
                    completionHandler(.failure(NSError(domain: "VimeoClient:fetch", code: 0, userInfo: [NSLocalizedDescriptionKey: "Category data not found"])))
                    return
                }
                
                completionHandler(.success(data))
            }
        }
        task.resume()
    }
    
    func getVideosForCategory(category: Category, completionHandler: @escaping CompletionHandlerType<Any>) {
        
        let urlString = "\(VimeoAPI.BaseUrl)\(category.uri)/videos"
        
        let params = [
            "filter": "embeddable",
            "filter_embeddable": "true",
            "sort": "date",
            "direction": "desc",
            "fields": "resource_key,uri,link,name,width,height,embed.html,created_time,description,duration,stats.plays,user.name,pictures"
        ]
        
        let task = VimeoClient.sharedInstance().fetch(urlString: urlString, parameters: params, headers: getDefaultHeaders) { result in
            
            switch result {
            case .failure(let error):
                print("Fetching videos for category \(category.name) failed with error: \(error)")
                completionHandler(result)
                
            case .success(let res):
                guard let dict = res as? [String:Any], let data = dict["data"] as? [[String: AnyObject]] else {
                    print("No videos found in category \(category.name)")
                    completionHandler(.failure(NSError(domain: "VimeoClient:getVideosForCategory", code: 0, userInfo: [NSLocalizedDescriptionKey: "No videos found in category \(category.name)"])))
                    return
                }
                
                completionHandler(.success(data))
            }
        }
        task.resume()
    }
}
