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
*******************************************************************************************************************************************************************************/

import Cocoa
import CoreData
import AVFoundation

let ID3V2_2ALBUM = "id3/%00TAL"
let ID3V2_2ALBUMARTIST = "id3/%00TP2"
let ID3V2_2ARTIST = "id3/%00TP1"
let ID3V2_2COMMENTS = "id3/%00COM"
let ID3V2_2COMPOSER = "id3/%00TCM"
let ID3V2_2GENRE = "id3/%00TCO"
let ID3V2_2GROUPING = "id3/%00TT1"
let ID3V2_2NAME = "id3/%00TT2"
let ID3V2_2YEAR = "id3/%00TYE"

let ID3V2_4ALBUM = "id3/TALB"
let ID3V2_4ALBUMARTIST = "id3/TPE2"
let ID3V2_4ARTIST = "id3/TPE1"
let ID3V2_4COMMENTS = "id3/COMM"
let ID3V2_4COMPOSER = "id3/TCOM"
let ID3V2_4GENRE = "id3/TCON"
let ID3V2_4GROUPING = "id3/TIT1"
let ID3V2_4NAME = "id3/TIT2"
let ID3V2_4YEAR = "id3/TDRC"

let MP4V2_0ALBUM = "itsk/%A9alb"
let MP4V2_0ALBUMARTIST = "itsk/aART"
let MP4V2_0ARTIST = "itsk/%A9ART"
let MP4V2_0COMMENTS = "itsk/%A9cmt"
let MP4V2_0COMPOSER = "itsk/%A9wrt"
let MP4V2_0GENRE = "itsk/%A9gen"
let MP4V2_0GROUPING = "itsk/%A9grp"
let MP4V2_0ANAME = "itsk/%A9nam"
let MP4V2_0YEAR = "itsk/%A9day"

