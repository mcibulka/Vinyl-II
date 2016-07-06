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
    
    var songs = [Song]()
    var tempSongs = [Song]()
    
    var audioPlayer = AVAudioPlayer()
    let seekInterval = 15.0
    
    var firstPlay = false
    var playIndex = 0
    
    
    override func viewDidLoad() {
        NotificationCenter.default().addObserver(self, selector:#selector(ViewController.loadLibrary(_:)), name:"LoadLibrary", object:nil)
    }
    
    
    func loadLibrary(_ aNotification:Notification) {
        let path = Bundle.main().pathForResource("songsList", ofType: "txt")
        let contents = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        
        print("LOADING...\n")
        
        // If there are previously added songs, populate the song array
        if contents != "" {
            let entries = contents!.components(separatedBy: "\n")

            for entry in entries {
                let components = entry.components(separatedBy: ";")
                let songURL = components[0]
                let dateAdded = components[1]
                let songTime = components[2]
                
                let asset = AVURLAsset(url: URL(string: songURL)!, options: nil)
                
                let song = Song(fileURL: songURL, dateAdded: dateAdded, time: songTime)
                song.extractMetaData(asset)
                print(song.fileURL)

                songArrayController.addObject(song)
            }
        }
        else {
            print("File empty.")
        }
        
        print("\nLOAD COMPLETE.\n\n")
    }
    
    
    func saveLibrary() {
        let path = Bundle.main().pathForResource("songsList", ofType: "txt")
        var contents = ""
     
        print("\nSAVING...\n")
        
        // Cycle through songs and create one continuous string of their file paths
        for i in 0..<songs.count {
            if i != songs.count - 1 {
                contents += songs[i].fileURL + ";" + songs[i].dateAdded + ";" + songs[i].time + "\n"
            }
            else {
                contents += songs[i].fileURL + ";" + songs[i].dateAdded + ";" + songs[i].time    // Don't append a "\n" to the last song in order to avoid loading a nil entry at start up
            }
        }
        
        do {
            try contents.write(toFile: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {}
        print(contents)
        
        print("\nSAVE COMPLETE.")
    }
    
    
    func addSongs(_ songsToAdd: NSArray) {
        /* FUNCTION: isDirectory
        ** INPUT: NSURL
        ** RETURN: true if the NSURL is a directory, false if not a directory
        */
        func isDirectory(_ path: URL) -> Bool {
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
        func directoryIterator(_ directory: URL) -> NSArray {
            let defaultFileManager = FileManager.default()
            let filelist = try? defaultFileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])

            return filelist!
        }
        
        
        /* FUNCTION: copySongToLibrary
        ** INPUT: Copies a song from the supplied NSURL to the library folder
        ** RETURN: none
        */
        func copySongToLibrary(_ sourceURL: URL, songToCopy: Song) {
            let defaultFM = FileManager.default()
            let desktop = try! defaultFM.urlForDirectory(.desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            var path = desktop
            
            do {
                try path.appendPathComponent("VinylLibrary", isDirectory: true)
            } catch {}
            
            
            /*Construct Copy To Path*/
            // Add artist to the path
            do {
                try path.appendPathComponent(songToCopy.albumArtist!.replacingOccurrences(of: "/", with: ":"))   // Ensure "/" are not interpreted as directories
            } catch {}
            
            do {
                try defaultFM.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
            } catch {}
            
            do {
                try path.appendPathComponent(songToCopy.album!.replacingOccurrences(of: "/", with: ":"))
            } catch {}
                
            do {
                try defaultFM.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
            } catch {}
        
            
            // Create own file name to ensure a consistent naming convention, "<Track Number><Space><Track Name>.mp3"
            var trackNumber = songToCopy.trackNumber!
            
            if trackNumber.characters.count == 1 {   // Track number is a single digit
                trackNumber.insert("0", at: trackNumber.startIndex)
            }
            
            do {
                try path.appendPathComponent(trackNumber + " " + songToCopy.name!.replacingOccurrences(of: "/", with: ":"))
            } catch {}
            
            do {
                try path.appendPathExtension("mp3")
            } catch {}
            
            songToCopy.fileURL = path.absoluteString!
            
            do {
                try defaultFM.copyItem(at: sourceURL, to: path)
            } catch {}
        }
        
        let songsToAddCopy = songsToAdd.mutableCopy() as! NSMutableArray
        let songURL = songsToAddCopy.lastObject as! URL
        
//        if songURL.absoluteString != nil
//        {
            if isDirectory(songURL) {
                songsToAddCopy.removeLastObject()
                addSongs(directoryIterator(songURL))
                
                // 1 to skip the directory which is saved as the first element in the array
                if songsToAddCopy.count > 1 {
                    addSongs(songsToAddCopy)
                }
            }
            else {
                // Only add MP3 files
                if songURL.pathExtension?.lowercased() == "mp3"
                {
                    // Copy song and get its new URL
                    let newAsset = AVURLAsset(url: songURL as URL, options: nil)
                    
                    let newSong = Song(newAsset: newAsset)
                    newSong.extractMetaData(newAsset)
                    copySongToLibrary(songURL, songToCopy: newSong)
                    tempSongs.insert(newSong, at: 0)
                }
                
                songsToAddCopy.removeLastObject()
                
                if songsToAddCopy.count > 0 {
                    addSongs(songsToAddCopy)
                }
            }
//        }
    }
    
    
    @IBAction func addToLibrary(_ sender: NSMenuItem) {
        let addPanel = NSOpenPanel()
        addPanel.allowsMultipleSelection = true
        addPanel.canChooseDirectories = true
        addPanel.canChooseFiles = true
        
        // Only add songs if the user clicks OK
        if addPanel.runModal() == NSFileHandlingPanelOKButton {
            print("ADDING...\n")
            addSongs(addPanel.urls)
            
            if tempSongs.count > 0 {
                songArrayController.add(contentsOf: tempSongs)
                tempSongs.removeAll()
                saveLibrary()
            }
            
            print("\nADD Complete.\n\n")
        }
    }
    
    
    @IBAction func clickPrevious(_ sender: NSToolbarItem) {
        if songs.count > 0 {
            if audioPlayer.currentTime > 1.0 {  // restart song from beginning
                audioPlayer.currentTime = 0
            }
            else {
                playIndex -= 1
    
                if playIndex == -1 {    // jump from start of table to end to loop playback
                    playIndex = songs.count - 1
                }
    
                if audioPlayer.isPlaying {
                    cueSong(songs[playIndex].fileURL, play: true)
                }
                else {
                    cueSong(songs[playIndex].fileURL, play: false)
                }
            }
        }
    }
    
    
    @IBAction func clickSeekBackward(_ sender: NSToolbarItem) {
        if songs.count > 0
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
    
    
    @IBAction func clickPlay(_ sender: NSToolbarItem) {
        let defaultNC = NotificationCenter.default()
        
        if sender.image?.name() == "Play" {
            if songs.count > 0 {
                if firstPlay == false {
                    cueSong(songs[playIndex].fileURL, play: true)
                    firstPlay = true
                    defaultNC.post(name: Notification.Name(rawValue: "EnableOtherPlaybackButtons"), object: nil)
                }
                
                defaultNC.post(name: Notification.Name(rawValue: "DisplayPauseImage"), object: nil)
            }
        }
        else {  // Image must be "Pause"
            if audioPlayer.isPlaying == true {
                audioPlayer.pause()
                defaultNC.post(name: Notification.Name(rawValue: "DisplayPlayImage"), object: nil)
            }
            else {
                audioPlayer.play()
                defaultNC.post(name: Notification.Name(rawValue: "DisplayPauseImage"), object: nil)
            }
        }
    }
    
    
    @IBAction func clickSeekForward(_ sender: NSToolbarItem) {
        if songs.count > 0 {
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
    
    
    @IBAction func clickNext(_ sender: NSToolbarItem) {
        if songs.count > 0 {
            playIndex += 1
        
            if playIndex == songs.count {   // jump from end of table to start to loop playback
                playIndex = 0
            }
            
            if audioPlayer.isPlaying {
                cueSong(songs[playIndex].fileURL, play: true)
            }
            else {
                cueSong(songs[playIndex].fileURL, play: false)
            }
        }
    }
    
    
    func doubleClick() {
        let defaultNC = NotificationCenter.default()
        
        if songArrayTableView.selectedRow != -1 {   // ensure double click occurs on a song within table
            playIndex = songArrayTableView.selectedRow
            cueSong(songs[playIndex].fileURL, play: true)
            
            if firstPlay == false {
                defaultNC.post(name: Notification.Name(rawValue: "EnableOtherPlaybackButtons"), object: nil)
                firstPlay = true
            }
            
            defaultNC.post(name: Notification.Name(rawValue: "DisplayPauseImage"), object: nil)
        }
    }
    
    
    func cueSong(_ fileURL: String, play: Bool) {
        audioPlayer = try! AVAudioPlayer(contentsOf: URL(string: fileURL)!)
        audioPlayer.prepareToPlay()
        
        if play == true {
            audioPlayer.play()
        }
    }
}

