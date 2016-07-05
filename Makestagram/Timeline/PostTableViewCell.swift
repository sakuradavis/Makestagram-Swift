//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by sakura davis on 7/4/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Bond

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    
    //property and property observer
    var post: Post? {
        didSet {
            //Whenever a new value is assigned to the post property, we use optional binding to check whether the new value is nil.
            if let post = post {
                //If the value isn't nil, we create a binding between the image property of the post and the image property of the postImageView using the .bindTo method.
                post.image.bindTo(postImageView.bnd_image)
                //Now our PostTableViewCell is able to receive and store a Post object and react to an asynchronously available image of that post!
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
