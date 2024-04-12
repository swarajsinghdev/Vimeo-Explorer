//
//  BaseClient.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 30/06/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import UIKit

import UIKit

class BaseClient: NSObject {
    
    typealias CompletionHandlerType<T> = (Result<T>) -> Void
    
    enum Result<T> {
        case success(T)
        case failure(Error)
    }
    
    var session: URLSession
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    class func sharedInstance() -> BaseClient {
        struct Singleton {
            static let sharedInstance = BaseClient()
        }
        return Singleton.sharedInstance
    }
    
    // HTTP GET request
    func fetch(urlString: String, parameters: [String: Any], headers: [String: String]?, completionHandler: @escaping CompletionHandlerType<Any>) -> URLSessionDataTask {
        
        let url = URL(string: urlString + BaseClient.escapedParameters(parameters: parameters))
        var request = URLRequest(url: url!)
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        setActivityIndicatorState(active: true)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            self.setActivityIndicatorState(active: false)
            self.handleResponse(request: request, data: data, response: response, error: error, completionHandler: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    func post(urlString: String, parameters: [String: Any], headers: [String: String]?, completionHandler: @escaping CompletionHandlerType<Any>) -> URLSessionTask {
        
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) {
            request.httpBody = jsonData
        } else {
            print("Error sending params as JSON, params: \(parameters)")
        }
        
        setActivityIndicatorState(active: true)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            self.setActivityIndicatorState(active: false)
            self.handleResponse(request: request, data: data, response: response, error: error, completionHandler: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    private func httpResponseToDictionary(response: HTTPURLResponse) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["url"] = response.url?.absoluteString ?? ""
        dictionary["statusCode"] = response.statusCode
        dictionary["allHeaderFields"] = response.allHeaderFields
        return dictionary
    }
    
    // Function to log the request URL and HTTP body before API hit
    private func logRequest(request: URLRequest) {
        if let url = request.url {
            print("Request URL: \(url)")
        }
        if let body = request.httpBody{
            print("****** Request HTTP Body: ****** \n \(body.json)")
            print("****** Request HTTP Body: KEY VALUE ****** \n \(body.dictionary!.keyValueString)")
        }
    }

    // Function to log the HTTP response and data after API hit
    private func logResponse<T>(response: URLResponse?, data: Data?, error: Error?, completionHandler: @escaping CompletionHandlerType<T>) {
        // Log the HTTP response
        if let httpResponse = response as? HTTPURLResponse {
            let httpResponseDict = httpResponseToDictionary(response: httpResponse)
            print("****** HTTP Response: ****** \n \(httpResponseDict.json)")
        }
        
        // Log the response data
        if let responseData = data {
            print("****** Response Data: ****** \(responseData.json)")
        }
        
        // Check for errors and handle accordingly
        guard error == nil else {
            completionHandler(.failure(error!))
            return
        }
    }

    // Response handler, parses JSON response, checks status code, and calls the completion handler
    private func handleResponse<T>(request: URLRequest, data: Data?, response: URLResponse?, error: Error?, completionHandler: @escaping CompletionHandlerType<T>) {
        // Log the request URL and HTTP body before hitting the API
        logRequest(request: request)
        
        // Handle the HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            let errorString = "Your request returned an invalid response!"
            completionHandler(.failure(NSError(domain: "BaseClient:fetch", code: 0, userInfo: [NSLocalizedDescriptionKey: errorString])))
            return
        }
        
        // Check the status code of the HTTP response
        guard (200...299).contains(httpResponse.statusCode) else {
            var errorString = ""
            switch httpResponse.statusCode {
            case 401, 403:
                errorString = "Failed to connect to remote API. Possibly API details are not set"
            default:
                errorString = "Your request returned an invalid response! Status code: \(httpResponse.statusCode)!"
            }
            completionHandler(.failure(NSError(domain: "BaseClient:fetch", code: 0, userInfo: [NSLocalizedDescriptionKey: errorString])))
            return
        }
        
        // Log the HTTP response and data after API hit
        logResponse(response: response, data: data, error: error, completionHandler: completionHandler)
        
        // Check for data and parse JSON
        guard let responseData = data else {
            completionHandler(.failure(NSError(domain: "BaseClient:fetch", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data returned from request"])))
            return
        }
        
        // Parse JSON response
        BaseClient.parseJSONWithCompletionHandler(data: responseData, completionHandler: completionHandler)
    }

    
    func getImage(urlString: String, completionHandler: @escaping (Bool, UIImage?, String?) -> Void) {
        guard let url = URL(string: urlString) else {
            completionHandler(false, nil, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let image = BaseClient.Caches.imageCache.imageWithIdentifier(identifier: urlString) {
            completionHandler(true, image, nil)
            return
        }
        
        setActivityIndicatorState(active: true)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completionHandler(false, nil, error?.localizedDescription)
                return
            }
            
            guard let image = UIImage(data: data) else {
                completionHandler(false, nil, "Could not convert returned data into image object")
                return
            }
            
            completionHandler(true, image, nil)
            BaseClient.Caches.imageCache.storeImage(image: image, withIdentifier: urlString)
        }
        
        task.resume()
    }
    
    class func parseJSONWithCompletionHandler<T>(data: Data, completionHandler: CompletionHandlerType<T>) {
        do {
            let parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            completionHandler(.success(parsedResult as! T))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    class func escapedParameters(parameters: [String : Any]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            if let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                /* Append it */
                urlVars += [key + "=" + "\(escapedValue)"]
            }
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    // MARK: Activity Indicator
    
    func setActivityIndicatorState(active: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = active
        }
       
    }
}
