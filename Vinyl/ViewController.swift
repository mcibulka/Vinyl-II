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
    var audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(string: "x"), error: nil)
    
    
    
    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadLibrary:", name:"LoadSongs", object: nil)
    }
    
    
    func loadLibrary(notification: NSNotification)
    {
        println("LOADING...\n")
        
        let mainBundle = NSBundle.mainBundle()
        let path = mainBundle.pathForResource("songsList", ofType: "txt")
        
        let content = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        
        // If there are previously added songs, populate the song array
        if content != ""
        {
            let filePathArray = content!.componentsSeparatedByString("\n")

            for filePath in filePathArray
            {
                let songURL = NSURL(string: filePath)
                let asset = AVURLAsset(URL: songURL, options: nil)
                
                let song = Song(asset: asset)
                song.extractSongInfo(asset)
                println(song.fileURL)

                songArrayController.addObject(song)
            }
        }
        else {
            println("File empty.")
        }
        
        println("\nLOAD COMPLETE.\n\n")
    }
    
    
    func saveLibrary()
    {
        println("SAVING...\n")
        let mainBundle = NSBundle.mainBundle()
        let path = mainBundle.pathForResource("songsList", ofType: "txt")
        
        var songsToWrite = ""
        
        // Cycle through songs and create one continuous string of their file paths
        for var i = 0; i < songArray.count; i++
        {
            if i != songArray.count - 1 {
                songsToWrite += songArray[i].fileURL + "\n"
            }
            else {
                songsToWrite += songArray[i].fileURL    // Don't append a "\n" to the last song in order to avoid loading a nil entry at start up
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
            var isDirectory: ObjCBool = ObjCBool(false)
            
            if NSFileManager.defaultManager().fileExistsAtPath(path.path!, isDirectory: &isDirectory) {}
            
            if isDirectory {return true}
            else {return false}
        }
        
        
        /* FUNCTION: dirIterator
        ** INPUT: NSURL of a directory
        ** RETURN: An NSArray of NSURLS that were contained in the directory
        */
        func dirIterator(dir: NSURL) -> NSArray
        {
            let fileManager = NSFileManager.defaultManager()
            let filelist = fileManager.contentsOfDirectoryAtURL(dir, includingPropertiesForKeys: nil, options: nil, error: nil)

            return filelist!
        }
        
        
        /* FUNCTION: copySongToLibrary
        ** INPUT: Copies a song from the supplied NSURL to the library folder
        ** RETURN: URL to copy of file in library folder
        */
        func copySongToLibrary(sourceURL: NSURL) -> NSURL
        {
            let fileManager = NSFileManager.defaultManager()
            
            // Get path to Documents directory, then the library folder
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentsDirectory: AnyObject = paths[0]
            let dataPath = documentsDirectory.stringByAppendingPathComponent("VinylMusic")
            
            // If the library folder doesn't exist, create it
            if (!NSFileManager.defaultManager().fileExistsAtPath(dataPath)) {
                NSFileManager.defaultManager().createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil, error: nil)
            }
            
            // Get the file name from the end of the song to be copied and append it to the file path of the library folder
            let fileName = sourceURL.lastPathComponent?
            let dataPathWithFileName = "\(dataPath)/\(fileName!)"
            
            let dataURLWithFileName = NSURL(fileURLWithPath: dataPathWithFileName)
            
            // Copy the file to the new location
            fileManager.copyItemAtURL(sourceURL, toURL: dataURLWithFileName!, error: nil)
            
            return dataURLWithFileName!
        }
        
        
        var songsToAddCopy = songsToAdd.mutableCopy() as NSMutableArray
        var lastUrl = songsToAddCopy.lastObject as NSURL
        
        if lastUrl.absoluteString != nil
        {
            if isDirectory(lastUrl)
            {
                songsToAddCopy.removeLastObject()
                addSongs(dirIterator(lastUrl))
                
                // 1 to skip the directory which is saved as the first element in the array
                if songsToAddCopy.count > 1 {
                    addSongs(songsToAddCopy)
                }
            }
            else
            {
                // Copy song and get its new URL
                var newSongURL = copySongToLibrary(lastUrl)
                var asset = AVURLAsset(URL: newSongURL as NSURL, options: nil)

                let song = Song(asset: asset)
                song.extractSongInfo(asset)
                println(song.fileURL)
                
                songArrayController.addObject(song)
                
                songsToAddCopy.removeLastObject()
                
                if songsToAddCopy.count > 0 {
                    addSongs(songsToAddCopy)
                }
            }
        }
    }
    
    
    @IBAction func addToLibrary(sender: NSMenuItem)
    {
        let addFileOpenPanel = NSOpenPanel()
        addFileOpenPanel.allowsMultipleSelection = true
        addFileOpenPanel.canChooseDirectories = true
        addFileOpenPanel.canChooseFiles = true
        addFileOpenPanel.runModal()
        
        println("ADDING...\n")
        addSongs(addFileOpenPanel.URLs)
        println("\nADD Complete.\n\n")
        
        saveLibrary()
    }
    
    
    // should change function name to not confuse with "playTheSong" ... I didnt want to mess up the bindings
    @IBAction func playSong(sender: NSToolbarItem)
    {
        let mainBundle = NSBundle.mainBundle()

        if (songArrayTableView.selectedRowIndexes.count > 0) // If table row selection isnt nil
        {
            if (!audioPlayer.playing)
            {
                playTheSong(songArray[songArrayTableView.selectedRow].fileURL)
                sender.image = NSImage(byReferencingFile: mainBundle.pathForResource("Pause", ofType: ".png")!)
            }
            else
            {
                audioPlayer.pause()
                sender.image = NSImage(byReferencingFile: mainBundle.pathForResource("Play", ofType: ".png")!)
            }
        }
    }
    
    
    func doubleClick(){
        playTheSong(songArray[songArrayTableView.selectedRow].fileURL)
    }
    
    
    // Not the best name..
    func playTheSong(fileURL: String)
    {
        var error: NSError
        audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(string: fileURL), error: nil)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
}

