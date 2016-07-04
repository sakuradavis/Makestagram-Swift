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
    //Create an instance of a PhotoTakingHelper that will display our popup.
    var photoTakingHelper: PhotoTakingHelper?
    
    
    //Setting the TimelineViewController to be the delegate of the tabBarController.

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
    }
    
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