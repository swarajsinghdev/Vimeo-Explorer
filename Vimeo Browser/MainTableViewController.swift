//
//  MainTableViewController.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 10/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import UIKit
import CoreData
import UIKit
import CoreData

class MainTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    var selectedVideo: Video?
    
    // MARK: Core Data Helpers
    lazy var fetchedResultsController: NSFetchedResultsController<Video> = {
        
        let fetch = NSFetchRequest<Video>(entityName: "Video")
        let sort = NSSortDescriptor(key: "createdTime", ascending: false)
        fetch.sortDescriptors = [sort]
        fetch.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: Convenience Properties
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.shared.managedObjectContext
    }()
    
    @objc func loadData() {
        
        DataManager.shared.loadData { success in
            
            if !success {
                print("Load data failed")
                
                self.displayQuickAlert(title: "ERROR!", message: "An error occurred when trying to connect to Vimeo. You will only be able to browse local data. Please restart your app to retry for the latest content")
            }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
           
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching the latest content")
        
        tableView.addSubview(refreshControl)
        
        loadData()
        
        tableView.register(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: VimeoClient.Constants.videoCellIdentifier)
        
        do {
            try self.fetchedResultsController.performFetch()
            self.tableView.reloadData()
        } catch let error {
            print("Fetch error in MainTableViewController: \(error)")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == VimeoClient.Constants.ShowVideoSegueIdentifier {
            
            if let vc = segue.destination as? VideoViewController, let video = selectedVideo {
                vc.video = video
            }
        }
    }
    
    @IBAction func refreshData(_ sender: UIBarButtonItem) {
        
        self.loadData()
    }
}

extension MainTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedVideo = fetchedResultsController.object(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: VimeoClient.Constants.ShowVideoSegueIdentifier, sender: self)
    }
}

extension MainTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let video = fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: VimeoClient.Constants.videoCellIdentifier) as! VideoCell
        cell.setVideoContent(video: video)
        
        return cell
    }
}

extension MainTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
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
