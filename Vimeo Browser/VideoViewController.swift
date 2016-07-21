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
    var webView:WKWebView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        setupWebView()
        setupConstraints()
        
        titleLabel.text = video.name
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        let html = video.embedCode.stringByAppendingString("<style>iframe { width: 100% !important; } </style>")
        webView.loadHTMLString(html, baseURL: nil)
    }

    func setupWebView() {
        
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
        //webView.navigationDelegate = self
        webView.scrollView.scrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.backgroundColor = UIColor.blackColor()
        
        view.addSubview(webView)
    }
    
    func setProperties() {
        
    }
    
    func setupConstraints() {
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 10).active = true
        NSLayoutConstraint(item: webView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: webView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 9.0 / 16.0, constant: 0).active = true
    }
}
