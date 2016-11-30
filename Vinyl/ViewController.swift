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

class ViewController: NSViewController, NSTableViewDelegate, AVAudioPlayerDelegate
{
    @IBOutlet weak var songsTable: NSTableView!
    @IBOutlet var songsController: NSArrayController!
    
    var player = AVAudioPlayer()
    
    var songs = [Song]()
    
    var playlist = [Int]()
    var p = 0
    
    var played = [Bool]()
    let seek = 15.0
    
    var firstPlay = false
    var repeatOff = true
    var repeatSingle = false
    var repeatAll = false
    var shuffle = false
    
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector:#selector(ViewController.loadLibrary(_:)), name:NSNotification.Name(rawValue: "LoadLibrary"), object:nil)
    }
    
    
    func loadLibrary(_ aNotification:Notification) {
        func buildPlaylist()
        {
            for i in 0...songs.count - 1 {
                playlist.append(i)
            }
        }
        
        
        let path = Bundle.main.path(forResource:"songsList", ofType:"txt")
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
                    played.append(false)
                }
                
                buildPlaylist()
                cueSong(play:false)
                songsTable.selectRowIndexes(IndexSet(integer:p), byExtendingSelection:false)
            }
        }
        catch let error as NSError {
            print("Error loading library data from songsList. Other. Domain: \(error.domain), Code: \(error.code)")
        }
    }
    
    
    func saveLibrary() {
        let path = Bundle.main.path(forResource:"songsList", ofType:"txt")
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
            let defaultFM = FileManager.default
            let desktop = try! defaultFM.url(for:.desktopDirectory, in:.userDomainMask, appropriateFor:nil, create:false)
            var path = desktop
            
            path.appendPathComponent("VinylLibrary", isDirectory:true)

            
            /*Construct Copy To Path*/
            path.appendPathComponent(song.albumArtist!.replacingOccurrences(of:"/", with:":"))   // Ensure '/' are not interpreted as directories
            
            do {
                try defaultFM.createDirectory(at:path, withIntermediateDirectories:false, attributes:nil)
            }
            catch CocoaError.fileWriteFileExists {}  // do nothing
            catch CocoaError.fileWriteNoPermission {
                print("Error creating Album Artist directory in library folder. File write permissions.")
            }
            catch let error as NSError {
                print("Error creating Album Artist directory in library folder. Other. Domain: \(error.domain), Code: \(error.code)")
            }
            
                
            path.appendPathComponent(song.album!.replacingOccurrences(of:"/", with:":"))
                
            do {
                try defaultFM.createDirectory(at:path, withIntermediateDirectories:false, attributes:nil)
            }
            catch CocoaError.fileWriteFileExists {}  // do nothing
            catch CocoaError.fileWriteNoPermission {
                print("Error creating Album directory in library folder. File write permissions.")
            }
            catch let error as NSError {
                print("Error creating Album directory in library folder. Other. Domain: \(error.domain), Code: \(error.code)")
            }
            
            
            // Create own file name to ensure a consistent naming convention, "<Track Number><Space><Track Name>.<Format>"
            var trackNumber = song.trackNumber!
            
            if trackNumber.characters.count == 1 { trackNumber.insert("0", at:trackNumber.startIndex) }   // Track number is a single digit
            
            path.appendPathComponent(trackNumber + " " + song.name!.replacingOccurrences(of:"/", with:":"))
            path.appendPathExtension(song.format)
            
            song.path = path.absoluteString
            
            do {
                try defaultFM.copyItem(at:source, to:path)
            }
            catch CocoaError.fileWriteFileExists {}  // do nothing
            catch CocoaError.fileWriteNoPermission {
                print("Error copying song to Vinyl Library. File write permissions.")
            }
            catch CocoaError.fileWriteOutOfSpace {
                print("Error copying song to Vinyl Library. Out of space.")
            }
            catch let error as NSError {
                print("Error copying song to Vinyl Library. Other. Domain: \(error.domain) Code: \(error.code)")
            }
        }

        let localFM = FileManager()
        let resourceKeys = [URLResourceKey.isDirectoryKey, URLResourceKey.nameKey]
        let directoryEnumerator = localFM.enumerator(at:songsToAdd[0] as! URL, includingPropertiesForKeys:resourceKeys, options:[.skipsHiddenFiles, .skipsPackageDescendants], errorHandler:nil)!
        
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
                played.append(false)
            }
        }
    }
    
    
    @IBAction func addToLibrary(_ sender:NSMenuItem) {
        let addPanel = NSOpenPanel()
        addPanel.canChooseDirectories = true
        
        // Only add songs if the user clicks OK
        if addPanel.runModal() == NSFileHandlingPanelOKButton { addSongs(addPanel.urls as NSArray) }
        saveLibrary()
    }
    
    
    @IBAction func clickPrevious(_ sender:NSToolbarItem) {
        func cue() {
            if player.isPlaying {
                cueSong(play:true)
            }
            else {
                cueSong(play:false)
            }
        }
        
        
        if player.currentTime > 1.0 { player.currentTime = 0.0 }  // single click will start song from beginning
        else {  // double click intends to play previous song
            if repeatOff {
                if p != 0 {
                    p -= 1
                    cue()
                }
            }
            
            if repeatSingle {
                player.currentTime = 0.0
            }
            
            if repeatAll {
                if p == 0 {                 // repeat from end of table if first song is currently playing
                    p = playlist.count      // NOTE: index value corrected after condition exits
                }
                
                p -= 1
                cue()
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
        let defaultNC = NotificationCenter.default
        
        if sender.image?.name() == "Play" {
            if songs.count > 0 {
                if !firstPlay {
                    cueSong(play:true)
                    firstPlay = true
                    defaultNC.post(name:Notification.Name(rawValue:"EnableOtherPlaybackButtons"), object:nil)
                }
                
                defaultNC.post(name:Notification.Name(rawValue:"DisplayPauseImage"), object:nil)
            }
        }
        else {  // Image must be "Pause"
            if player.isPlaying {
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
        func cue() {
            if player.isPlaying {
                cueSong(play:true)
            }
            else {
                cueSong(play:false)
            }
        }
        
        
        if repeatOff {
            p += 1
            cue()
        }
        
        if repeatSingle {
            player.currentTime = 0.0
        }
        
        if repeatAll {
            if p == playlist.count - 1 {   // repeat from start of table if last song is currently playing
                p = -1                     // NOTE: index value corrected after condition exits
            }
            
            p += 1
            cue()
        }
    }
    
    
    @IBAction func clickRepeat(_ sender:NSToolbarItem) {
        let defaultNC = NotificationCenter.default
        
        if sender.image?.name() == "Repeat" {
            defaultNC.post(name:Notification.Name(rawValue:"DisplayRepeatSingleImage"), object:nil)
            defaultNC.post(name:Notification.Name(rawValue:"CheckNextEnabled"), object:nil)
            repeatSingle = true
            repeatOff = false
        }
        else if sender.image?.name() == "Repeat-Single" {
            defaultNC.post(name:Notification.Name(rawValue:"DisplayRepeatAllImage"), object:nil)
            repeatSingle = false
            repeatAll = true
            repeatOff = false
        }
        else {  // Must be "Repeat-All"
            defaultNC.post(name:Notification.Name(rawValue:"DisplayRepeatImage"), object:nil)
            
            if p == songs.count - 1 {
                defaultNC.post(name:Notification.Name(rawValue:"DisableNext"), object:nil)
            }
            
            repeatSingle = false
            repeatAll = false
            repeatOff = true
        }
    }
    
    
    @IBAction func clickShuffle(_ sender:NSToolbarItem) {
        let defaultNC = NotificationCenter.default
        
        if sender.image?.name() == "Shuffle-Off" {
            defaultNC.post(name:Notification.Name(rawValue:"DisplayShuffleOnImage"), object:nil)
            shuffle = true
            shufflePlaylist()
        }
        else {  // Must be "Shuffle-On"
            defaultNC.post(name:Notification.Name(rawValue:"DisplayShuffleOffImage"), object:nil)
            shuffle = false
        }
    }
    
    
    func shufflePlaylist() {
        playlist.removeAll(keepingCapacity:true)
        playlist.append(p)     // first song is song currently playing / cued
        played[p] = true
        
        for _ in 1...songs.count {
            repeat {
                let r = Int(arc4random_uniform(UInt32(songs.count)) + 0)
                
                if played[r] == false {
                    playlist.append(r)
                    played[r] = true
                }
            } while played.contains(false)
        }
    }
    
    
    func doubleClick() {
        let defaultNC = NotificationCenter.default
        
        if songsTable.selectedRow != -1 {   // ensure double click occurs on a song within table
            p = songsTable.selectedRow
            cueSong(play:true)
            
            if !firstPlay {
                defaultNC.post(name:Notification.Name(rawValue:"EnableOtherPlaybackButtons"), object:nil)
                firstPlay = true
            }
            
            if p == songs.count - 1 {
                if repeatOff {
                    defaultNC.post(name:Notification.Name(rawValue:"DisableNext"), object:nil)
                }
            }
            
            songsTable.selectRowIndexes(IndexSet(integer:p), byExtendingSelection:false)
            defaultNC.post(name:Notification.Name(rawValue:"DisplayPauseImage"), object:nil)
        }
    }
    
    
    func cueSong(play:Bool) {
        songsTable.selectRowIndexes(IndexSet(integer:playlist[p]), byExtendingSelection:false)
        
        do {
            try player = AVAudioPlayer(contentsOf:URL(string:songs[playlist[p]].path)!)
			player.delegate = self
            player.prepareToPlay()
            
            if play == true {
                player.play()
            }
        }
        catch let error as NSError {
            print("Error with audio player. Other. Domain: \(error.domain) Code: \(error.code)")
        }
    }

    
    func lastPlayed() {
        let defaultNC = NotificationCenter.default
        
        songsTable.deselectRow(p)
        defaultNC.post(name:Notification.Name(rawValue:"DisplayPlayImage"), object:nil)
        defaultNC.post(name:Notification.Name(rawValue:"DisableOtherPlaybackButtons"), object:nil)
    }
    
    
    func audioPlayerDidFinishPlaying(_ player:AVAudioPlayer, successfully flag:Bool) {
        if flag {
            if repeatSingle {
                cueSong(play:true)
            }
            else {
                p += 1

                if p < playlist.count {
                    cueSong(play:true)
                }
                else {
                    if repeatAll {
                        p = 0
                        cueSong(play:true)
                    }
                    
                    if repeatOff {
                        lastPlayed()
                    }
                }
            }
        }
    }
    
    
    func audioPlayerDecodeErrorDidOccur(_ player:AVAudioPlayer, error:Error?) {
        print("Error with audio player. Decode.")
    }
}
