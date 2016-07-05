//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by sakura davis on 7/4/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse
import Bond

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likesIconImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
     @IBOutlet weak var moreButton: UIButton!
    
    
    @IBAction func moreButtonTapped(sender: AnyObject) {
    }
    
 
    @IBAction func likeButtonTapped(sender: AnyObject) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //TO FREE UP BINDING
    var postDisposable: DisposableType?
    var likeDisposable: DisposableType?
    
    //property and property observer
    var post: Post? {
        didSet {
            // destroy any old bindings that may exist
            postDisposable?.dispose()
            likeDisposable?.dispose()
            
            //Whenever a new value is assigned to the post property, we use optional binding to check whether the new value is nil.
            if let post = post {
                //Here we set up the bindings to post.image and post.likes.
                //Create a binding between the image property of the post and the image property of the postImageView using the .bindTo method.
                postDisposable = post.image.bindTo(postImageView.bnd_image)
                //Now our PostTableViewCell is able to receive and store a Post object and react to an asynchronously available image of that post!
                likeDisposable = post.likes.observe { (value: [PFUser]?) -> () in
                    //Because post.likes contains an optional array of PFUsers, we use optional binding to ensure that value is not nil.
                    if let value = value {
                        //update the likesLabel to display a list of usernames of all users that have liked the post. use a utility method stringFromUserList to generate that list.
                        self.likesLabel.text = self.stringFromUserList(value)
                        // set the state of the like button (the heart) based on whether or not the current user is in the list of users that like the currently displayed post.
                        self.likeButton.selected = value.contains(PFUser.currentUser()!)
                        // if no one likes the current post, we want to hide the small heart icon displayed in front of the list of users that like a post.
                        self.likesIconImageView.hidden = (value.count == 0)
                    } else {
                        //If posts.like is nil, not loaded from parse yet, set all UI elements to default values.
                        self.likesLabel.text = ""
                        self.likeButton.selected = false
                        self.likesIconImageView.hidden = true
                    }
                }
            }
        }
    }
    
    // Generates a comma separated list of usernames from an array (e.g. "User1, User2")
    func stringFromUserList(userList: [PFUser]) -> String {
        //mapping from PFUser objects to the usernames of these PFObjects.
        let usernameList = userList.map { user in user.username! }
        // use that array of strings to create one joint string.
        let commaSeparatedUserList = usernameList.joinWithSeparator(", ")
        print("list of users like created")
        return commaSeparatedUserList
    }
    

}
