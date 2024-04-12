//
//  VideoViewController.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 19/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import UIKit
import WebKit
import CoreData

class VideoViewController: UIViewController {
    
    var video: Video!
    
    @IBOutlet weak var favouriteVideoButton: UIBarButtonItem!
    
    // MARK: UI Components
    var webView: WKWebView!
    
    // MARK: Convenience Properties
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.shared.managedObjectContext
    }()
    
    // MARK: VC Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        setupConstraints()
        
        if let videoBodyView = Bundle.main.loadNibNamed("VideoBodyView", owner: self, options: nil)?.first as? VideoBodyView {
            view.addSubview(videoBodyView)
            videoBodyView.setVideoContent(video: video)
            videoBodyView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                videoBodyView.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 4),
                videoBodyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
                videoBodyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
            ])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if video.isFavourite.boolValue {
            setFavourite()
        }
    }
    
    // MARK: Actions
    @IBAction func bookmarkVideo(_ sender: UIBarButtonItem) {
        if video.isFavourite.boolValue {
            unsetFavourite()
        } else {
            setFavourite()
        }
        
        do {
            try sharedContext.save()
        } catch let error {
            title = "An error occurred"
            print("*** ERROR Occurred: VideoViewController::bookmarkVideo: \(error)")
        }
    }
    
    private func setFavourite() {
        favouriteVideoButton.image = UIImage(named: "Like-Filled")
        favouriteVideoButton.tintColor = .red
        video.isFavourite = true
    }
    
    private func unsetFavourite() {
        favouriteVideoButton.image = UIImage(named: "Like")
        favouriteVideoButton.tintColor = nil
        video.isFavourite = false
    }
    
    // MARK: Private functions
    private func setupWebView() {
        let source = "var meta = document.createElement('meta');meta.name = 'viewport';meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';var head = document.getElementsByTagName('head')[0];head.appendChild(meta);"
        
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(script)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.backgroundColor = .black
        
        view.addSubview(webView)
        
        let html = video.embedCode.appending("<style>iframe { width: 100% !important; height: 100% !important; } body { margin: 0; background-color:black; }</style>")
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    private func setupConstraints() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9.0 / 16.0)
        ])
    }
}
