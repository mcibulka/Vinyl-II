/*******************************************************************************************************************************************************************************
*
*   Project: Vinyl
*
*   Directory: Vinyl
*   File Name: TableViewController
*
*   Date Created: January 20, 2015
*   Created By: Matthew Cibulka
*
*   Copyright (c) 2015 Matthew Cibulka. All rights reserved.
*
*******************************************************************************************************************************************************************************/

import Cocoa
import AVFoundation


class TableViewController: NSTableView
{
    @IBOutlet weak var TableView: NSTableView!

    var audioPlayer = AVAudioPlayer()
    
    var songArray = [
        Song(   album: "Group Therapy",
            albumArtist: "Above & Beyond",
            artist: "Above & Beyond feat. Richard Bedford",
            comments: "iTunes, Complete Album",
            composer: "N/A",
            dateAdded: "2011-06-12, 12:27 AM",
            genre: "Trance",
            grouping: "Ultra Records",
            name: "Sun & Moon",
            time: "5:26",
            year: "2011",
            fileURL: "file:///Users/Matthew/Google%20Drive/Vinyl/Sample%20Music%20Library/M4A/03%20Sun%20&%20Moon.m4a")
    ]
    
    func tableViewSelectionDidChange(notification: NSNotification)
    {
        // Play the song selected from the table
        TableView = notification.object as NSTableView
        let selection = TableView.selectedRow
        
        println(selection)
        
        
        /*
        //check selection is not an empty row
        //Table will return a -1 if the row is empty
        if selection >= 0 {
            var songURL :NSURL = songArray[selection].fileURL.URL!!
            audioPlayer = AVAudioPlayer(contentsOfURL: songURL, error: nil)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
        */
    }
}
