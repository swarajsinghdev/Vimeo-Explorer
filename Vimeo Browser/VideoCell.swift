//
//  VideoCell.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 10/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {
    
    @IBOutlet var featuredImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setVideoContent(video:Video) {
        
        titleLabel.text = video.name
        categoryLabel.text = video.category?.name ?? "l"
        metaLabel.text = "\(video.numberOfPlays) plays"
        
        self.featuredImage.image = UIImage(named: "placeholder")
        
        VimeoClient.sharedInstance().getImage(urlString: video.imageUrl) { (success, image, errorDescription) in
    
            if let image = image {
                DispatchQueue.main.async {
                    self.featuredImage.image = image
                }
                    
                
            }
        }
        
    }
}
