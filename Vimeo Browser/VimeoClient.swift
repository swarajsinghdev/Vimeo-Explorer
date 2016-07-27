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
    var accessToken:String?
    
    override class func sharedInstance() -> VimeoClient {
        struct Singleton {
            static var sharedInstance = VimeoClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // reference used for base64 encoding: http://stackoverflow.com/questions/29365145/how-to-encode-string-to-base64-in-swift
    lazy private var getDefaultHeaders: [String:String] = {
       
        var baseString = "\(VimeoAPI.ClientIdentifier):\(VimeoAPI.ClientSecrets)".dataUsingEncoding(NSUTF8StringEncoding)!
        
        let base64EncodedString = baseString.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        var headers = [String:String]()
        headers["Content-Type"] = "application/json"
        
        if VimeoClient.sharedInstance().authenticated {
            headers["Authorization"] = "bearer \(VimeoClient.sharedInstance().accessToken)"
        } else {
            headers["Authorization"] = "basic \(base64EncodedString)"
        }
        
        return headers
    }()
    
    func authenticate(completionHandler: (success:Bool, error:NSError?) -> Void) {
        
        if authenticated {
            completionHandler(success: true, error: nil)
        }
        
        let params = [
            Keys.VimeoGrantType : VimeoAPI.VimeoTokenGrantType
        ]
        
        VimeoClient.sharedInstance().post(VimeoAPI.UnauthorizedAccessTokenUrl, parameters: params, headers: getDefaultHeaders) { result in
            
            switch result {
            case .Failure(let error):
                
                print("auth failed with error: \(error)")
                completionHandler(success: false, error: error)
            case.Success(let res):
                
                //print("Success: \(res)")
                
                guard let access_token = res![Keys.VimeoAccessToken] as? String else {
                    print("No access token was found when authenticating")
                    completionHandler(success: false, error: nil)
                    return
                }
                
                self.authenticated = true
                self.accessToken = access_token
                
                completionHandler(success: true, error: nil)
            }
        }
        
    }
    
    func getCategories(completionHandler: CompletionHandlerType) {
        
        let urlString = "\(VimeoAPI.BaseUrl)\(Methods.CategoriesMethod)"
        
        let params = [
            "fields": "uri,name,link,resource_key,top_level,pictures"
        ]
        
        VimeoClient.sharedInstance().fetch(urlString, parameters: params, headers: getDefaultHeaders) { result in
            
            switch result {
            case .Failure(let error):
                
                print("auth failed with error: \(error)")
                completionHandler(result)
                
            case .Success(let res):
                
                guard let data = res!["data"] as? [[String:AnyObject]] else {
                    print("category data not found")
                    completionHandler(.Failure(NSError(domain: "VimeoClient:fetch", code: 0, userInfo: [NSLocalizedDescriptionKey: "category data not found"])))
                    return
                }
                
                completionHandler(.Success(data))
            }
        }
    }
    
    func getVideosForCategory(category:Category, completionHandler: CompletionHandlerType) {
        
        let urlString = "\(VimeoAPI.BaseUrl)\(category.uri)/videos"
        
        let params = [
            "filter": "embeddable",
            "filter_embeddable": "true",
            "sort": "date",
            "direction": "desc",
            "fields": "resource_key,uri,link,name,width,height,embed.html,created_time,description,duration,stats.plays,user.name,pictures"
        ]
        
        VimeoClient.sharedInstance().fetch(urlString, parameters: params, headers: getDefaultHeaders) { result in
            
            switch result {
            case .Failure(let error):
                
                print("Get videos for category failure: \(error)")
                completionHandler(result)
            case .Success(let res):
                
                guard let data = res!["data"] as? [[String:AnyObject]] else {
                    completionHandler(.Failure(NSError(domain: "VimeoClient:getVideosForCategory", code: 0, userInfo: [NSLocalizedDescriptionKey: "no videos found in category \(category.name)"])))
                    return
                }
                
                completionHandler(.Success(data))
            }
        }
    }
    
}
