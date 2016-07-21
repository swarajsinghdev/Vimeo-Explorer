//
//  VideoBodyView.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 21/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import UIKit

class VideoBodyView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setVideoContent(video: Video) {
        
        titleLabel.text = video.name
        playsLabel.text = "\(video.numberOfPlays) plays - \(video.createdTime.timeAgoSinceDate(true))"
        descriptionLabel.text = video.videoDescription
    }
}
