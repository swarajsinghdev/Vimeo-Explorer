//
//  VideoViewController.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 19/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import UIKit
import WebKit

class VideoViewController: UIViewController {
    
    var video:Video!
    
    // MARK: UI Components
    var webView:WKWebView!
    /**
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addComponents()
        setupWebView()
        setupConstraints()
        
        if let videoBodyView = NSBundle.mainBundle().loadNibNamed("VideoBodyView", owner: self, options: nil).first as? VideoBodyView {
            
            view.addSubview(videoBodyView)
            videoBodyView.setVideoContent(video)
            videoBodyView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint(item: videoBodyView, attribute: .Top, relatedBy: .Equal, toItem: webView, attribute: .Bottom, multiplier: 1.0, constant: 4).active = true
            NSLayoutConstraint(item: videoBodyView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 8).active = true
            NSLayoutConstraint(item: videoBodyView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 8).active = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    private func setupWebView() {
        
        let source: NSString = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"
        
        let script: WKUserScript = WKUserScript(source: source as String, injectionTime: .AtDocumentEnd, forMainFrameOnly: false)
        
        let userContentController: WKUserContentController = WKUserContentController()
        userContentController.addUserScript(script)
        
        let configuration: WKWebViewConfiguration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        webView = WKWebView(frame: CGRectZero, configuration: configuration)
        webView.scrollView.scrollEnabled = false
        webView.scrollView.bounces = false
        webView.backgroundColor = UIColor.blackColor()
        
        view.addSubview(webView)
        
        let html = video.embedCode.stringByAppendingString("<style>iframe { width: 100% !important; height: 100% !important; } body { margin: 0; background-color:black; }</style>")
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    private func addComponents() {
    
        /**
        titleLabel = UILabel()
        titleLabel.text = video.name.uppercaseString
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont(name: "Helvetica Neue", size: 14.0)
        view.addSubview(titleLabel)
        
        descriptionLabel = UILabel()
        descriptionLabel.text = "\(video.videoDescription!)".stringByReplacingOccurrencesOfString("\n", withString: " ")
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .ByWordWrapping
        descriptionLabel.font = UIFont(name: "Helvetica Neue", size: 12.0)
        descriptionLabel.sizeToFit()
        view.addSubview(descriptionLabel)
        */
    }
    
    private func setupConstraints() {
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .TopMargin, multiplier: 1.0, constant: 60).active = true
        NSLayoutConstraint(item: webView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: webView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 9.0 / 16.0, constant: 0).active = true
        /**
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: webView, attribute: .Bottom, multiplier: 1.0, constant: 8).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 8).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 8).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 20).active = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: descriptionLabel, attribute: .Top, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1.0, constant: 4).active = true
        NSLayoutConstraint(item: descriptionLabel, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 8).active = true
        NSLayoutConstraint(item: descriptionLabel, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 8).active = true
        */
    }
}
