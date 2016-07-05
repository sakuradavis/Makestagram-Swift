//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by sakura davis on 7/1/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit

class TimelineViewController: UIViewController, TimelineComponentTarget {
    
    @IBOutlet weak var tableView: UITableView!
    
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!
    
    //TIMELINE QUERY (SHOW POSTS)
    //var posts: [Post] = []
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        timelineComponent.loadInitialIfRequired()
        //Following code removed after implementing TimelineComponent which takes care of recieving posts on timeline.
//        //We no longer want to download all images immediately after the timeline query completes, instead we want to load them lazily as soon as a post is displayed.
//        
//        //We kick off the network request.
//        ParseHelper.timelineRequestForCurrentUser {(result: [PFObject]?, error: NSError?) -> Void in
//            
//            //Cast result [PFObject] to [Post] or store an empty array ([]) in self.posts.
//            self.posts = result as? [Post] ?? []
//           
////            //For all posts...
////            for post in self.posts {
////                do {
////                    //download imageFile
////                    let data = try post.imageFile?.getData()
////                    //turn it from NSData into a UIImage, store in image property of post.
////                    post.image = UIImage(data: data!, scale:1.0)
////                } catch {
////                    print("could not get image")
////                }
////            }
//            
//            //Refresh!
//            self.tableView.reloadData()
        
    }
    
    //Setting the TimelineViewController to be the delegate of the tabBarController.
    override func viewDidLoad() {
        super.viewDidLoad()
        //TimelineComponent only takes one argument when it's being initialized: the target. The target is the object to which the TimelineComponent shall add its functionality
        timelineComponent = TimelineComponent(target: self)
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
    
    
    //MARK: TimelineComponentTarget Protocol!!!
    //initially show the newest 5 posts
    let defaultRange = 0...4
    //When the user reaches the end of the timeline, we load an additional 5.
    let additionalRangeSize = 5
    
    //implement the loadInRange method so that the TimelineComponent can call it and receive the posts on a user's timeline.
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        //pass the range
        ParseHelper.timelineRequestForCurrentUser(range) { (result: [PFObject]?, error: NSError?) -> Void in
            // In the callback of the query we check whether or not we have received a result. If the result is nil we store an empty array in the posts variable.
            let posts = result as? [Post] ?? []
            //pass the posts that have been loaded back to the TimelineComponent by calling the completionBlock.
            completionBlock(posts)
        }
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
        return timelineComponent.content.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //cast cell to our custom class PostTableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        let post = timelineComponent.content[indexPath.row]        
        // Directly before a post will be displayed, we trigger the image download.
        post.downloadImage()
        //fetch likes
        post.fetchLikes()
        print("about to fetch likes lazily!")
        //assign the post that shall be displayed to the post property
        cell.post = post
        
        return cell
        
//        //Using the postImageView property of our custom cell we can now decide which image should be displayed in the cell.
//        cell.postImageView.image = posts[indexPath.row].image
//        return cell
    }
}

//Whenever a cell becomes visible, we are required to call the targetWillDisplayEntry: method and pass the index of the currently displayed cell. That way the TimelineComponent will know when the user has scrolled to the bottom of the timeline.
extension TimelineViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        timelineComponent.targetWillDisplayEntry(indexPath.row)
    }
    
}
