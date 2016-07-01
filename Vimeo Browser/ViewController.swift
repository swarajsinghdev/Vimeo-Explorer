//
//  ViewController.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 30/06/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    // MARK: Convenience Properties
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        
        do {
            let result = try self.sharedContext.executeFetchRequest(fetchRequest)
            
            print(result)
            
        } catch let error {
            print(error)
        }
        
        VimeoClient.sharedInstance().authenticate() { success in
            print(VimeoClient.sharedInstance().accessToken)
            
            VimeoClient.sharedInstance().getCategories() { result in
                
                switch result {
                case .Success(let res):
                    
                    if let categories = res as? [[String:AnyObject]] {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let _ = categories.map() { (dictionary:[String:AnyObject]) -> Category in
                                let category = Category(dictionary: dictionary, context: self.sharedContext)
                                return category
                            }
                        }
                    }
                    
                case .Failure(let error):
                    print(error)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

