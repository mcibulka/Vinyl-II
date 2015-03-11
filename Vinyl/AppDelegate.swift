/*******************************************************************************************************************************************************************************
*
*   Project: Vinyl
*
*   Directory: Vinyl
*   File Name: AppDelegate.swift
*
*   Date Created: January 17, 2015
*   Created By: Matthew Cibulka
*
*   Copyright (c) 2015 Matthew Cibulka. All rights reserved.
*
**********************************************************************************************************************************************************************************/

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    let defaultNotificationCenter = NSNotificationCenter.defaultCenter()

    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        /* Insert code here to initialize your application */
        defaultNotificationCenter.postNotificationName("LoadSongs", object: nil)
    }

    func applicationWillTerminate(aNotification: NSNotification)
    {
        /* Insert code here to tear down your application */
    }
}

