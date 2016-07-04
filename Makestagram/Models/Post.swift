//
//  Post.swift
//  Makestagram
//
//  Created by sakura davis on 7/3/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse

// To create a custom Parse class you need to inherit from PFObject and implement the PFSubclassing protocol
class Post : PFObject, PFSubclassing {
    
    //each property that you want to access on this Parse class (Post): imageFile and user
    // NSManaged tells the Swift compiler that we won't initialize the properties in the initializer, because Parse will take care of it for us.
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
    
}