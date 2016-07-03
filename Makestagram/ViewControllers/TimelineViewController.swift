//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by sakura davis on 7/1/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

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
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!)
        { (image: UIImage?) in
            print("received a callback")
        }
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