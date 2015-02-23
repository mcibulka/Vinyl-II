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
import AVFoundation
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    let addFileOpenPanel = NSOpenPanel()
    
    var songArray = [Song]()
    var songsToSave = [String]()
    
    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        /* Insert code here to initialize your application */
        
        //open file with song URLS
        println("OPENING:")
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("data", ofType: "txt")
        
        // Read content of file
        let content = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        
        // Extract Song info
        if content != nil
        {
            let urlArray = content!.componentsSeparatedByString("\n")
            
            for var i = 0; i < urlArray.count; i++
            {
                let songUrl = NSURL(string: urlArray[i])
                
                let asset = AVURLAsset(URL: songUrl, options: nil)
                var mySong = Song(asset: asset)
                
                songArray.append(mySong)
            }
        }
        else {
            println("File empty\n")
        }
        
        println(songArray.count)
        for var i=0 ; i<songArray.count ; i++
        {
            println(songArray[i].toString())
        }
    }

    func applicationWillTerminate(aNotification: NSNotification)
    {
        // Insert code here to tear down your application
        // Open file
        println("SAVING:")
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("data", ofType: "txt")
        
        if NSFileManager.defaultManager().fileExistsAtPath(path!)
        {
            for song in songsToSave
            {
                if let fileHandle = NSFileHandle(forWritingAtPath: path!)
                {
                    //Add file path to data.txt
                    let data = ("\(song)\n").dataUsingEncoding(NSUTF8StringEncoding)
                    fileHandle.seekToEndOfFile()
                    fileHandle.writeData(data!)
                    fileHandle.closeFile()
                }
                else {
                    println("Can't open fileHandle.")
                }
            }
        }
    }
    
    /* FUNCTION: isDirectory
    ** INPUT: NSURL
    ** RETURN: true if the NSURL is a directory, false if not a directory
    */
    func isDirectory(path: NSURL) -> Bool
    {
        var isDirectory: ObjCBool = ObjCBool(false)     // REFACTOR to Swift type Bool?
        
        if NSFileManager.defaultManager().fileExistsAtPath(path.path!, isDirectory: &isDirectory) {}
        
        if isDirectory {
            return true
        }
        else {
            return false
        }
    }
    
    /* FUNCTION: dirIterator
    ** INPUT: NSURL of a directory
    ** RETURN: An NSArray of NSURLS that were contained in the directory
    */
    func dirIterator(dir: NSURL) -> NSArray
    {
        let fileManager = NSFileManager.defaultManager()
        let enumerator = fileManager.enumeratorAtURL(dir as NSURL, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: nil, errorHandler: nil)
        var urlArray = [NSURL]()
        
        while let element = enumerator?.nextObject() as? NSURL
        {
            println("Found a file")
            urlArray.append(element)
        }
        return urlArray
    }
    
    func addSongs(songsToAdd: NSArray)
    {
        for var i = 0; i < songsToAdd.count; i++
        {
            var asset = AVURLAsset(URL: songsToAdd[i] as NSURL, options: nil)
            
            if isDirectory(songsToAdd[i] as NSURL) {
                addSongs(dirIterator(songsToAdd[i] as NSURL))
            }
            else if asset.URL != nil
            {
                println("URL: \(asset)")
                let mySong = Song(asset: asset)
                
                //Add song to song array
                songArray.append(mySong)
                
                //add to songsToSave
                println("Songs to add:\(songsToAdd[i].absoluteString)")
                songsToSave.append(songsToAdd[i].absoluteString!!)
            }
        }
    }
    
    
    @IBAction func AddToLibrary(sender: AnyObject)
    {
        addFileOpenPanel.allowsMultipleSelection = true
        addFileOpenPanel.canChooseDirectories = true
        addFileOpenPanel.canChooseFiles = true
        addFileOpenPanel.runModal()
        
        var songsToAdd: NSArray = addFileOpenPanel.URLs
        addSongs(songsToAdd)
    }

    
