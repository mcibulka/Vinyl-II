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
*******************************************************************************************************************************************************************************/

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    /* Code to initialize the application */
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        let defaultFM = FileManager.default()
        let libraryName = "VinylLibrary"
        
        NotificationCenter.default().post(name: Notification.Name(rawValue: "LoadLibrary"), object: nil)
    
        let desktopDir = try! defaultFM.urlForDirectory(.desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        var libPath = desktopDir
    
        do {
            try libPath.appendPathComponent(libraryName, isDirectory: true)
        } catch {}
        
        do {
            try defaultFM.createDirectory(at: libPath, withIntermediateDirectories: false, attributes: nil)
        } catch {}
    }

    
    /* Code to tear down the application */
    func applicationWillTerminate(_ aNotification: Notification) {}
}

