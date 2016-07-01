//
//  Constants.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 30/06/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import Foundation

extension BaseClient {
    
    struct VimeoAPI {
        static let ClientIdentifier = ""
        static let ClientSecrets = ""
        static let AuthorizeUrl = "https://api.vimeo.com/oauth/authorize"
        static let BaseUrl = "https://api.vimeo.com/"
        static let AccessTokenUrl = "https://api.vimeo.com/oauth/access_token"
        static let UnauthorizedAccessTokenUrl = "https://api.vimeo.com/oauth/authorize/client"
        static let VimeoTokenGrantType = "client_credentials"
    }
    
    struct Constants {
        
    }
    
    struct Keys {
        
        // Vimeo 
        static let VimeoGrantType = "grant_type"
        static let VimeoAccessToken = "access_token"
    }
    
    struct Methods {
        static let CategoriesMethod = "categories"
    }
}