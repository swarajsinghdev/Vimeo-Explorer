//
//  FavouriteTableViewController.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 10/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import UIKit
import CoreData

class FavouriteTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetch = NSFetchRequest(entityName: "Video")
        let sort = NSSortDescriptor(key: "createdTime", ascending: false)
        let predicate = NSPredicate(format: "favourite = %@", true)
        fetch.sortDescriptors = [sort]
        fetch.predicate = predicate
        fetch.fetchBatchSize = 25
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: Convenience Properties
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
}

extension FavouriteTableViewController: UITableViewDelegate {
    
}

extension FavouriteTableViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return UITableViewCell(style: .Default, reuseIdentifier: "FavouriteCell")
    }
}

extension FavouriteTableViewController: NSFetchedResultsControllerDelegate {
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Insert:
            tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        default:
            break
        }
    }
}
