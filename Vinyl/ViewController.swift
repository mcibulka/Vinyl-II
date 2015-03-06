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
    
    var audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(string: "file:///Users/Matthew/Google%20Drive/Vinyl/Sample%20Music%20Library/M4A/03%20Sun%20&%20Moon.m4a"), error: nil)
    
    var songArray = [Song]()
    
    
    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadLibrary:", name:"LoadSongs", object: nil)
    }
    
    
    func loadLibrary(notification: NSNotification)
    {
        println("LOADING...\n")
        
        let mainBundle = NSBundle.mainBundle()
        let path = mainBundle.pathForResource("songsList", ofType: "txt")
        
        if path != nil
        {
            let content = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
            
            if content != ""
            {
                let filePathArray = content!.componentsSeparatedByString("\n")

                for filePath in filePathArray
                {
                    println(filePath)
                    let songURL = NSURL(string: filePath)
                    let asset = AVURLAsset(URL: songURL, options: nil)
                    
                    let mySong = Song(asset: asset)
                    mySong.extractSongInfo(asset)

                    songArrayController.addObject(mySong)
                }
            }
            else {
                println("File empty.")
            }
        }
        else {
            println("The file, \"songsList.txt\" could not be found.\n")
        }
        
        println("\nLOAD COMPLETE.\n\n")
    }
    
    
    func saveLibrary()
    {
        println("SAVING...\n")
        let mainBundle = NSBundle.mainBundle()
        let path = mainBundle.pathForResource("songsList", ofType: "txt")
        
        if path != nil
        {
            var songsToWrite = ""
            
            for var i = 0; i < songArray.count; i++
            {
                if i != songArray.count - 1 {
                    songsToWrite += songArray[i].fileURL + "\n"
                }
                else {
                    songsToWrite += songArray[i].fileURL
                }
            }
            
            songsToWrite.writeToFile(path!, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
            println(songsToWrite)
        }
        else {
            println("The file, \"songsList.txt\" could not be found.")
        }
        
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
            let filelist = fileManager.contentsOfDirectoryAtURL(dir, includingPropertiesForKeys: nil, options: nil, error: nil)
            /*for filepath in filelist! {
            println(filepath)
            }*/
            return filelist!
        }
        
        
        /* FUNCTION: copySongToLibrary
        ** INPUT: Copies a song from the supplied NSURL to the library folder
        ** RETURN: URL to copy of file in library folder
        */
        func copySongToLibrary(sourceURL: NSURL) -> NSURL
        {
            let fileManager = NSFileManager.defaultManager()
            
            // Get path to documents directory... then our library folder
            var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            var documentsDirectory: AnyObject = paths[0]
            var dataPath = documentsDirectory.stringByAppendingPathComponent("VinylMusic")
            
            // If the folder isnt already there, create it
            if (!NSFileManager.defaultManager().fileExistsAtPath(dataPath)) {
                NSFileManager.defaultManager().createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil, error: nil)
            }
            var error: NSError?
            
            // Get the filename from the end of the sourceURL and append it to the datapath
            var fileName = sourceURL.lastPathComponent?
            var dataPathWithFileName = "\(dataPath)/\(fileName!)"
            
            let dataURLWithFileName = NSURL(fileURLWithPath: dataPathWithFileName)
            
            // Copy the file to the new location
            fileManager.copyItemAtURL(sourceURL, toURL: dataURLWithFileName!, error:&error)
//            println(error)
            
            return dataURLWithFileName!
        }
        
        
        var songsToAddCopy = songsToAdd.mutableCopy() as NSMutableArray
        var lastUrl: NSURL = songsToAddCopy.lastObject as NSURL
        
        
        //subpathsOfDirectoryAtPath()
        if lastUrl.absoluteString != nil
        {
            if isDirectory(lastUrl)
            {
                //println("It was a dir")
                songsToAddCopy.removeLastObject()
                addSongs(dirIterator(lastUrl))
                
                // 1 to skip the dir which is saved as first elem. in array
                if songsToAddCopy.count > 1 {
                    addSongs(songsToAddCopy)
                }
            }
            else
            {
                //copy song and get new URL
                var newSongURL = copySongToLibrary(lastUrl)
                
                // Extract song info
                var asset = AVURLAsset(URL: newSongURL as NSURL, options: nil)
                //println("URL: \(asset)")
                let mySong = Song(asset: asset)
                mySong.extractSongInfo(asset)
                
                //Add song to song array
                songArrayController.addObject(mySong)
                
                //add to songsToSave
                //println("Songs to add:\(lastUrl.absoluteString)")
//                songsToSave.append(newSongURL.absoluteString!)
                songsToAddCopy.removeLastObject()
                if songsToAddCopy.count > 0 {
                    addSongs(songsToAddCopy)
                }
            }
        }
    }
    
    
    @IBAction func addToLibrary(sender: AnyObject)
    {
        let addFileOpenPanel = NSOpenPanel()
        
        addFileOpenPanel.allowsMultipleSelection = true
        addFileOpenPanel.canChooseDirectories = true
        addFileOpenPanel.canChooseFiles = true
        addFileOpenPanel.runModal()
        
        println("ADDING...\n")

        addSongs(addFileOpenPanel.URLs)
        
        println("ADD Complete.\n\n")
        
        saveLibrary()
    }
    
    
    @IBAction func playSong(sender: NSToolbarItem)
    {
        let mainBundle = NSBundle.mainBundle()
        
        if audioPlayer.playing == false
        {
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            sender.image = NSImage(byReferencingFile: mainBundle.pathForResource("Pause", ofType: ".png")!)
        }
        else
        {
            audioPlayer.pause()
            sender.image = NSImage(byReferencingFile: mainBundle.pathForResource("Play", ofType: ".png")!)
        }
    }
}

