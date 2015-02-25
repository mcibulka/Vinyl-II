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
    var songsToSave = [String]()
    
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
}

