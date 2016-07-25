//
//  BaseClient.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 30/06/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import UIKit

class BaseClient: NSObject {
    
    typealias CompletionHandlerType = (Result) -> Void
    
    enum Result {
        case Success(AnyObject?)
        case Failure(NSError)
    }
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    class func sharedInstance() -> BaseClient {
        struct Singleton {
            static var sharedInstance = BaseClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // HTTP GET request
    func fetch(urlString: String, parameters: [String:AnyObject], headers: [String:String]?, completionHandler: CompletionHandlerType) -> NSURLSessionDataTask {
        
        let url = NSURL(string: urlString + BaseClient.escapedParameters(parameters))
        let request = NSMutableURLRequest(URL: url!)
        
        if let headers = headers {
            for (key,value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            self.handleResponse(request, data: data, response: response, error: error, completionHandler: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    func post(urlString:String, parameters: [String:AnyObject], headers: [String:AnyObject]?, completionHandler: CompletionHandlerType) -> NSURLSessionTask {
        
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        if let headers = headers {
            for (key,value) in headers {
                request.setValue(value as? String, forHTTPHeaderField: key)
            }
        }
        
        if let jsonData = try? NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted) {
            request.HTTPBody = jsonData
        } else {
            print("error sending params as JSON, params: \(parameters)")
        }
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            self.handleResponse(request, data: data, response: response, error: error, completionHandler: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    // Response handler, parses JSON response, checks status code, and calls the completion handler
    private func handleResponse(request:NSURLRequest, data:NSData?, response:NSURLResponse?, error:NSError?, completionHandler:CompletionHandlerType) -> Void {
        
        print(response)
        guard (error == nil) else {
            completionHandler(Result.Failure(error!))
            return
        }
        
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            var errorString = ""
            if let response = response as? NSHTTPURLResponse {
                
                switch response.statusCode {
                case 401, 403:
                    errorString = "Your login details are incorrect, Please try again"
                    break;
                default:
                    errorString = "Your request returned an invalid response! Status code: \(response.statusCode)!"
                    break;
                }
                
            } else if let response = response {
                errorString = "Your request returned an invalid response! Response: \(response)!"
            } else {
                errorString = "Your request returned an invalid response!"
            }
            
            completionHandler(Result.Failure(NSError(domain: "BaseClient:fetch", code: 0, userInfo: [NSLocalizedDescriptionKey: errorString])))
            return
        }
        
        guard let data = data else {
            completionHandler(Result.Failure(NSError(domain: "BaseClient:fetch", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data returned from request"])))
            return
        }
        
        BaseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        
    }
    
    func getImage(urlString:String, completionHandler:(success:Bool, image:UIImage?, errorDescription:String?) -> Void) -> Void {
        
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        if let image = BaseClient.Caches.imageCache.imageWithIdentifier(urlString) {
            completionHandler(success: true, image: image, errorDescription: nil)
            return
        }
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard let data = data where error == nil else {
                completionHandler(success: false,image: nil, errorDescription: error?.localizedDescription)
                return
            }
            
            if let image = UIImage(data: data) {
                BaseClient.Caches.imageCache.storeImage(image, withIdentifier: urlString)
                completionHandler(success: true, image: image, errorDescription: nil)
            } else {
                completionHandler(success: false, image: nil, errorDescription: "Could not convert returned data into image object")
            }
        }
        
        task.resume()
        
    }
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHandlerType) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandler(Result.Failure(NSError(domain: "BaseClient:parseJson", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to parse JSON: \(String(data))"])))
        }
        
        completionHandler(Result.Success(parsedResult))
    }
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}
