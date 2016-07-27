//
//  ViewController+Extension.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 26/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func displayQuickAlert(title:String, message: String) {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        if let navVC = self.navigationController {
            navVC.presentViewController(alertVC, animated: true, completion: nil)
        }
        
    }
}
