//
//  AppDelegate.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/15/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

//These actions (starting, going into the background, and closing), are referred to as lifecycle events. Whenever we want to respond to such events, the AppDelegate is the right place to add our code

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //This method is called as soon as our app starts - this is where we need to add the code to configure the Parse.
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Set up the Parse SDK
        //$0 stands for first argument "configuration"
        let configuration = ParseClientConfiguration {
            $0.applicationId = "makestagram"
            $0.server = "https://makestagram-parse-sld.herokuapp.com/parse"
        }
        Parse.initializeWithConfiguration(configuration)
        
        //Extend the AppDelegate to log in with our test credentials. We'll also add an if statement to test if the login was successful.
        //We are using the loginWithUsername method of PFUser to programmatically sign in with the info of the test user that we just created. PFUser is the default Parse class for user objects
        do {
            try PFUser.logInWithUsername("test", password: "test")
        } catch {
            print("Unable to log in")
        }
        //check if it was successful.
        //The PFUser.currentUser() method returns an optional PFUser?
        //We use an optional binding (if let user = PFUser.currentUser()) to check if the result of the method call was a PFUser.
        if let currentUser = PFUser.currentUser() {
            print("\(currentUser.username!) logged in successfully")
        } else {
            print("No logged in user :(")
        }
        
        //Allows public read access - any user can see all objects created with this default ACL
        let acl = PFACL()
        acl.publicReadAccess = true
        PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

