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
    
    //Static: we can call it without having to create an instance of ParseHelper - you should do that for all helper methods.
    //Takes completionBlock: the callback block that should be called once the query has completed. The type of this parameter is PFQueryArrayResultBlock.  By taking this callback as a parameter, we can call any Parse method and return the result of the method to that completionBlock.
    
    static func timelineRequestForCurrentUser(completionBlock: PFQueryArrayResultBlock) {
        
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
        
        //Instead of providing a closure and handling the results of the query within this method, we hand off the results to the closure that has been handed to use through the completionBlock parameter. This means whoever calls the timelineRequestForCurrentUser method will be able to handle the result returned from the query!
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
}