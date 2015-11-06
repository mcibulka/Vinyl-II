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
    var temporarySongArray = [Song]()
    
    var audioPlayer = AVAudioPlayer()
    let seekInterval = 15.0
    
    var firstSongPlayed = false
    var currentlyPlayingIndex = 0
    
    
    override func viewDidLoad()
    {
        let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
        defaultNotificationCenter.addObserver(self, selector: "loadLibrary:", name:"LoadLibrary", object: nil)
    }
    
    
    func loadLibrary(aNotification: NSNotification)
    {
        let mainBundle = NSBundle.mainBundle()
        let path = mainBundle.pathForResource("songsList", ofType: "txt")
        let songsListFileContent = try? String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        
        print("LOADING...\n")
        
        // If there are previously added songs, populate the song array
        if songsListFileContent != ""
        {
            let entryArray = songsListFileContent!.componentsSeparatedByString("\n")

            for entry in entryArray
            {
                let entryComponentsArray = entry.componentsSeparatedByString(";")
                let existingSongFileURL = entryComponentsArray[0]
                let existingSongDateAdded = entryComponentsArray[1]
                let existingSongTime = entryComponentsArray[2]
                
                let existingAsset = AVURLAsset(URL: NSURL(string: existingSongFileURL)!, options: nil)
                
                let existingSong = Song(fileURLString: existingSongFileURL, dateAddedString: existingSongDateAdded, timeString: existingSongTime)
                existingSong.extractMetaData(existingAsset)
                print(existingSong.fileURL)

                songArrayController.addObject(existingSong)
            }
        }
        else {
            print("File empty.")
        }
        
        print("\nLOAD COMPLETE.\n\n")
    }
    
    
    func saveLibrary()
    {
        let mainBundle = NSBundle.mainBundle()
        let path = mainBundle.pathForResource("songsList", ofType: "txt")
        
        var songsToWrite = ""
     
        print("\nSAVING...\n")
        
        // Cycle through songs and create one continuous string of their file paths
        for var i = 0; i < songArray.count; i++
        {
            if i != songArray.count - 1 {
                songsToWrite += songArray[i].fileURL + ";" + songArray[i].dateAdded + ";" + songArray[i].time + "\n"
            }
            else {
                songsToWrite += songArray[i].fileURL + ";" + songArray[i].dateAdded + ";" + songArray[i].time    // Don't append a "\n" to the last song in order to avoid loading a nil entry at start up
            }
        }
        
        do {
            try songsToWrite.writeToFile(path!, atomically: true, encoding: NSUTF8StringEncoding)
        } catch _ {
        }
        print(songsToWrite)
        
        print("\nSAVE COMPLETE.")
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
        
        
        /* FUNCTION: directoryIterator
        ** INPUT: NSURL of a directory
        ** RETURN: An NSArray of NSURLS that were contained in the directory
        */
        func directoryIterator(directory: NSURL) -> NSArray
        {
            let defaultFileManager = NSFileManager.defaultManager()
            let filelist = try? defaultFileManager.contentsOfDirectoryAtURL(directory, includingPropertiesForKeys: nil, options: [])

            return filelist!
        }
        
        
        /* FUNCTION: copySongToLibrary
        ** INPUT: Copies a song from the supplied NSURL to the library folder
        ** RETURN: none
        */
        func copySongToLibrary(sourceURL: NSURL, songToCopy: Song)
        {
            let defaultFileManager = NSFileManager.defaultManager()
            
            // Get path to the Documents directory, then the library folder
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentsDirectory: AnyObject = paths[0]
            var dataPath = documentsDirectory.stringByAppendingPathComponent("VinylMusic")
            
            // If the library folder doesn't exist, create it
            if (!defaultFileManager.fileExistsAtPath(dataPath)) {
                do {
                    try defaultFileManager.createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
                } catch _ {
                }
            }
            
            // Add artist to the path
            let albumArtistPathComponent = songToCopy.albumArtist!.stringByReplacingOccurrencesOfString("/", withString: ":")   // Ensure "/" are not interpreted as directories
            dataPath = (dataPath as NSString).stringByAppendingPathComponent(albumArtistPathComponent)
        
            // If the artist folder dosent exist, create it
            if (!defaultFileManager.fileExistsAtPath(dataPath)) {
                do {
                    try defaultFileManager.createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
                } catch _ {
                }
            }
            
            // Add album to the path
            let albumPathComponent = songToCopy.album!.stringByReplacingOccurrencesOfString("/", withString: ":")
            dataPath = (dataPath as NSString).stringByAppendingPathComponent(albumPathComponent)
            
            // If the album folder dosent exist, create it
            if (!defaultFileManager.fileExistsAtPath(dataPath)) {
                do {
                    try defaultFileManager.createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
                } catch _ {
                }
            }
            
            
            // Create own file name to ensure a consistent naming convention, "<Track Number><Space><Track Name>.mp3"
            var trackNumber = songToCopy.trackNumber!
            
            if trackNumber.characters.count == 1 {   // Track number is a single digit
                trackNumber.insert("0", atIndex: trackNumber.startIndex)
            }

            dataPath = (dataPath as NSString).stringByAppendingPathComponent(trackNumber)
            dataPath += " "
            
            let namePathComponent = songToCopy.name!.stringByReplacingOccurrencesOfString("/", withString: ":")
            dataPath += namePathComponent
            
            dataPath = (dataPath as NSString).stringByAppendingPathExtension("mp3")!
            
            
            let newSongURL = NSURL(fileURLWithPath: dataPath)
            songToCopy.fileURL = "\(newSongURL)"
            
            do {
                // Copy the song to the new location
                try defaultFileManager.copyItemAtURL(sourceURL, toURL: newSongURL)
            } catch _ {
            }
        }
        
        let songsToAddCopy = songsToAdd.mutableCopy() as! NSMutableArray
        let songURL = songsToAddCopy.lastObject as! NSURL
        
//        if songURL.absoluteString != nil
//        {
            if isDirectory(songURL)
            {
                songsToAddCopy.removeLastObject()
                addSongs(directoryIterator(songURL))
                
                // 1 to skip the directory which is saved as the first element in the array
                if songsToAddCopy.count > 1 {
                    addSongs(songsToAddCopy)
                }
            }
            else
            {
                // Only add MP3 files
                if songURL.pathExtension?.lowercaseString == "mp3"
                {
                    // Copy song and get its new URL
                    let newAsset = AVURLAsset(URL: songURL as NSURL, options: nil)
                    
                    let newSong = Song(newAsset: newAsset)
                    newSong.extractMetaData(newAsset)
                    
                    copySongToLibrary(songURL, songToCopy: newSong)

                    temporarySongArray.insert(newSong, atIndex: 0)
                }
                
                songsToAddCopy.removeLastObject()
                
                if songsToAddCopy.count > 0 {
                    addSongs(songsToAddCopy)
                }
            }
//        }
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
            print("ADDING...\n")
            addSongs(addToLibraryOpenPanel.URLs)
            
            if temporarySongArray.count > 0
            {
                songArrayController.addObjects(temporarySongArray)
                temporarySongArray.removeAll()

                saveLibrary()
            }
            
            print("\nADD Complete.\n\n")
        }
    }
    
    
    @IBAction func clickPrevious(sender: NSToolbarItem)
    {        
        if songArray.count > 0
        {
            currentlyPlayingIndex--
            
            // Jump from the start of the table to the end to loop playback
            if currentlyPlayingIndex == -1 {
                currentlyPlayingIndex = songArray.count - 1
            }
            
            if audioPlayer.playing {
                loadSongForPlayback(songArray[currentlyPlayingIndex].fileURL, beginPlaying: true)
            }
            else {
                loadSongForPlayback(songArray[currentlyPlayingIndex].fileURL, beginPlaying: false)
            }
        }
    }
    
    
    @IBAction func clickSeekBackward(sender: NSToolbarItem)
    {
        if songArray.count > 0
        {
            let seekTo = audioPlayer.currentTime - seekInterval
            
            if seekTo >= 0 {
                audioPlayer.currentTime = seekTo
            }
            else {
                audioPlayer.currentTime = audioPlayer.duration + seekTo     // seekTo is actually a negative number in this case, causing it to be subtracted from duration
            }
        }
    }
    
    
    @IBAction func clickPlay(sender: NSToolbarItem)
    {
        let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
        
        if sender.image?.name() == "Play"
        {
            if songArray.count > 0
            {
                if firstSongPlayed == false
                {
                    loadSongForPlayback(songArray[currentlyPlayingIndex].fileURL, beginPlaying: true)
                    firstSongPlayed = true
                    defaultNotificationCenter.postNotificationName("EnableOtherPlaybackButtons", object: nil)
                }
                
                defaultNotificationCenter.postNotificationName("DisplayPauseImage", object: nil)
            }
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
    
    
    @IBAction func clickSeekForward(sender: NSToolbarItem)
    {
        if songArray.count > 0
        {
            let seekTo = audioPlayer.currentTime + seekInterval
            
            if seekTo < audioPlayer.duration {
                audioPlayer.currentTime = seekTo
            }
            else if seekTo == audioPlayer.duration {
                audioPlayer.currentTime = 0
                audioPlayer.play()
            }
            else {
                audioPlayer.currentTime = seekTo - audioPlayer.duration
            }
        }
    }
    
    
    @IBAction func clickNext(sender: NSToolbarItem)
    {
        if songArray.count > 0
        {
            currentlyPlayingIndex++
            
            // Jump from the end of the table to the start to loop playback
            if currentlyPlayingIndex == songArray.count {
                currentlyPlayingIndex = 0
            }
            
            if audioPlayer.playing {
                loadSongForPlayback(songArray[currentlyPlayingIndex].fileURL, beginPlaying: true)
            }
            else {
                loadSongForPlayback(songArray[currentlyPlayingIndex].fileURL, beginPlaying: false)
            }
            
            
        }
    }
    
    
    func doubleClick()
    {
        let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
        
        // Ensure the double click occurs on a song in the table
        if songArrayTableView.selectedRow != -1
        {
            currentlyPlayingIndex = songArrayTableView.selectedRow
            loadSongForPlayback(songArray[currentlyPlayingIndex].fileURL, beginPlaying: true)
            
            if firstSongPlayed == false
            {
                defaultNotificationCenter.postNotificationName("EnableOtherPlaybackButtons", object: nil)
            
                firstSongPlayed = true
            }
            
            defaultNotificationCenter.postNotificationName("DisplayPauseImage", object: nil)
        }
    }
    
    
    func loadSongForPlayback(fileURL: String, beginPlaying: Bool)
    {
        audioPlayer = try! AVAudioPlayer(contentsOfURL: NSURL(string: fileURL)!)
        audioPlayer.prepareToPlay()
        
        if beginPlaying == true {
            audioPlayer.play()
        }
    }
}

