//
//  FriendSearchTableViewCell.swift
//  Makestagram
//
//  Created by sakura davis on 7/5/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse

//Any class that wants to be a delegate of the FriendSearchTableViewCell will have to implement that protocol. Notice that the delegate methods are simply used to inform the delegate of whether a user was selected as followed or not.
protocol FriendSearchTableViewCellDelegate: class {
    func cell(cell: FriendSearchTableViewCell, didSelectFollowUser user: PFUser)
    func cell(cell: FriendSearchTableViewCell, didSelectUnfollowUser user: PFUser)
}

class FriendSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    //as each FriendSearchTableViewCell is created, the FriendSearchViewController will set itself as the delegate by assigning itself with this delegate property.
    weak var delegate: FriendSearchTableViewCellDelegate?
    
    var user: PFUser? {
        didSet {
            usernameLabel.text = user?.username
        }
    }
    
    var canFollow: Bool? = true {
        didSet {
            /*
             Change the state of the follow button based on whether or not
             it is possible to follow a user.
             */
            if let canFollow = canFollow {
                followButton.selected = !canFollow
            }
        }
    }
    
    @IBAction func followButtonTapped(sender: AnyObject) {
        if let canFollow = canFollow where canFollow == true {
            delegate?.cell(self, didSelectFollowUser: user!)
            self.canFollow = false
        } else {
            delegate?.cell(self, didSelectUnfollowUser: user!)
            self.canFollow = true
        }
    }
}