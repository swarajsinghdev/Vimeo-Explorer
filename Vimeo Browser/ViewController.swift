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
        
        DataManager.sharedInstance().loadData() { success in
            print("successfully loaded initial data")
            
            let fetchRequest = NSFetchRequest(entityName: "Video")
            
            do {
            let results = try self.sharedContext.executeFetchRequest(fetchRequest)
            
            print("\(results.count) found")
            } catch let error {
                print("\(error)")
            }
        }
    }

}

