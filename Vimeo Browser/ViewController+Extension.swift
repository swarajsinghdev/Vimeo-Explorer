//
//  ViewController+Extension.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 26/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func displayQuickAlert(title: String, message: String) {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            alertVC.dismiss(animated: true, completion: nil)
        }))
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
       
    }
}

