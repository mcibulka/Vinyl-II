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
    func applicationDidFinishLaunching(_ aNotification:Notification)
    {
        let defaultFM = FileManager.default
        let libraryName = "VinylLibrary"
        
        NotificationCenter.default.post(name:Notification.Name(rawValue:"LoadLibrary"), object:nil)
    
        let desktop = try! defaultFM.url(for:.desktopDirectory, in:.userDomainMask, appropriateFor:nil, create:false)
        var library = desktop
        library.appendPathComponent(libraryName, isDirectory:true)
        
        do {
            try defaultFM.createDirectory(at:library, withIntermediateDirectories:false, attributes:nil)
        }
        catch CocoaError.fileWriteFileExists {}  // do nothing
        catch CocoaError.fileWriteNoPermission {
            print("Error creating Vinyl Library directory. File write permissions.")
        }
        catch CocoaError.fileWriteOutOfSpace {
            print("Error creating Vinyl Library directory. Out of space.")
        }
        catch let error as NSError {
            print("Error creating Vinyl Library directory. Other. Domain: \(error.domain), Code: \(error.code)")
        }
    }

    
    /* Code to tear down the application */
    func applicationWillTerminate(_ aNotification:Notification) {}
}

