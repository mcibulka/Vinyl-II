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

//extension FourCharCode
//{
//    func toString() -> NSString
//    {
//        let codes: [UInt32] = [
//            (self >> 24) & 255,
//            (self >> 16) & 255,
//            (self >> 8) & 255,
//            self & 255]
//        return codes.map{String(UnicodeScalar($0))}.reduce("", +)
//    }
//}

//var songArray = [NSManagedObject]()
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    let addFileOpenPanel = NSOpenPanel()
    var songArray = [Song]()
    
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
        if content != "" {
            var urlArray: NSArray = content!.componentsSeparatedByString("\n")
            var url: NSString
            
            for var i = 0; i < urlArray.count; i++
            {
                url = urlArray[i] as NSString
                
                if url != ""{
                    let songUrl = NSURL(string: url)
                    var asset = AVURLAsset(URL: songUrl, options: nil)
                    var mySong = extractSongInfo(asset)
                    
                    //Add song to song array
                    songArray.append(mySong)
                    println(mySong.artist)
                    // update table
                    //////myTableView.reloadData()
                }
            }
        } else {
            println("File empty\n")
        }
        
        //Core Data:
//        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
//        
//        // delete all records
//        for song in songArray {
//            managedContext.deleteObject(song)
//        }
//        
//        // save context
//        var error: NSError?
//        if !managedContext.save(&error) {
//            println("Could not save \(error), \(error?.userInfo)")
//        }

    }

    func applicationWillTerminate(aNotification: NSNotification)
    {
        // Insert code here to tear down your application
        // Open file
        println("SAVING:")
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("data", ofType: "txt")
        var err:NSError?
        var fileHandle: NSFileHandle
        
        if NSFileManager.defaultManager().fileExistsAtPath(path!) {
            for song in songsToSave {
                if let fileHandle = NSFileHandle(forWritingAtPath: path!) {
                    
                    //Add file path to data.txt
                    var text = song as NSString
                    println(song)
                    let data = ("\(text)\n").dataUsingEncoding(NSUTF8StringEncoding)
                    fileHandle.seekToEndOfFile()
                    fileHandle.writeData(data!)
                    fileHandle.closeFile()
                } else {
                    println("Can't open fileHandle \(err)")
                }
            }
        }
        
        //Core Data stuff:
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
    
    /* FUNCTION: isDirectory
    ** INPUT: NSURL
    ** RETURN: true if the NSURL is a directory, false if not a directory
    */
    func isDirectory(path: NSURL) -> Bool
    {
        addFileOpenPanel.allowsMultipleSelection = true
        addFileOpenPanel.canChooseDirectories = false
        addFileOpenPanel.canChooseFiles = true
        addFileOpenPanel.runModal()
//        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
//        let managedContext = self.managedObjectContext!
//        let entity =  NSEntityDescription.entityForName("Song", inManagedObjectContext:self.managedObjectContext!)
//        
//        let mySong = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:self.managedObjectContext!)
//        
        // Set all of the song attributes
//        song.setValue("new title", forKey: "title")
//        song.setValue("new album", forKey: "album")
       
        
        if isDirectory {
            return true
        } else {
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
        let enumerator: NSDirectoryEnumerator? = fileManager.enumeratorAtURL( dir as NSURL, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: nil, errorHandler: nil)
        var array = [NSURL]()
        
        while let element = enumerator?.nextObject() as? NSURL {
            println("Found a file")
            array.append(element)
        }
        return array
    }
    
    func addSongs(songsToAdd: NSArray)
    {
        for var i = 0; i < songsToAdd.count; i++
        {
            var mySong:Song = Song()
            let asset = AVURLAsset(URL: songsToAdd[i] as NSURL, options: nil)
            
            /* Determine song's time */
            let cmTime: CMTime = asset.duration
            let cmTimeSecs: Float64 = CMTimeGetSeconds(cmTime)
            let intTime: Int64 = Int64(round(cmTimeSecs))
            let minutes = (intTime % 3600) / 60
            let seconds = (intTime % 3600) % 60
            let timeStr: NSString = "\(minutes):\(seconds)"
            
            mySong.time = timeStr
            
            
            /* Record time and date of when song is added to the library */
            let dateAdded: NSDate = NSDate(timeIntervalSinceNow: 0.0)
            let dateAddedStr: NSString = dateAdded.descriptionWithCalendarFormat("%Y-%m-%d %H:%M:%S", timeZone: nil, locale: nil)!
            
            mySong.dateAdded = dateAddedStr
            
            
            if asset.URL != nil
            {
                var metadataItemArray: NSArray
                
                /* Extract metadata based on file type of song */
                let formats: NSArray = asset.availableMetadataFormats
                for format in formats
                {
                    if format as NSString == AVMetadataFormatID3Metadata    // MP3
                    {
                        metadataItemArray = asset.metadataForFormat(AVMetadataFormatID3Metadata)
                        
                        for metadataItem in metadataItemArray as [AVMetadataItem]
                        {
                            switch metadataItem.key() as NSString
                            {
                                case AVMetadataID3MetadataKeyAlbumTitle:                    // Album
                                    mySong.album = metadataItem.stringValue
                                case AVMetadataID3MetadataKeyLeadPerformer:                 // Album Artist
                                    mySong.artist = metadataItem.stringValue
                                case AVMetadataID3MetadataKeyBand:                          // Artist
                                    mySong.albumArtist = metadataItem.stringValue
                                case AVMetadataID3MetadataKeyBeatsPerMinute:                // Beats Per Minute
                                    mySong.beatsPerMinute = metadataItem.stringValue
                                case AVMetadataID3MetadataKeyComments:                      // Comments
                                    mySong.comments = metadataItem.stringValue
                                case AVMetadataID3MetadataKeyComposer:                      // Composer
                                    mySong.composer = metadataItem.stringValue
                                case AVMetadataID3MetadataKeyContentType:                   // Genre
                                    mySong.genre = metadataItem.stringValue
                                case AVMetadataID3MetadataKeyContentGroupDescription:       // Grouping
                                    mySong.grouping = metadataItem.stringValue
                                case AVMetadataID3MetadataKeyTitleDescription:              // Name
                                    mySong.name = metadataItem.stringValue
                                case AVMetadataID3MetadataKeyTrackNumber:                   // Track Number
                                    mySong.trackNumber = metadataItem.stringValue
                                case AVMetadataID3MetadataKeyRecordingTime,                 // Year
                                     AVMetadataID3MetadataKeyYear:
                                    mySong.year = metadataItem.stringValue
                                case AVMetadataID3MetadataKeyAttachedPicture:               // Album Artwork
                                    mySong.artwork = "Artwork"
                                default:
                                    break
                            }
                        }
                    }
                    else if format as NSString == AVMetadataFormatiTunesMetadata    // M4A
                    {
                        println("\niTunes files not supported yet.\n")
//                        metadataItemArray = asset.metadataForFormat(AVMetadataFormatiTunesMetadata)
//                        println(metadataItemArray)
//
//                        for metadataItem in metadataItemArray as [AVMetadataItem]
//                        {
//                            println(metadataItem.key().description)
//                            var keyAsString: String
//                            if let numKey = metadataItem.key() as? NSNumber {
//                                keyAsString = numKey.unsignedIntValue.toString()
//                            } else if let strKey = metadataItem.key() as? NSString {
//                                keyAsString = strKey
//                            } else {
//                                keyAsString = metadataItem.key().description
//                            }
//                            println(keyAsString)
//                        
//                            println(metadataItem.key() as NSString?)
//                            if let numKey = metadataItem.key() as? NSNumber
//                            {
//                                let strKey:NSString = numKey.unsignedIntValue.toString()
//                                println("\(strKey) == \(AVMetadataiTunesMetadataKeyAlbum)")
//                                
//                                switch strKey {
//                                case AVMetadataiTunesMetadataKeyAlbum:                    // Album
//                                    mySong.album = metadataItem.stringValue
//                                case AVMetadataiTunesMetadataKeyAlbumArtist:                 // Album Artist
//                                    mySong.artist = metadataItem.stringValue
//                                case AVMetadataiTunesMetadataKeyArtist:                          // Artist
//                                    mySong.albumArtist = metadataItem.stringValue
//                                case AVMetadataiTunesMetadataKeyBeatsPerMin:                // Beats Per Minute
//                                    mySong.beatsPerMinute = metadataItem.stringValue
//                                case AVMetadataiTunesMetadataKeyUserComment:                      // Comments
//                                    mySong.comments = metadataItem.stringValue
//                                case AVMetadataiTunesMetadataKeyComposer:                      // Composer
//                                    mySong.composer = metadataItem.stringValue
////                                case AVMetadataiTunesMetadataKeyUserGenre:                   // Genre
////                                    mySong.genre = metadataItem.stringValue
//                                case AVMetadataiTunesMetadataKeyGrouping:       // Grouping
//                                    mySong.grouping = metadataItem.stringValue
//                                case AVMetadataiTunesMetadataKeySongName:              // Name
//                                    mySong.name = metadataItem.stringValue
////                                case AVMetadataiTunesMetadataKeyTrackNumber:                   // Track Number
////                                    mySong.trackNumber = metadataItem.stringValue
//                                case AVMetadataiTunesMetadataKeyReleaseDate:                          // Year
//                                    mySong.year = metadataItem.stringValue
//                                case AVMetadataiTunesMetadataKeyCoverArt:               // Album Artwork
//                                    mySong.artwork = "Artwork"
//                                default:
//                                    break
//                                }
//                            }
//                        }
                    }
                    else
                    {
                        println("\nERROR. Unrecognized file format: \(format)\n\n")
                    }
                }
                
            } else if asset.URL != nil {
                println("URL: \(asset)")
                let mySong = extractSongInfo(asset)
                
                //Add song to song array
                songArray.append(mySong)
                
                // update table
               ////////// myTableView.reloadData()
                
                //add to songsToSave
                println("Songs to add:\(songsToAdd[i].absoluteString)")
                songsToSave.append(songsToAdd[i].absoluteString!!)
            }
        }
    }
    
    func extractSongInfo(asset: AnyObject) -> Song
    {
        var mySong:Song = Song()
        var metadataItemArray: NSArray
        
        // Extract metadata based on file type of song
        var formats: NSArray = asset.availableMetadataFormats
        for format in formats
        {
            if format as NSString == AVMetadataFormatID3Metadata    // MP3
            {
                metadataItemArray = asset.metadataForFormat(AVMetadataFormatID3Metadata)
                
                for metadataItem in metadataItemArray
                {
                    if let numKey = AVMetadataItem.keyForIdentifier(metadataItem.identifier) as? NSNumber
                    {
                        let strKey = numKey.unsignedIntValue.toString()
                        
                        switch strKey {
                        case AVMetadataID3MetadataKeyAlbumTitle:                    // Album
                            mySong.album = metadataItem.stringValue
                        case AVMetadataID3MetadataKeyLeadPerformer:                 // Album Artist
                            mySong.artist = metadataItem.stringValue
                        case AVMetadataID3MetadataKeyBand:                          // Artist
                            mySong.albumArtist = metadataItem.stringValue
                        case AVMetadataID3MetadataKeyBeatsPerMinute:                // Beats Per Minute
                            mySong.beatsPerMinute = metadataItem.stringValue
                        case AVMetadataID3MetadataKeyComments:                      // Comments
                            mySong.comments = metadataItem.stringValue
                        case AVMetadataID3MetadataKeyComposer:                      // Composer
                            mySong.composer = metadataItem.stringValue
                        case AVMetadataID3MetadataKeyContentType:                   // Genre
                            mySong.genre = metadataItem.stringValue
                        case AVMetadataID3MetadataKeyContentGroupDescription:       // Grouping
                            mySong.grouping = metadataItem.stringValue
                        case AVMetadataID3MetadataKeyTitleDescription:              // Name
                            mySong.name = metadataItem.stringValue
                        case AVMetadataID3MetadataKeyTrackNumber:                   // Track Number
                            mySong.trackNumber = metadataItem.stringValue
                        case AVMetadataID3MetadataKeyYear:                          // Year
                            mySong.year = metadataItem.stringValue
                        case AVMetadataID3MetadataKeyAttachedPicture:               // Album Artwork
                            mySong.artwork = "Artwork"
                        default:
                            break
                        }
                    }
                }
            }
            else if format as NSString == AVMetadataFormatiTunesMetadata    // .m4a
            {
                println("\niTunes files not supported yet.\n")
                //                        metadataItemArray = asset.metadataForFormat(AVMetadataFormatiTunesMetadata)
                //                        println(metadataItemArray)
                //
                //                        for metadataItem in metadataItemArray
                //                        {
                //                            if let numKey = AVMetadataItem.keyForIdentifier(metadataItem.identifier) as? NSNumber
                //                            {
                //                                let strKey:NSString = numKey.unsignedIntValue.toString()
                //                                println("\(strKey) == \(AVMetadataiTunesMetadataKeyAlbum)")
                //
                //                                switch strKey {
                //                                case AVMetadataiTunesMetadataKeyAlbum:                    // Album
                //                                    mySong.album = metadataItem.stringValue
                //                                case AVMetadataiTunesMetadataKeyAlbumArtist:                 // Album Artist
                //                                    mySong.artist = metadataItem.stringValue
                //                                case AVMetadataiTunesMetadataKeyArtist:                          // Artist
                //                                    mySong.albumArtist = metadataItem.stringValue
                //                                case AVMetadataiTunesMetadataKeyBeatsPerMin:                // Beats Per Minute
                //                                    mySong.beatsPerMinute = metadataItem.stringValue
                //                                case AVMetadataiTunesMetadataKeyUserComment:                      // Comments
                //                                    mySong.comments = metadataItem.stringValue
                //                                case AVMetadataiTunesMetadataKeyComposer:                      // Composer
                //                                    mySong.composer = metadataItem.stringValue
                ////                                case AVMetadataiTunesMetadataKeyUserGenre:                   // Genre
                ////                                    mySong.genre = metadataItem.stringValue
                //                                case AVMetadataiTunesMetadataKeyGrouping:       // Grouping
                //                                    mySong.grouping = metadataItem.stringValue
                //                                case AVMetadataiTunesMetadataKeySongName:              // Name
                //                                    mySong.name = metadataItem.stringValue
                ////                                case AVMetadataiTunesMetadataKeyTrackNumber:                   // Track Number
                ////                                    mySong.trackNumber = metadataItem.stringValue
                //                                case AVMetadataiTunesMetadataKeyReleaseDate:                          // Year
                //                                    mySong.year = metadataItem.stringValue
                //                                case AVMetadataiTunesMetadataKeyCoverArt:               // Album Artwork
                //                                    mySong.artwork = "Artwork"
                //                                default:
                //                                    break
                //                                }
                //                            }
                //                        }
            }
            else
            {
                println("\nERROR. Unrecognized file format: \(format)\n\n")
            }
        }
        // Add file path to Song object
        if let x = asset.URL!{
            var newstring = "\(asset.URL)"
            newstring = newstring.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            newstring = newstring.stringByReplacingOccurrencesOfString("Optional(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            newstring = newstring.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            mySong.fileURL = "\(newstring)\n"
        }
        println("\(mySong.fileURL)")
        return mySong
    }
    
    @IBAction func AddToLibrary(sender: AnyObject)
    {
        addFileOpenPanel.allowsMultipleSelection = true
        addFileOpenPanel.canChooseDirectories = true
        addFileOpenPanel.canChooseFiles = true
        addFileOpenPanel.runModal()
//        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
//        let managedContext = self.managedObjectContext!
//        let entity =  NSEntityDescription.entityForName("Song", inManagedObjectContext:self.managedObjectContext!)
//
//        let mySong = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:self.managedObjectContext!)
//
        // Set all of the song attributes
//        song.setValue("new title", forKey: "title")
//        song.setValue("new album", forKey: "album")
        
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

