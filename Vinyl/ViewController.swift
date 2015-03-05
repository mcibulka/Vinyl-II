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
    
    let addFileOpenPanel = NSOpenPanel()
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
            let enumerator = fileManager.enumeratorAtURL(dir as NSURL, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: nil, errorHandler: nil)
            var urlArray = [NSURL]()
    
            while let element = enumerator?.nextObject() as? NSURL
            {
                println("Found a file")
                urlArray.append(element)
            }
            return urlArray
        }
        
        println("ADDING...\n")
        
        for var i = 0; i < songsToAdd.count; i++
        {
            var asset = AVURLAsset(URL: songsToAdd[i] as NSURL, options: nil)
            
            if isDirectory(songsToAdd[i] as NSURL) {
                addSongs(dirIterator(songsToAdd[i] as NSURL))
            }
            else if asset.URL != nil
            {
                let mySong = Song(asset: asset)
                mySong.extractSongInfo(asset)
                println(mySong.fileURL + "\n")
                
                songArrayController.addObject(mySong)
            }
        }
        
        println("ADD Complete.\n\n")
        
        saveLibrary()
    }
    
    
    @IBAction func addToLibrary(sender: AnyObject)
    {
        addFileOpenPanel.allowsMultipleSelection = true
        addFileOpenPanel.canChooseDirectories = true
        addFileOpenPanel.canChooseFiles = true
        addFileOpenPanel.runModal()

        addSongs(addFileOpenPanel.URLs)
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

