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
    
    func authenticate(completionHandler: (success:Bool) -> Void) {
        
        if authenticated {
            completionHandler(success: true)
        }
        
        let params = [
            Keys.VimeoGrantType : VimeoAPI.VimeoTokenGrantType
        ]
        
        VimeoClient.sharedInstance().post(VimeoAPI.UnauthorizedAccessTokenUrl, parameters: params, headers: getDefaultHeaders) { result in
            
            switch result {
            case .Failure(let error):
                
                print("auth failed with error: \(error)")
                completionHandler(success: false)
            case.Success(let res):
                
                print("Success: \(res)")
                
                guard let access_token = res![Keys.VimeoAccessToken] as? String else {
                    print("No access token was found when authenticating")
                    completionHandler(success: false)
                    return
                }
                
                self.authenticated = true
                self.accessToken = access_token
                
                completionHandler(success: true)
            }
        }
        
    }
    
    func getCategories(completionHandler: CompletionHandlerType) {
        
        let urlString = "\(VimeoAPI.BaseUrl)\(Methods.CategoriesMethod)"
        
        VimeoClient.sharedInstance().fetch(urlString, parameters: [:], headers: getDefaultHeaders) { result in
            
            switch result {
            case .Failure(let error):
                
                print("auth failed with error: \(error)")
            case.Success(let res):
                
                guard let data = res!["data"] as? [[String:AnyObject]] else {
                    print("category data not found")
                    completionHandler(.Failure(NSError(domain: "VimeoClient:fetch", code: 0, userInfo: [NSLocalizedDescriptionKey: "category data not found"])))
                    return
                }
                
                completionHandler(.Success(data))
            }
        }
    }
    
}
