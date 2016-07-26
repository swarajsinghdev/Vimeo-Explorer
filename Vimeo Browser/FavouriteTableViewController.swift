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
    var selectedVideo:Video?
    
    // MARK: Core Data Helpers
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetch = NSFetchRequest(entityName: "Video")
        let sort = NSSortDescriptor(key: "createdTime", ascending: false)
        let predicate = NSPredicate(format: "isFavourite = %@", NSNumber(bool: true))
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        
        tableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: VimeoClient.Constants.videoCellIdentifier)
        
        do {
            try self.fetchedResultsController.performFetch()
            self.tableView.reloadData()
        } catch let error {
            print("Fetch error in MainTableViewController: \(error)")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == VimeoClient.Constants.ShowFavouriteVideoSegueIdentifier {
            
            if let vc = segue.destinationViewController as? VideoViewController, let video = selectedVideo {
                vc.video = video
            }
        }
    }
}

extension FavouriteTableViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedVideo = (fetchedResultsController.objectAtIndexPath(indexPath) as! Video)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier(VimeoClient.Constants.ShowFavouriteVideoSegueIdentifier, sender: self)
    }
}

extension FavouriteTableViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let video = fetchedResultsController.objectAtIndexPath(indexPath) as! Video
        
        let cell = tableView.dequeueReusableCellWithIdentifier(VimeoClient.Constants.videoCellIdentifier) as! VideoCell
        cell.setVideoContent(video)
        
        return cell
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
