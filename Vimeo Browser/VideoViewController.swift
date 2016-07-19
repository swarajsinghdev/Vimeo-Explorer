//
//  VideoViewController.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 19/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {
    
    var video:Video!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = video.name
    }
}
