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
*   Copyright (c) 2016 Matthew Cibulka. All rights reserved.
*
**********************************************************************************************************************************************************************************/

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        /* Insert code here to initialize your application */
        let defaultNotificationCenter = NotificationCenter.default()
        defaultNotificationCenter.post(name: Notification.Name(rawValue: "LoadLibrary"), object: nil)
        
        
        let defaultFM = FileManager.default()
        let desktopDir = try! defaultFM.urlForDirectory(.desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)    // disable error propogation with '!', we know the desktop directory will be returned
        var dataPath = desktopDir
        
        do {
            try dataPath.appendPathComponent("VinylLibrary", isDirectory: true)
        } catch {}
        
        
        // If the library folder doesn't exist, create it
        do {
            try defaultFM.createDirectory(at: dataPath, withIntermediateDirectories: false, attributes: nil)
        } catch {}
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        /* Insert code here to tear down your application */
    }
}

