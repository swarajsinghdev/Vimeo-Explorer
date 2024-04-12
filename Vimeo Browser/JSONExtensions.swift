//
//  JSONExtensions.swift
//  Vimeo Browser
//
//  Created by Swarajmeet Singh on 11/04/24.
//  Copyright © 2024 Martin Kelly. All rights reserved.
//

import Foundation

extension Data {
    /// Convert the Data object to a JSON dictionary and print it.
    var json: String {
        do {
            if let jsonDict = try JSONSerialization.jsonObject(with: self, options: []) as? [String: Any] {
                return jsonDict.json
            } else {
                return "Invalid JSON format"
            }
        } catch {
            return "JSON serialization error: \(error.localizedDescription)"
        }
    }
    
    /// Convert the Data object to a JSON dictionary.
    var dictionary: [String: Any]? {
        do {
            if let jsonDict = try JSONSerialization.jsonObject(with: self, options: []) as? [String: Any] {
                return jsonDict
            } else {
                return nil
            }
        } catch let error as NSError {
            return ["error": error.localizedDescription]
        }
    }
    
    /// Decode the Data object into a Decodable type.
    func decode<T: Decodable>(_ type: T.Type = T.self, using decoder: JSONDecoder = JSONDecoder()) throws -> T {
        return try decoder.decode(T.self, from: self)
    }
}

extension Dictionary where Key == String {
    /// Convert the dictionary to a JSON string.
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: .utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    /// Convert the dictionary to a key-value string.
    var keyValueString: String {
        var keyValueString = ""
        for (key, value) in self {
            let keyValue = "\(key) : \(value)\n"
            keyValueString.append(keyValue)
        }
        return keyValueString
    }
}
