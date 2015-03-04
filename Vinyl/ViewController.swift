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
    
    var audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(string: "file:///Users/claytonrose/Google%20Drive/Vinyl/Sample%20Music%20Library/M4A/03%20Sun%20&%20Moon.m4a"), error: nil)
    
    let addFileOpenPanel = NSOpenPanel()
    var songArray = [Song]()
    var songsToSave = [NSString]()
    
    override func viewDidLoad() {
      //  NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadLibrary:", name:"LoadSongs", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveLibrary:", name:"SaveSongs", object: nil)
        println("BEFORE")
        println(songArray)
        
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
    
    func saveLibrary(notification: NSNotification){
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
                mySong.extractSongInfo(asset)
                
                //Add song to song array
                songArrayController.addObject(mySong)
                //songArray.append(mySong)
                
                //add to songsToSave
                println("Songs to add:\(songsToAdd[i].absoluteString)")
                songsToSave.append(songsToAdd[i].absoluteString!!)
            }
        }
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
        
        if audioPlayer.playing == false
        {
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            sender.image = NSImage(byReferencingFile: "/Users/claytonrose/Documents/Vinyl-II/Vinyl/Resources/Pause.png")
        }
        else
        {
            audioPlayer.pause()
            sender.image = NSImage(byReferencingFile: "/Users/claytonrose/Documents/Vinyl-II/Vinyl/Resources/Play.png")
        }
    }
}

