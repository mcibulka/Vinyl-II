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

import AVFoundation
import Cocoa

class ViewController: NSViewController, AVAudioPlayerDelegate
{
    @IBOutlet weak var songsTable: NSTableView!
    @IBOutlet var songsController: NSArrayController!
    
    var player = AVAudioPlayer()
    
    var songs = [Song]()
    let seek = 15.0
    
    var firstPlay = false
    var repeatSingle = false
    var repeatAll = false
    var p = 0
    
    
    override func viewDidLoad() {
        NotificationCenter.default().addObserver(self, selector:#selector(ViewController.loadLibrary(_:)), name:"LoadLibrary", object:nil)
    }
    
    
    func loadLibrary(_ aNotification:Notification) {
        let path = Bundle.main().pathForResource("songsList", ofType:"txt")
        do {
            let contents = try String(contentsOfFile:path!, encoding:String.Encoding.utf8)
            
            // If there are previously added songs, populate the song array
            if contents != "" {
                let entries = contents.components(separatedBy:"\n")
                
                for entry in entries {
                    let components = entry.components(separatedBy:";")
                    let path = components[0]
                    let dateAdded = components[1]
                    let time = components[2]
                    let format = components[3]
                    
                    let asset = AVURLAsset(url:URL(string:path)!, options:nil)
                    let song = Song(path, dateAdded, time, format)
                    song.extractMetaData(asset)
                    songsController.addObject(song)
                }
            }
        }
        catch let error as NSError {
            print("Error loading library data from songsList. Other. Domain: \(error.domain), Code: \(error.code)")
        }
    }
    
    
    func saveLibrary() {
        let path = Bundle.main().pathForResource("songsList", ofType:"txt")
        var contents = ""
        
        // Cycle through songs and create one continuous string of their file paths
        for i in 0..<songs.count {
            if i != songs.count - 1 { contents += songs[i].path+";"+songs[i].dateAdded+";"+songs[i].time+";"+songs[i].format+"\n" }
            else { contents += songs[i].path+";"+songs[i].dateAdded+";"+songs[i].time+";"+songs[i].format }    // Don't append a "\n" to the last song in order to avoid loading a nil entry at start up
        }
        do {
            try contents.write(toFile:path!, atomically:true, encoding:String.Encoding.utf8)
        }
        catch let error as NSError {
            print("Error saving library data to songsList. Other. Domain: \(error.domain), Code: \(error.code)")
        }
    }
    
    
    func addSongs(_ songsToAdd:NSArray) {
        func copySongToLibrary(source:URL, song:Song) {
            let defaultFM = FileManager.default()
            let desktop = try! defaultFM.urlForDirectory(.desktopDirectory, in:.userDomainMask, appropriateFor:nil, create:false)
            var path = desktop
            
            try! path.appendPathComponent("VinylLibrary", isDirectory:true)

            
            /*Construct Copy To Path*/
            try! path.appendPathComponent(song.albumArtist!.replacingOccurrences(of:"/", with:":"))   // Ensure "/" are not interpreted as directories
            
            do {
                try defaultFM.createDirectory(at:path, withIntermediateDirectories:false, attributes:nil)
            }
            catch NSCocoaError.fileWriteFileExistsError {}  // do nothing
            catch NSCocoaError.fileWriteNoPermissionError {
                print("Error creating Album Artist directory in library folder. File write permissions.")
            }
            catch let error as NSError {
                print("Error creating Album Artist directory in library folder. Other. Domain: \(error.domain), Code: \(error.code)")
            }
            
                
            try! path.appendPathComponent(song.album!.replacingOccurrences(of:"/", with:":"))
                
            do {
                try defaultFM.createDirectory(at:path, withIntermediateDirectories:false, attributes:nil)
            }
            catch NSCocoaError.fileWriteFileExistsError {}  // do nothing
            catch NSCocoaError.fileWriteNoPermissionError {
                print("Error creating Album directory in library folder. File write permissions.")
            }
            catch let error as NSError {
                print("Error creating Album directory in library folder. Other. Domain: \(error.domain), Code: \(error.code)")
            }
            
            
            // Create own file name to ensure a consistent naming convention, "<Track Number><Space><Track Name>.mp3"
            var trackNumber = song.trackNumber!
            
            if trackNumber.characters.count == 1 { trackNumber.insert("0", at:trackNumber.startIndex) }   // Track number is a single digit
            
            try! path.appendPathComponent(trackNumber + " " + song.name!.replacingOccurrences(of:"/", with:":"))
            try! path.appendPathExtension(song.format)
            
            song.path = path.absoluteString!
            
            do {
                try defaultFM.copyItem(at:source, to:path)
            }
            catch NSCocoaError.fileWriteFileExistsError {}  // do nothing
            catch NSCocoaError.fileWriteNoPermissionError {
                print("Error copying song to Vinyl Library. File write permissions.")
            }
            catch NSCocoaError.fileWriteOutOfSpaceError {
                print("Error copying song to Vinyl Library. Out of space.")
            }
            catch let error as NSError {
                print("Error copying song to Vinyl Library. Other. Domain: \(error.domain) Code: \(error.code)")
            }
        }

        let localFM = FileManager()
        let resourceKeys = [URLResourceKey.isDirectoryKey, URLResourceKey.nameKey]
        let resourceKeysStr = [URLResourceKey.isDirectoryKey.rawValue, URLResourceKey.nameKey.rawValue]
        let directoryEnumerator = localFM.enumerator(at:songsToAdd[0] as! URL, includingPropertiesForKeys:resourceKeysStr, options:[.skipsHiddenFiles, .skipsPackageDescendants], errorHandler:nil)!
        
        var fileURLs: [NSURL] = []
        for case let fileURL as NSURL in directoryEnumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys:resourceKeys),
                let isDirectory = resourceValues[URLResourceKey.isDirectoryKey] as? Bool,
                let name = resourceValues[URLResourceKey.nameKey] as? String
                else { continue }
            
            if isDirectory { if name == "_extras" { directoryEnumerator.skipDescendants() } }
            else { fileURLs.append(fileURL) }
        }
        