//    // MARK: - Core Data stack
//
//    lazy var applicationDocumentsDirectory: NSURL = {
//        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.matthew-cibulka.Vinyl" in the user's Application Support directory.
//        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
//        let appSupportURL = urls[urls.count - 1] as NSURL
//        return appSupportURL.URLByAppendingPathComponent("com.matthew-cibulka.Vinyl")
//    }()
//
//    lazy var managedObjectModel: NSManagedObjectModel = {
//        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
//        let modelURL = NSBundle.mainBundle().URLForResource("Vinyl", withExtension: "momd")!
//        return NSManagedObjectModel(contentsOfURL: modelURL)!
//    }()
//
//    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
//        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
//        let fileManager = NSFileManager.defaultManager()
//        var shouldFail = false
//        var error: NSError? = nil
//        var failureReason = "There was an error creating or loading the application's saved data."
//
//        // Make sure the application files directory is there
//        let propertiesOpt = self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey], error: &error)
//        if let properties = propertiesOpt {
//            if !properties[NSURLIsDirectoryKey]!.boolValue {
//                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
//                shouldFail = true
//            }
//        } else if error!.code == NSFileReadNoSuchFileError {
//            error = nil
//            fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil, error: &error)
//        }
//        
//        // Create the coordinator and store
//        var coordinator: NSPersistentStoreCoordinator?
//        if !shouldFail && (error == nil) {
//            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//            let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Vinyl.storedata")
//            if coordinator!.addPersistentStoreWithType(NSXMLStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
//                coordinator = nil
//            }
//        }
//        
//        if shouldFail || (error != nil) {
//            // Report any error we got.
//            let dict = NSMutableDictionary()
//            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
//            dict[NSLocalizedFailureReasonErrorKey] = failureReason
//            if error != nil {
//                dict[NSUnderlyingErrorKey] = error
//            }
//            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            NSApplication.sharedApplication().presentError(error!)
//            return nil
//        } else {
//            return coordinator
//        }
//    }()
//
//    lazy var managedObjectContext: NSManagedObjectContext? = {
//        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
//        let coordinator = self.persistentStoreCoordinator
//        if coordinator == nil {
//            return nil
//        }
//        var managedObjectContext = NSManagedObjectContext()
//        managedObjectContext.persistentStoreCoordinator = coordinator
//        return managedObjectContext
//    }()
//
//    // MARK: - Core Data Saving and Undo support
//
//    @IBAction func saveAction(sender: AnyObject!) {
//        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
//        if let moc = self.managedObjectContext {
//            if !moc.commitEditing() {
//                NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing before saving")
//            }
//            var error: NSError? = nil
//            if moc.hasChanges && !moc.save(&error) {
//                NSApplication.sharedApplication().presentError(error!)
//            }
//        }
//    }
//
//    func windowWillReturnUndoManager(window: NSWindow) -> NSUndoManager? {
//        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
//        if let moc = self.managedObjectContext {
//            return moc.undoManager
//        } else {
//            return nil
//        }
//    }
//
//    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
//        // Save changes in the application's managed object context before the application terminates.
//        
//        if let moc = managedObjectContext {
//            if !moc.commitEditing() {
//                NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing to terminate")
//                return .TerminateCancel
//            }
//            
//            if !moc.hasChanges {
//                return .TerminateNow
//            }
//            
//            var error: NSError? = nil
//            if !moc.save(&error) {
//                // Customize this code block to include application-specific recovery steps.
//                let result = sender.presentError(error!)
//                if (result) {
//                    return .TerminateCancel
//                }
//                
//                let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
//                let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
//                let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
//                let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
//                let alert = NSAlert()
//                alert.messageText = question
//                alert.informativeText = info
//                alert.addButtonWithTitle(quitButton)
//                alert.addButtonWithTitle(cancelButton)
//                
//                let answer = alert.runModal()
//                if answer == NSAlertFirstButtonReturn {
//                    return .TerminateCancel
//                }
//            }
//        }
//        // If we got here, it is time to quit.
//        return .TerminateNow
//    }

}