//var songArray = [NSManagedObject]()
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    let addFileOpenPanel = NSOpenPanel()
    var songArray = [Song]()
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        /* Insert code here to initialize your application
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        // delete all records
        for song in songArray {
            managedContext.deleteObject(song)
        }
        
        // save context
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        */
    }

    func applicationWillTerminate(aNotification: NSNotification)
    {
//        // Insert code here to tear down your application
//        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
//       // let managedContext = appDelegate.self.managedObjectContext!
//        
//        let fetchRequest = NSFetchRequest(entityName:"Song")
//        
//        var error: NSError?
//        
//        let fetchedResults = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
//        
//        if let results = fetchedResults {
//            var songs = results
//            for song in songs {
//                println(song)
//               // println(song.valueForKey("album")!)
//            }
//            
//        } else {
//            println("Could not fetch \(error), \(error!.userInfo)")
//        }
    }
    
    @IBAction func AddToLibrary(sender: AnyObject)
    {
        addFileOpenPanel.allowsMultipleSelection = true
        addFileOpenPanel.canChooseDirectories = false
        addFileOpenPanel.canChooseFiles = true
        addFileOpenPanel.runModal()
        //let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        //let managedContext = appDelegate.managedObjectContext!
       // let managedContext = self.managedObjectContext!
//        let entity =  NSEntityDescription.entityForName("Song", inManagedObjectContext:self.managedObjectContext!)
//        
//        let mySong = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:self.managedObjectContext!)
//        
        // Set all of the song attributes
       // song.setValue("new title", forKey: "title")
        //song.setValue("new album", forKey: "album")
        
       
        
        // println("Count: \(addFileOpenPanel.URLs.count)")
        var songsToAdd: NSArray = addFileOpenPanel.URLs
        
        for var i = 0; i < songsToAdd.count; i++
        {
            var asset = AVURLAsset(URL: songsToAdd[i] as NSURL, options: nil)
            
            if asset.URL != nil
            {
                var commonMetadata = asset.commonMetadata as NSArray
                var formats : NSArray = asset.availableMetadataFormats
                
                var metaData : NSArray
                var mySong:Song = Song(album: "", albumArtist: "", artist: "", comments: "", composer: "", dateAdded: "", genre: "", grouping: "", name: "", time: "", year: "", fileURL: "")
                
                // Extract metadata based on file type of song
                for format in formats
                {
                    if format as NSString == "org.id3"  // .mp3
                    {
                        metaData = asset.metadataForFormat("org.id3")
                        var tag : AVMetadataItem
                        for tag in metaData
                        {
                            // NOTE: Initially wrote these blocks as a combined if-else statement using logical || but Xcode couldn't compile
                            // Xcode bug: SourceKitService is fluctuating up to 300% CPU Usage
                            /* Extract metadata based on id3v2-00 frames */
                            if tag.identifier == ID3V2_2ALBUM {                  // Album
                                mySong.album = tag.stringValue
                            } else if tag.identifier == ID3V2_2ALBUMARTIST {     // Album Artist
                                mySong.albumArtist = tag.stringValue
                            } else if tag.identifier == ID3V2_2ARTIST {          // Artist
                                mySong.artist = tag.stringValue
                            } else if tag.identifier == ID3V2_2COMMENTS {        // Comments
                                mySong.comments = tag.stringValue
                            } else if tag.identifier == ID3V2_2COMPOSER {        // Composer
                                mySong.composer = tag.stringValue
                            } else if tag.identifier == ID3V2_2GENRE {           // Genre
                                mySong.genre = tag.stringValue
                            } else if tag.identifier == ID3V2_2GROUPING {        // Grouping
                                mySong.grouping = tag.stringValue
                            } else if tag.identifier == ID3V2_2NAME {            // Name
                                mySong.name = tag.stringValue
                            } else if tag.identifier == ID3V2_2YEAR {            // Year
                                mySong.year = tag.stringValue
                            }
                            
                            /* Extract data based on id3v2.4.0 frames */
                            if tag.identifier == ID3V2_4ALBUM {                  // Album
                                mySong.album = tag.stringValue
                            } else if tag.identifier == ID3V2_4ALBUMARTIST {     // Album Artist
                                mySong.albumArtist = tag.stringValue
                            } else if tag.identifier == ID3V2_4ARTIST {          // Artist
                                mySong.artist = tag.stringValue
                            } else if tag.identifier == ID3V2_4COMMENTS {        // Comments
                                mySong.comments = tag.stringValue
                            } else if tag.identifier == ID3V2_4COMPOSER {        // Composer
                                mySong.composer = tag.stringValue
                            } else if tag.identifier == ID3V2_4GENRE {           // Genre
                                mySong.genre = tag.stringValue
                            } else if tag.identifier == ID3V2_4GROUPING {        // Grouping
                                mySong.grouping = tag.stringValue
                            } else if tag.identifier == ID3V2_4NAME {            // Name
                                mySong.name = tag.stringValue
                            } else if tag.identifier == ID3V2_4YEAR {            // Year
                                mySong.year = tag.stringValue
                            }
                        }
                    }
                    else if format as NSString == "com.apple.itunes"    // .m4a
                    {
                        metaData = asset.metadataForFormat("com.apple.itunes")
                        var tag : AVMetadataItem
                        for tag in metaData
                        {
                            if tag.identifier == MP4V2_0ALBUM {                 // Album
                                mySong.album = tag.stringValue
                            } else if tag.identifier == MP4V2_0ALBUMARTIST{     // Album Artist
                                mySong.albumArtist = tag.stringValue
                            } else if tag.identifier == MP4V2_0ARTIST {         // Artist
                                mySong.artist = tag.stringValue
                            } else if tag.identifier == MP4V2_0COMMENTS {       // Comments
                                mySong.comments = tag.stringValue
                            } else if tag.identifier == MP4V2_0COMPOSER {       // Composer
                                mySong.composer = tag.stringValue
                            } else if tag.identifier == MP4V2_0GENRE {          // Genre - not yet decoded
                                mySong.genre = tag.stringValue
                            } else if tag.identifier == MP4V2_0GROUPING {       // Grouping
                                mySong.grouping = tag.stringValue
                            } else if tag.identifier == MP4V2_0ANAME {          // Name
                                mySong.name = tag.stringValue
                            } else if tag.identifier == MP4V2_0YEAR {           // Year
                                mySong.year = tag.stringValue
                            }
                        }
                    }

                    else
                    {
                        println("\nERROR. Unrecognized file format: \(format)\n\n")
                    }
                }
                
                //Add file path
                mySong.fileURL = "\(asset.URL)"
                //mySong.setValue("\(asset.URL)", forKey:"fileURL")
                //Add song to song array
                songArray.append(mySong)
                
                // update table
                //myTableView.reloadData()
                
                // Save context
//                var error: NSError?
//                if !self.managedObjectContext!.save(&error) {
//                    println("Could not save \(error), \(error?.userInfo)")
//                }
                
                //  print out song array
                println("----------------------------------")
                for i in songArray
                {
                    //iTunes
                    println("\nAlbum: \(i.album)\nAlbum Artist: \(i.albumArtist)\nArtist: \(i.artist)\nComments: \(i.comments)\nComposer: \(i.composer)\nGenre: \(i.genre)\nGrouping: \(i.grouping)\nName \(i.name)\nYear: \(i.year)")
                    
                    //filepath
                    println("\nFile path: \(i.fileURL)\n")
                }
            }
        }
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

