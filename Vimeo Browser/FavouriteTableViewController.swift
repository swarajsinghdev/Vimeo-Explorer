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
    var selectedVideo: Video?
    
    // MARK: Core Data Helpers
    lazy var fetchedResultsController: NSFetchedResultsController<Video> = {
        
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest() as! NSFetchRequest<Video>
        let sortDescriptor = NSSortDescriptor(key: "createdTime", ascending: false)
        let predicate = NSPredicate(format: "isFavourite == %@", NSNumber(value: true))
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 25
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: Convenience Properties
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.shared.managedObjectContext
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        
        tableView.register(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: VimeoClient.Constants.videoCellIdentifier)
        
        do {
            try self.fetchedResultsController.performFetch()
            self.tableView.reloadData()
        } catch let error {
            print("Fetch error in MainTableViewController: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == VimeoClient.Constants.ShowFavouriteVideoSegueIdentifier {
            
            if let vc = segue.destination as? VideoViewController, let video = selectedVideo {
                vc.video = video
            }
        }
    }
}

extension FavouriteTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedVideo = fetchedResultsController.object(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: VimeoClient.Constants.ShowFavouriteVideoSegueIdentifier, sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension FavouriteTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let video = fetchedResultsController.object(at: indexPath)
            video.isFavourite = NSNumber(value: false)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let video = fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: VimeoClient.Constants.videoCellIdentifier) as! VideoCell
        cell.setVideoContent(video: video)
        
        return cell
    }
}

extension FavouriteTableViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        default:
            break
        }
    }
}