        for fileURL in fileURLs {
            let format = fileURL.pathExtension!.lowercased()
            let formats: Set = ["mp3", "m4a"]
            if formats.contains(format)     // Copy song and get its new URL
            {
                let asset = AVURLAsset(url:fileURL as URL, options:nil)
                
                let song = Song(asset, format)
                song.extractMetaData(asset)
                copySongToLibrary(source:fileURL as URL, song:song)
                songsController.addObject(song)
            }
        }
    }
    
    
    @IBAction func addToLibrary(_ sender:NSMenuItem) {
        let addPanel = NSOpenPanel()
        addPanel.canChooseDirectories = true
        
        // Only add songs if the user clicks OK
        if addPanel.runModal() == NSFileHandlingPanelOKButton { addSongs(addPanel.urls) }
        saveLibrary()
    }
    
    
    @IBAction func clickPrevious(_ sender:NSToolbarItem) {
        if songs.count > 0 {
            if player.currentTime > 1.0 { player.currentTime = 0 }  // restart song from beginning
            else {
                p -= 1
    
                if p == -1 { p = songs.count - 1 }   // jump from start of table to end to loop playback
                
                if player.isPlaying { cueSong(songs[p].path, play:true) }
                else { cueSong(songs[p].path, play:false) }
                
                songsTable.selectRowIndexes(IndexSet(integer:p), byExtendingSelection:false)
            }
        }
    }
    
    
    @IBAction func clickSeekBackward(_ sender:NSToolbarItem) {
        if songs.count > 0
        {
            let seekTo = player.currentTime - seek
            
            if seekTo >= 0 { player.currentTime = seekTo }
            else { player.currentTime = player.duration + seekTo }    // seekTo is actually a negative number in this case, causing it to be subtracted from duration
        }
    }
    
    
    @IBAction func clickPlay(_ sender:NSToolbarItem) {
        let defaultNC = NotificationCenter.default()
        
        if sender.image?.name() == "Play" {
            if songs.count > 0 {
                if firstPlay == false {
                    cueSong(songs[p].path, play: true)
                    firstPlay = true
                    defaultNC.post(name:Notification.Name(rawValue:"EnableOtherPlaybackButtons"), object:nil)
                }
                
                defaultNC.post(name:Notification.Name(rawValue:"DisplayPauseImage"), object:nil)
                songsTable.selectRowIndexes(IndexSet(integer:p), byExtendingSelection:false)
            }
        }
        else {  // Image must be "Pause"
            if player.isPlaying == true {
                player.pause()
                defaultNC.post(name:Notification.Name(rawValue:"DisplayPlayImage"), object:nil)
            }
            else {
                player.play()
                defaultNC.post(name:Notification.Name(rawValue:"DisplayPauseImage"), object:nil)
            }
        }
    }
    
    
    @IBAction func clickSeekForward(_ sender:NSToolbarItem) {
        if songs.count > 0 {
            let seekTo = player.currentTime + seek
            
            if seekTo < player.duration { player.currentTime = seekTo }
            else if seekTo == player.duration {
                player.currentTime = 0
                player.play()
            }
            else { player.currentTime = seekTo - player.duration }
        }
    }
    
    
    @IBAction func clickNext(_ sender:NSToolbarItem) {
        if songs.count > 0 {
            p += 1
        
            if p == songs.count { p = 0 }   // jump from end of table to start to loop playback
            
            if player.isPlaying { cueSong(songs[p].path, play:true) }
            else { cueSong(songs[p].path, play:false) }
            
            songsTable.selectRowIndexes(IndexSet(integer:p), byExtendingSelection:false)
        }
    }
    
    
    @IBAction func clickRepeat(_ sender:NSToolbarItem) {
        let defaultNC = NotificationCenter.default()
        
        if sender.image?.name() == "Repeat" {
            defaultNC.post(name:Notification.Name(rawValue:"DisplayRepeatSingleImage"), object:nil)
            repeatSingle = true
        }
        else if sender.image?.name() == "Repeat-Single" {
            defaultNC.post(name:Notification.Name(rawValue:"DisplayRepeatAllImage"), object:nil)
            repeatSingle = false
            repeatAll = true
        }
        else {  // Must be "Repeat-All"
            defaultNC.post(name:Notification.Name(rawValue:"DisplayRepeatImage"), object:nil)
            repeatSingle = false
            repeatAll = false
        }
    }
    
    
    func doubleClick() {
        let defaultNC = NotificationCenter.default()
        
        if songsTable.selectedRow != -1 {   // ensure double click occurs on a song within table
            p = songsTable.selectedRow
            cueSong(songs[p].path, play:true)
            
            if firstPlay == false {
                defaultNC.post(name:Notification.Name(rawValue:"EnableOtherPlaybackButtons"), object:nil)
                firstPlay = true
            }
            
            songsTable.selectRowIndexes(IndexSet(integer:p), byExtendingSelection:false)
            defaultNC.post(name:Notification.Name(rawValue:"DisplayPauseImage"), object:nil)
        }
    }
    
    
    func cueSong(_ fileURL:String, play:Bool) {
        do {
            try player = AVAudioPlayer(contentsOf:URL(string:fileURL)!)
			player.delegate = self
            player.prepareToPlay()
            
            if play == true { player.play() }
        }
        catch let error as NSError {
            print("Error with audio player. Other. Domain: \(error.domain) Code: \(error.code)")
        }
    }
    
    
    func audioPlayerDidFinishPlaying(_ player:AVAudioPlayer, successfully flag:Bool) {
        if flag == true {
            if repeatSingle == true {
                cueSong(songs[p].path, play:true)
            }
            else if repeatAll == true {
                p = 0
                cueSong(songs[p].path, play:true)
                songsTable.selectRowIndexes(IndexSet(integer:p), byExtendingSelection:false)
            }
            else {
                if p != songs.count-1 {
                    p += 1
                    cueSong(songs[p].path, play:true)
                    songsTable.selectRowIndexes(IndexSet(integer:p), byExtendingSelection:false)
                }
                else { NotificationCenter.default().post(name:Notification.Name(rawValue:"DisplayPlayImage"), object:nil) }
            }
        }
    }
    
    
    func audioPlayerDecodeErrorDidOccur(_ player:AVAudioPlayer, error:NSError?) {
        print("Error with audio player. Decode.")
    }
}
