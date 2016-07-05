//
//  Post.swift
//  Makestagram
//
//  Created by sakura davis on 7/3/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse
import Bond

// To create a custom Parse class you need to inherit from PFObject and implement the PFSubclassing protocol
class Post : PFObject, PFSubclassing {
    
    //Parse class (Post) has imageFile and user
        // *** NSManaged tells the Swift compiler that we won't initialize the properties in the initializer, because Parse will take care of it for us.
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    //MARK: PFSubclassing Protocol
    // By implementing the parseClassName static function, you create a connection between the Parse class and your Swift class.
    static func parseClassName() -> String {
        return "Post"
    }
    
    // init and initialize are purely boilerplate code - copy these two into any custom Parse class that you're creating.
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    // UPLOAD IN BACKGROUND

    //The Observable wrapper enables us to use the property together with bindings.
    var image: Observable<UIImage?> = Observable(nil)
    
    
    //Let's request some extra time for our photo upload.
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    func uploadPost() {
        if let image = image.value {
            //When the uploadPost method is called, we grab the photo to be uploaded from the image property; turn it into a PFFile called imageFile.

            //We turn the UIImage into an NSData instance because the PFFile class needs an NSData argument for its initializer.
            //guard is just like optional binding in that it's used to unwrap optionals. With optional binding, we want to execute some code when the variable exists:
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
            
            //Next we create and save the PFFile.
            //takes the optional returned from the PFFile constructor, and force unwraps it.
            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else {return}
            
            // any uploaded post should be associated with the current user
            user = PFUser.currentUser()
            
            //We assign imageFile to self.imageFile. Then we call saveInBackground() to upload the Post.
            self.imageFile = imageFile
            
            //Create a background task so photo finishes uploading when user closes our app.
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler
                { () -> Void in
                //The API requires us to provide an expirationHandler in the form of a closure. That closure runs when the extra time that iOS permitted us has expired.
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            
            //After we've created the background task we save the post and imageFile by calling saveInBackgroundWithBlock();
            saveInBackgroundWithBlock() { (success: Bool, error: NSError?) in
                //Within the completion handler of saveInBackgroundWithBlock() we inform iOS that our background task is completed.
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        }
    }
    
    // DOWNLOAD LAZILY
    
    func downloadImage() {
        // if image is not downloaded yet, get it
        if (image.value == nil) {
            // Instead of using getData we are using getDataInBackgroundWithBlock - that way we are no longer blocking the main thread
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    //Once the download completes, we update the post.image
                    self.image.value = image
                }
            }
        }
    }
    
    //LIKES
    
    //We make the property Observable so that we can listen to changes and update our UI after we've downloaded the likes for a post.
    var likes: Observable<[PFUser]?> = Observable(nil)
    
    //FETCH LIKES
    func fetchLikes() {
        //as soon as likes.value has a cached value, we don't need to perform the body of this method
        if (likes.value != nil) {
            return
        }
        
        // We fetch the likes for the current Post using the ParseHelper likesForPost method that we created earlier
        ParseHelper.likesForPost(self, completionBlock: { (likes: [PFObject]?, error: NSError?) -> Void in
            //The filter method takes a closure and returns an array that only contains the objects from the original array that meet the requirement stated in that closure. (only likes that belong to users that exist)
            let validLikes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            
            //start with an array of likes and retrieve an array of users.
            self.likes.value = validLikes?.map { like in
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                //Then we assign the result to our likes.value property.
                return fromUser
            }
        })
    }
    
    //HAS USER ALRADY LIKED?
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return likes.contains(user)
        } else {
            return false
        }
    }
    
    //LIKE/UNLIKE POST
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            // if post is liked, unlike it now
            //Removing the user from the local cache stored in the likes property
            likes.value = likes.value?.filter { $0 != user }
            //syncing the change with Parse.
            ParseHelper.unlikePost(user, post: self)
        } else {
            // if this post is not liked yet, like it now
            //add them to the local cache and then sync the change with Parse.
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
    
}