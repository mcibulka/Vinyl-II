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
    var tempSongArray = [Song]()
    
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
        
        
        /* FUNCTION: directoryIterator
        ** INPUT: NSURL of a directory
        ** RETURN: An NSArray of NSURLS that were contained in the directory
        */
        func directoryIterator(directory: NSURL) -> NSArray
        {
            let defaultFileManager = NSFileManager.defaultManager()
            let filelist = defaultFileManager.contentsOfDirectoryAtURL(directory, includingPropertiesForKeys: nil, options: nil, error: nil)

            return filelist!
        }
        
        
        /* FUNCTION: copySongToLibrary
        ** INPUT: Copies a song from the supplied NSURL to the library folder
        ** RETURN: URL to copy of file in library folder
        */
        func copySongToLibrary(sourceURL: NSURL, var albumArtist: String, var album: String, var name: String) -> NSURL
        {
            let defaultFileManager = NSFileManager.defaultManager()
            
            // Get path to the Documents directory, then the library folder
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentsDirectory: AnyObject = paths[0]
            var dataPath = documentsDirectory.stringByAppendingPathComponent("VinylMusic")
            
            // If the library folder doesn't exist, create it
            if (!defaultFileManager.fileExistsAtPath(dataPath)) {
                defaultFileManager.createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil, error: nil)
            }
            
            // Add artist to the path
            dataPath = dataPath.stringByAppendingPathComponent(albumArtist.lowercaseString)
            // If the artist folder dosent exist, create it
            if (!defaultFileManager.fileExistsAtPath(dataPath)) {
                defaultFileManager.createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil, error: nil)
            }
            
            // Add album to the path
            dataPath = dataPath.stringByAppendingPathComponent(album.lowercaseString)
            // If the album folder dosent exist, create it
            if (!defaultFileManager.fileExistsAtPath(dataPath)) {
                defaultFileManager.createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil, error: nil)
            }
            
            // Get the file name from the end of the song to be copied and append it to the file path
            let fileName = sourceURL.lastPathComponent?
            //let dataPathWithFileName = "\(dataPath)/\(fileName!)"
            
            
            dataPath = dataPath.stringByAppendingPathComponent(fileName!)
            let dataURLWithFileName = NSURL(fileURLWithPath: dataPath)
            
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
                addSongs(directoryIterator(lastURL))
                
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
                    //var newSongURL = copySongToLibrary(lastURL)
                    //var newAsset = AVURLAsset(URL: newSongURL as NSURL, options: nil)
                    var newAsset = AVURLAsset(URL: lastURL as NSURL, options: nil)
                    
                    let newSong = Song(newAsset: newAsset)
                    newSong.extractMetaData(newAsset)
                    
                    var newSongURL = copySongToLibrary(lastURL, newSong.albumArtist!, newSong.album!, newSong.name!)
                    newSong.fileURL = "\(newSongURL)"
                    println(newSong.fileURL)
                    tempSongArray.insert(newSong, atIndex: 0)
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
            println(addToLibraryOpenPanel.URLs)
            
            if tempSongArray.count > 0
            {
                songArrayController.addObjects(tempSongArray)
                tempSongArray.removeAll()
            }
            
            println("\nADD Complete.\n\n")
            
            saveLibrary()
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
            var seekTo = audioPlayer.currentTime - seekInterval
            
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
                    defaultNotificationCenter.postNotificationName("EnableOtherPlaybackControls", object: nil)
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
            var seekTo = audioPlayer.currentTime + seekInterval
            
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
                defaultNotificationCenter.postNotificationName("EnableOtherPlaybackControls", object: nil)
            
                firstSongPlayed = true
            }
            
            defaultNotificationCenter.postNotificationName("DisplayPauseImage", object: nil)
        }
    }
    
    
    func loadSongForPlayback(fileURL: String, beginPlaying: Bool)
    {
        audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(string: fileURL), error: nil)
        audioPlayer.prepareToPlay()
        
        if beginPlaying == true {
            audioPlayer.play()
        }
    }
}

