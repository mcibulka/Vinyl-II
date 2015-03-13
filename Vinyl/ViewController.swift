/*******************************************************************************************************************************************************************************
*
*   Project: Vinyl
*
*   Directory: Vinyl
*   File Name: ViewController.swift
*
*   Date Created: January 17, 2015
*   Created By: Matthew Cibulka
*
*   Copyright (c) 2015 Matthew Cibulka. All rights reserved.
*
*******************************************************************************************************************************************************************************/

import Cocoa
import AVFoundation

class ViewController: NSViewController
{
    @IBOutlet weak var songArrayTableView: NSTableView!
    @IBOutlet var songArrayController: NSArrayController!
    
    var songArray = [Song]()
    var audioPlayer = AVAudioPlayer()
    var firstSongPlayed = false
    
    
    override func viewDidLoad()
    {
        let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
        defaultNotificationCenter.addObserver(self, selector: "loadLibrary:", name:"LoadSongs", object: nil)
        
        
    }
    
    
    func loadLibrary(notification: NSNotification)
    {
        let mainBundle = NSBundle.mainBundle()
        let path = mainBundle.pathForResource("songsList", ofType: "txt")
        let songsListFileContent = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
     
        println("LOADING...\n")
        
        // If there are previously added songs, populate the song array
        if songsListFileContent != ""
        {
            let entryArray = songsListFileContent!.componentsSeparatedByString("\n")

            for entry in entryArray
            {
                let entryComponentsArray = entry.componentsSeparatedByString(",")
                let existingSongFileURL = entryComponentsArray[0]
                let existingSongDateAdded = entryComponentsArray[1]
                let existingSongTime = entryComponentsArray[2]
                
                let existingAsset = AVURLAsset(URL: NSURL(string: existingSongFileURL), options: nil)
                
                let existingSong = Song(fileURLString: existingSongFileURL, dateAddedString: existingSongDateAdded, timeString: existingSongTime)
                existingSong.extractMetaData(existingAsset)
                println(existingSong.fileURL)

                songArrayController.addObject(existingSong)
            }
        }
        else {
            println("File empty.")
        }
        
        println("\nLOAD COMPLETE.\n\n")
    }
    
    
    func saveLibrary()
    {
        let mainBundle = NSBundle.mainBundle()
        let path = mainBundle.pathForResource("songsList", ofType: "txt")
        
        var songsToWrite = ""
     
        println("SAVING...\n")
        
        // Cycle through songs and create one continuous string of their file paths
        for var i = 0; i < songArray.count; i++
        {
            if i != songArray.count - 1 {
                songsToWrite += songArray[i].fileURL + "," + songArray[i].dateAdded + "," + songArray[i].time + "\n"
            }
            else {
                songsToWrite += songArray[i].fileURL + "," + songArray[i].dateAdded + "," + songArray[i].time    // Don't append a "\n" to the last song in order to avoid loading a nil entry at start up
            }
        }
        
        songsToWrite.writeToFile(path!, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        println(songsToWrite)
        
        println("\nSAVE COMPLETE.\n\n")
    }
    
    
    func addSongs(songsToAdd: NSArray)
    {
        /* FUNCTION: isDirectory
        ** INPUT: NSURL
        ** RETURN: true if the NSURL is a directory, false if not a directory
        */
        func isDirectory(path: NSURL) -> Bool
        {
            let defaultFileManager = NSFileManager.defaultManager()
            var isDirectory: ObjCBool = ObjCBool(false)
            
            if defaultFileManager.fileExistsAtPath(path.path!, isDirectory: &isDirectory) {}
            
            if isDirectory { return true }
            else { return false }
        }
        
        
        /* FUNCTION: dirIterator
        ** INPUT: NSURL of a directory
        ** RETURN: An NSArray of NSURLS that were contained in the directory
        */
        func dirIterator(dir: NSURL) -> NSArray
        {
            let defaultFileManager = NSFileManager.defaultManager()
            let filelist = defaultFileManager.contentsOfDirectoryAtURL(dir, includingPropertiesForKeys: nil, options: nil, error: nil)

            return filelist!
        }
        
        
        /* FUNCTION: copySongToLibrary
        ** INPUT: Copies a song from the supplied NSURL to the library folder
        ** RETURN: URL to copy of file in library folder
        */
        func copySongToLibrary(sourceURL: NSURL) -> NSURL
        {
            let defaultFileManager = NSFileManager.defaultManager()
            
            // Get path to the Documents directory, then the library folder
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentsDirectory: AnyObject = paths[0]
            let dataPath = documentsDirectory.stringByAppendingPathComponent("VinylMusic")
            
            // If the library folder doesn't exist, create it
            if (!defaultFileManager.fileExistsAtPath(dataPath)) {
                defaultFileManager.createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil, error: nil)
            }
            
            // Get the file name from the end of the song to be copied and append it to the file path of the library folder
            let fileName = sourceURL.lastPathComponent?
            let dataPathWithFileName = "\(dataPath)/\(fileName!)"
            
            let dataURLWithFileName = NSURL(fileURLWithPath: dataPathWithFileName)
            
            // Copy the file to the new location
            defaultFileManager.copyItemAtURL(sourceURL, toURL: dataURLWithFileName!, error: nil)
            
            return dataURLWithFileName!
        }
        
        
        var songsToAddCopy = songsToAdd.mutableCopy() as NSMutableArray
        var lastURL = songsToAddCopy.lastObject as NSURL
        
        if lastURL.absoluteString != nil
        {
            if isDirectory(lastURL)
            {
                songsToAddCopy.removeLastObject()
                addSongs(dirIterator(lastURL))
                
                // 1 to skip the directory which is saved as the first element in the array
                if songsToAddCopy.count > 1 {
                    addSongs(songsToAddCopy)
                }
            }
            else
            {
                // Only add MP3 files
                if lastURL.pathExtension?.lowercaseString == "mp3"
                {
                    // Copy song and get its new URL
                    var newSongURL = copySongToLibrary(lastURL)
                    var newAsset = AVURLAsset(URL: newSongURL as NSURL, options: nil)
                    
                    let newSong = Song(newAsset: newAsset)
                    newSong.extractMetaData(newAsset)
                    println(newSong.trackNumber)
                    println(newSong.fileURL)
                    
                    songArrayController.addObject(newSong)
                }
                
                songsToAddCopy.removeLastObject()
                
                if songsToAddCopy.count > 0 {
                    addSongs(songsToAddCopy)
                }
            }
        }
    }
    
    
    @IBAction func addToLibrary(sender: NSMenuItem)
    {
        let addToLibraryOpenPanel = NSOpenPanel()
        addToLibraryOpenPanel.allowsMultipleSelection = true
        addToLibraryOpenPanel.canChooseDirectories = true
        addToLibraryOpenPanel.canChooseFiles = true
        
        // Only add songs if the user clicks OK
        if addToLibraryOpenPanel.runModal() == NSFileHandlingPanelOKButton
        {
            println("ADDING...\n")
            addSongs(addToLibraryOpenPanel.URLs)
            println("\nADD Complete.\n\n")
            
            saveLibrary()
        }
    }
    
    
    @IBAction func clickPlayToolbarItem(sender: NSToolbarItem)
    {
        let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
        
        if sender.image?.name() == "Play"
        {
            if firstSongPlayed == false {
                playSong(songArray[0].fileURL)
                firstSongPlayed = true
            }
            
            defaultNotificationCenter.postNotificationName("DisplayPauseImage", object: nil)
        }
        else    // Image must be "Pause"
        {
            if audioPlayer.playing == true {
                audioPlayer.pause()
                defaultNotificationCenter.postNotificationName("DisplayPlayImage", object: nil)
            }
            else {
                audioPlayer.play()
                defaultNotificationCenter.postNotificationName("DisplayPauseImage", object: nil)
            }
        }
    }
    
    
    func doubleClick()
    {
        let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
        
        // Ensure the double click occurs on a song in the table
        if songArrayTableView.selectedRow != -1
        {
            playSong(songArray[songArrayTableView.selectedRow].fileURL)
            
            if firstSongPlayed == false {
                firstSongPlayed = true
            }
            
            defaultNotificationCenter.postNotificationName("DisplayPauseImage", object: nil)
        }
    }
    
    
    func playSong(fileURL: String)
    {
        audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(string: fileURL), error: nil)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
}

