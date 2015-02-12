/*******************************************************************************************************************************************************************************
*
*   Project: Vinyl
*
*   Directory: Vinyl
*   File Name: ToolbarController.swift
*
*   Date Created: February 7, 2015
*   Created By: Matthew Cibulka
*
*   Copyright (c) 2015 Matthew Cibulka. All rights reserved.
*
*******************************************************************************************************************************************************************************/

import Cocoa
import AVFoundation

class ToolbarController: NSToolbar
{
    @IBOutlet weak var playToolbarItem: NSToolbarItem!
    
    var audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(string: "file:///Users/Matthew/Google%20Drive/Vinyl/Sample%20Music%20Library/M4A/03%20Sun%20&%20Moon.m4a"), error: nil)
    
    
    @IBAction func playSong(sender: NSToolbarItem)
    {
        if audioPlayer.playing == false
        {
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
            playToolbarItem.image = NSImage(byReferencingFile: "/Users/Matthew/Documents/Projects/Vinyl-II/Vinyl/Resources/Pause.png")
        }
        else
        {
            audioPlayer.pause()
            playToolbarItem.image = NSImage(byReferencingFile: "/Users/Matthew/Documents/Projects/Vinyl-II/Vinyl/Resources/Play.png")
        }
    }
}
