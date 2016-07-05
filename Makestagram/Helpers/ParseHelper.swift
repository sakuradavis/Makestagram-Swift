//
//  ParseHelper.swift
//  Makestagram
//
//  Created by sakura davis on 7/4/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse


//We're going to introduce a ParseHelper.swift file that will contain most of our code that's responsible for talking to our Parse server. That way we can avoid bloated view controllers.

//We are going to wrap all of our helper methods into a class called ParseHelper (call ParseHelper.____)
class ParseHelper {
    
    //MARK: CONSTANTS
    //Parse[ClassName][FieldName].
    
    // Following Relation
    static let ParseFollowClass       = "Follow"
    static let ParseFollowFromUser    = "fromUser"
    static let ParseFollowToUser      = "toUser"
    
    // Like Relation
    static let ParseLikeClass         = "Like"
    static let ParseLikeToPost        = "toPost"
    static let ParseLikeFromUser      = "fromUser"
    
    // Post Relation
    static let ParsePostUser          = "user"
    static let ParsePostCreatedAt     = "createdAt"
    
    // Flagged Content Relation
    static let ParseFlaggedContentClass    = "FlaggedContent"
    static let ParseFlaggedContentFromUser = "fromUser"
    static let ParseFlaggedContentToPost   = "toPost"
    
    // User Relation
    static let ParseUserUsername      = "username"
    
    
    //MARK: TIMELINE
    
    //Static: we can call it without having to create an instance of ParseHelper - you should do that for all helper methods.
    //Takes completionBlock: the callback block that should be called once the query has completed. The type of this parameter is PFQueryArrayResultBlock.  By taking this callback as a parameter, we can call any Parse method and return the result of the method to that completionBlock.
    //Range argument will define which portions of the timeline will be loaded. Range literals can be defined like this: 5..10 (10 included) or 5..<10 (10 excluded).
    static func timelineRequestForCurrentUser(range: Range<Int>, completionBlock: PFQueryArrayResultBlock) {
        
        //Creating the query that fetches the Follow relationships for the current user.
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseFollowFromUser, equalTo:PFUser.currentUser()!)

        //use that query to fetch any posts that are created by users that the current user is following.
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
 
        // another query to retrieve all posts that the current user has posted.
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
 
        //create a combined query of the 2. and 3. queries using the orQueryWithSubqueries method.
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        //Know user for all posts
        query.includeKey(ParsePostUser)
        //chronological order.
        query.orderByDescending(ParsePostCreatedAt)
        
        //PFQuery provides a skip property. That allows us - as suspected by the name - to define how many elements that match our query shall be skipped.
        query.skip = range.startIndex
        //The limit property defines how many elements we want to load. We calculate the size of the range (by subtracting the startIndex from the endIndex) and pass the result to the limit property.
        query.limit = range.endIndex - range.startIndex

        //Instead of providing a closure and handling the results of the query within this method, we hand off the results to the closure that has been handed to use through the completionBlock parameter. This means whoever calls the timelineRequestForCurrentUser method will be able to handle the result returned from the query!
        query.findObjectsInBackgroundWithBlock(completionBlock)
        print("found timeline posts")

    }
    
    //MARK: LIKES
    
    //create like object
    static func likePost(user: PFUser, post: Post) {
        let likeObject = PFObject(className: ParseLikeClass)
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        likeObject.saveInBackgroundWithBlock(nil)
        print("created new like object")

    }
    
    //find like and delete
    static func unlikePost(user: PFUser, post: Post) {
        //query to find the like of a given user that belongs to a given post
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeFromUser, equalTo: user)
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            //We iterate over all like objects that met our requirements and delete them.
            if let results = results {
                for like in results {
                    like.deleteInBackgroundWithBlock(nil)
                    print("found like, deleting")
                }
            }
        }
    }
    
    //retrieve all likes for a post
    static func likesForPost(post: Post, completionBlock: PFQueryArrayResultBlock) {
        //find likes
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeToPost, equalTo: post)
        //know users
        query.includeKey(ParseLikeFromUser)
        //hand off the results to the closure that has been handed to use through the completionBlock parameter. This means whoever calls the method will be able to handle the result returned from the query!
        query.findObjectsInBackgroundWithBlock(completionBlock)
        print("Parse did query for all likes for post")
    }
    
}

extension PFObject {
    //Now Swift knows to consider any two Parse objects equal if they have the same objectId.
    public override func isEqual(object: AnyObject?) -> Bool {
        if (object as? PFObject)?.objectId == self.objectId {
            return true
        } else {
            return super.isEqual(object)
        }
    }
    
}