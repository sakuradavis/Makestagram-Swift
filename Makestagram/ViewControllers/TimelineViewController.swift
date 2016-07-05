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
        
        //We no longer want to download all images immediately after the timeline query completes, instead we want to load them lazily as soon as a post is displayed.
        
        //We kick off the network request.
        ParseHelper.timelineRequestForCurrentUser {
            (result: [PFObject]?, error: NSError?) -> Void in
            
            //Cast result [PFObject] to [Post] or store an empty array ([]) in self.posts.
            self.posts = result as? [Post] ?? []
           
//            //For all posts...
//            for post in self.posts {
//                do {
//                    //download imageFile
//                    let data = try post.imageFile?.getData()
//                    //turn it from NSData into a UIImage, store in image property of post.
//                    post.image = UIImage(data: data!, scale:1.0)
//                } catch {
//                    print("could not get image")
//                }
//            }
            
            //Refresh!
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
                post.image.value = image
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
        //cast cell to our custom class PostTableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        let post = posts[indexPath.row]
        
        // Directly before a post will be displayed, we trigger the image download.
        post.downloadImage()
        //assign the post that shall be displayed to the post property
        cell.post = post
        
        return cell
        
//        //Using the postImageView property of our custom cell we can now decide which image should be displayed in the cell.
//        cell.postImageView.image = posts[indexPath.row].image
//        return cell
    }
}
