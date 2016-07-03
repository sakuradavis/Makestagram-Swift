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
    //Add the property definition for photoTakingHelper
    var photoTakingHelper: PhotoTakingHelper?
    
    
    //Setting the TimelineViewController to be the delegate of the tabBarController.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
    }
    
    func takePhoto() {
        // instantiate photo taking class, provide callback for when photo is selected
        
        //As a callback we pass a closure. A closure is basically a function without a name.
        //Trailing closures can be used whenever the last argument of a function or initializer is a closure.
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!, callback: { (image: UIImage?) in
            if let image = image {
                
                //We turn the UIImage into an NSData instance because the PFFile class needs an NSData argument for its initializer. Also, we give it the name "image.jpg".
                //takes the optional returned from the PFFile constructor, and force unwraps it.
                let imageData = UIImageJPEGRepresentation(image, 0.8)!
                //Next we create and save the PFFile.
                let imageFile = PFFile(name: "image.jpg", data: imageData)!
                
                //create a PFObject of type post. We assign the "imageFile" to this post and then save it as well.
                let post = PFObject(className: "Post")
                post["imageFile"] = imageFile
                post.saveInBackground()
            }
        })
    }
    
}

// MARK: Tab Bar Delegate
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