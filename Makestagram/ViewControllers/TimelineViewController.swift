//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by sakura davis on 7/1/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse

class TimelineViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    //TIMELINE QUERY (SHOW POSTS)
    var posts: [Post] = []
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Creating the query that fetches the Follow relationships for the current user.
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
        
        //use that query to fetch any posts that are created by users that the current user is following.
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
        
        // another query to retrieve all posts that the current user has posted.
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey("user", equalTo: PFUser.currentUser()!)
        
        //create a combined query of the 2. and 3. queries using the orQueryWithSubqueries method.
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        //Know user for all posts
        query.includeKey("user")
        //chronological order.
        query.orderByDescending("createdAt")
        
        //We kick off the network request.
        query.findObjectsInBackgroundWithBlock {(result: [PFObject]?, error: NSError?) -> Void in
            //Cast result [PFObject] to [Post] or store an empty array ([]) in self.posts.
            self.posts = result as? [Post] ?? []
            // Refresh
            self.tableView.reloadData()
        }
    }
    
    
    //Setting the TimelineViewController to be the delegate of the tabBarController.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
    }
    
    //PHOTO TAKING
    //Create an instance of a PhotoTakingHelper that will display our popup.
    var photoTakingHelper: PhotoTakingHelper?

    
    func takePhoto() {
        //Within the takePhoto method we're creating an instance of PhotoTakingHelper. We're assigning that instance to the photoTakingHelper property. The initializer of the PhotoTakingHelper takes two parameters: the view controller on which the popup should be presented and the callback that should run as soon as a photo has been selected
        
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!,
            //Provide callback for when photo is selected
            //As a callback we pass a closure. A closure is basically a function without a name.
            //Trailing closures can be used whenever the last argument of a function or initializer is a closure.

            callback: { (image: UIImage?) in
                let post = Post()
                post.image = image
                post.uploadPost()
            }
        )
    }
    
    
    
    
}





// MARK: Tab Bar Delegate
//Using this method the tab bar view controller asks its delegate whether or not it should present the view controller that belongs to the tab bar item that the user just tapped.
//The protocol method requires us to return a boolean value. If we return true the tab bar will present the view controller that the user has selected. If we return false the view controller will not be displayed - exactly the behavior that we want for the Photo Tab Bar Item.

extension TimelineViewController: UITabBarControllerDelegate {
    
func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
    // If the view controller is a PhotoViewController we return false and print "Take Photo" to the console
    if (viewController is PhotoViewController) {
        takePhoto()
        return false
    }
        //If the view controller isn't a PhotoViewController, we return true and let the tab bar controller behave as usual.
        else {
            return true
        }
    }
}

extension TimelineViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Our Table View needs to have as many rows as we have posts stored in the posts property
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //For now we return a simple placeholder cell with the title "Post" 
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell")!
        
        cell.textLabel!.text = "Post"
        
        return cell
    }
}
