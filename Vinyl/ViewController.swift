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
*   Copyright (c) 2016 Matthew Cibulka. All rights reserved.
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
        let defaultNotificationCenter = NotificationCenter.default()
        defaultNotificationCenter.addObserver(self, selector:#selector(ViewController.loadLibrary(_:)), name:"LoadLibrary", object:nil)
    }
    
    
    func loadLibrary(_ aNotification:Notification)
    {
        let mainBundle = Bundle.main()
        let path = mainBundle.pathForResource("songsList", ofType: "txt")
        let songsListFileContent = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        
        print("LOADING...\n")
        
        // If there are previously added songs, populate the song array
        if songsListFileContent != ""
        {
            let entryArray = songsListFileContent!.components(separatedBy: "\n")

            for entry in entryArray
            {
                let entryComponentsArray = entry.components(separatedBy: ";")
                let existingSongFileURL = entryComponentsArray[0]
                let existingSongDateAdded = entryComponentsArray[1]
                let existingSongTime = entryComponentsArray[2]
                
                let existingAsset = AVURLAsset(url: URL(string: existingSongFileURL)!, options: nil)
                
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
        let mainBundle = Bundle.main()
        let path = mainBundle.pathForResource("songsList", ofType: "txt")
        
        var songsToWrite = ""
     
        print("\nSAVING...\n")
        
        // Cycle through songs and create one continuous string of their file paths
        for index in 0..<songArray.count
        {
            if index != songArray.count - 1 {
                songsToWrite += songArray[index].fileURL + ";" + songArray[index].dateAdded + ";" + songArray[index].time + "\n"
            }
            else {
                songsToWrite += songArray[index].fileURL + ";" + songArray[index].dateAdded + ";" + songArray[index].time    // Don't append a "\n" to the last song in order to avoid loading a nil entry at start up
            }
        }
        
        do {
            try songsToWrite.write(toFile: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch _ {
        }
        print(songsToWrite)
        
        print("\nSAVE COMPLETE.")
    }
    
    
    func addSongs(_ songsToAdd: NSArray)
    {
        /* FUNCTION: isDirectory
        ** INPUT: NSURL
        ** RETURN: true if the NSURL is a directory, false if not a directory
        */
        func isDirectory(_ path: URL) -> Bool
        {
            let defaultFileManager = FileManager.default()
            var isDirectory: ObjCBool = ObjCBool(false)
            
            if defaultFileManager.fileExists(atPath: path.path!, isDirectory: &isDirectory) {}
            
            if isDirectory { return true }
            else { return false }
        }
        
        
        /* FUNCTION: directoryIterator
        ** INPUT: NSURL of a directory
        ** RETURN: An NSArray of NSURLS that were contained in the directory
        */
        func directoryIterator(_ directory: URL) -> NSArray
        {
            let defaultFileManager = FileManager.default()
            let filelist = try? defaultFileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])

            return filelist!
        }
        
        
        /* FUNCTION: copySongToLibrary
        ** INPUT: Copies a song from the supplied NSURL to the library folder
        ** RETURN: none
        */
        func copySongToLibrary(_ sourceURL: URL, songToCopy: Song)
        {
            let defaultFM = FileManager.default()
            let desktopDir = try! defaultFM.urlForDirectory(.desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            var dataPath = desktopDir
            
            do {
                try dataPath.appendPathComponent("VinylLibrary", isDirectory: true)
            } catch {}
            
            
            /*Construct Copy To Path*/
            // Add artist to the path
            do {
                try dataPath.appendPathComponent(songToCopy.albumArtist!.replacingOccurrences(of: "/", with: ":"))   // Ensure "/" are not interpreted as directories
            } catch {}
            
            do {
                try defaultFM.createDirectory(at: dataPath, withIntermediateDirectories: false, attributes: nil)
            } catch {}
            
            do {
                try dataPath.appendPathComponent(songToCopy.album!.replacingOccurrences(of: "/", with: ":"))
            } catch {}
                
            do {
                try defaultFM.createDirectory(at: dataPath, withIntermediateDirectories: false, attributes: nil)
            } catch {}
        
            
            // Create own file name to ensure a consistent naming convention, "<Track Number><Space><Track Name>.mp3"
            var trackNumber = songToCopy.trackNumber!
            
            if trackNumber.characters.count == 1 {   // Track number is a single digit
                trackNumber.insert("0", at: trackNumber.startIndex)
            }
            
            do {
                try dataPath.appendPathComponent(trackNumber + " " + songToCopy.name!.replacingOccurrences(of: "/", with: ":"))
            } catch {}
            
            do {
                try dataPath.appendPathExtension("mp3")
            } catch {}
            
            songToCopy.fileURL = dataPath.absoluteString!
            
            do {
                try defaultFM.copyItem(at: sourceURL, to: dataPath)
            } catch {}
        }
        
        let songsToAddCopy = songsToAdd.mutableCopy() as! NSMutableArray
        let songURL = songsToAddCopy.lastObject as! URL
        
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
                if songURL.pathExtension?.lowercased() == "mp3"
                {
                    // Copy song and get its new URL
                    let newAsset = AVURLAsset(url: songURL as URL, options: nil)
                    
                    let newSong = Song(newAsset: newAsset)
                    newSong.extractMetaData(newAsset)
                    
                    copySongToLibrary(songURL, songToCopy: newSong)

                    temporarySongArray.insert(newSong, at: 0)
                }
                
                songsToAddCopy.removeLastObject()
                
                if songsToAddCopy.count > 0 {
                    addSongs(songsToAddCopy)
                }
            }
//        }
    }
    
    
    @IBAction func addToLibrary(_ sender: NSMenuItem)
    {
        let addToLibraryOpenPanel = NSOpenPanel()
        addToLibraryOpenPanel.allowsMultipleSelection = true
        addToLibraryOpenPanel.canChooseDirectories = true
        addToLibraryOpenPanel.canChooseFiles = true
        
        // Only add songs if the user clicks OK
        if addToLibraryOpenPanel.runModal() == NSFileHandlingPanelOKButton
        {
            print("ADDING...\n")
            addSongs(addToLibraryOpenPanel.urls)
            
            if temporarySongArray.count > 0
            {
                songArrayController.add(contentsOf: temporarySongArray)
                temporarySongArray.removeAll()

                saveLibrary()
            }
            
            print("\nADD Complete.\n\n")
        }
    }
    
    
    @IBAction func clickPrevious(_ sender: NSToolbarItem)
    {        
        if songArray.count > 0
        {
            if audioPlayer.currentTime > 1.0 {  // restart song from beginning
                audioPlayer.currentTime = 0
            }
            else
            {
                currentlyPlayingIndex -= 1
    
                // Jump from the start of the table to the end to loop playback
                if currentlyPlayingIndex == -1 {
                    currentlyPlayingIndex = songArray.count - 1
                }
    
                if audioPlayer.isPlaying {
                    loadSongForPlayback(songArray[currentlyPlayingIndex].fileURL, beginPlaying: true)
                }
                else {
                    loadSongForPlayback(songArray[currentlyPlayingIndex].fileURL, beginPlaying: false)
                }
            }
        }
    }
    
    
    @IBAction func clickSeekBackward(_ sender: NSToolbarItem)
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
    
    
    @IBAction func clickPlay(_ sender: NSToolbarItem)
    {
        let defaultNotificationCenter = NotificationCenter.default()
        
        if sender.image?.name() == "Play"
        {
            if songArray.count > 0
            {
                if firstSongPlayed == false
                {
                    loadSongForPlayback(songArray[currentlyPlayingIndex].fileURL, beginPlaying: true)
                    firstSongPlayed = true
                    defaultNotificationCenter.post(name: Notification.Name(rawValue: "EnableOtherPlaybackButtons"), object: nil)
                }
                
                defaultNotificationCenter.post(name: Notification.Name(rawValue: "DisplayPauseImage"), object: nil)
            }
        }
        else    // Image must be "Pause"
        {
            if audioPlayer.isPlaying == true {
                audioPlayer.pause()
                defaultNotificationCenter.post(name: Notification.Name(rawValue: "DisplayPlayImage"), object: nil)
            }
            else {
                audioPlayer.play()
                defaultNotificationCenter.post(name: Notification.Name(rawValue: "DisplayPauseImage"), object: nil)
            }
        }
    }
    
    
    @IBAction func clickSeekForward(_ sender: NSToolbarItem)
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
    
    
    @IBAction func clickNext(_ sender: NSToolbarItem)
    {
        if songArray.count > 0
        {
            currentlyPlayingIndex += 1
            
            // Jump from the end of the table to the start to loop playback
            if currentlyPlayingIndex == songArray.count {
                currentlyPlayingIndex = 0
            }
            
            if audioPlayer.isPlaying {
                loadSongForPlayback(songArray[currentlyPlayingIndex].fileURL, beginPlaying: true)
            }
            else {
                loadSongForPlayback(songArray[currentlyPlayingIndex].fileURL, beginPlaying: false)
            }
            
            
        }
    }
    
    
    func doubleClick()
    {
        let defaultNotificationCenter = NotificationCenter.default()
        
        // Ensure the double click occurs on a song in the table
        if songArrayTableView.selectedRow != -1
        {
            currentlyPlayingIndex = songArrayTableView.selectedRow
            loadSongForPlayback(songArray[currentlyPlayingIndex].fileURL, beginPlaying: true)
            
            if firstSongPlayed == false
            {
                defaultNotificationCenter.post(name: Notification.Name(rawValue: "EnableOtherPlaybackButtons"), object: nil)
            
                firstSongPlayed = true
            }
            
            defaultNotificationCenter.post(name: Notification.Name(rawValue: "DisplayPauseImage"), object: nil)
        }
    }
    
    
    func loadSongForPlayback(_ fileURL: String, beginPlaying: Bool)
    {
        audioPlayer = try! AVAudioPlayer(contentsOf: URL(string: fileURL)!)
        audioPlayer.prepareToPlay()
        
        if beginPlaying == true {
            audioPlayer.play()
        }
    }
}

