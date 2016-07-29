/*******************************************************************************************************************************************************************************
*
*   Project: Vinyl
*
*   Directory: Vinyl
*   File Name: MyNSToolbar.swift
*
*   Date Created: March 11, 2015
*   Created By: Matthew Cibulka
*
*   Copyright (c) 2016 Matthew Cibulka. All rights reserved.
*
*******************************************************************************************************************************************************************************/

import Cocoa

class MyNSToolbar: NSToolbar
{
    @IBOutlet weak var previous: NSToolbarItem!
    @IBOutlet weak var seekBackward: NSToolbarItem!
    @IBOutlet weak var playPause: NSToolbarItem!
    @IBOutlet weak var seekForward: NSToolbarItem!
    @IBOutlet weak var next: NSToolbarItem!
    
    
    override func validateVisibleItems() {
        let defaultNC = NotificationCenter.default()
        defaultNC.addObserver(self, selector: #selector(MyNSToolbar.enableOtherPlaybackButtons(_:)), name:"EnableOtherPlaybackButtons", object: nil)
        defaultNC.addObserver(self, selector: #selector(MyNSToolbar.displayPauseImage(_:)), name:"DisplayPauseImage", object: nil)
        defaultNC.addObserver(self, selector: #selector(MyNSToolbar.displayPlayImage(_:)), name:"DisplayPlayImage", object: nil)
    }
    
    
    func enableOtherPlaybackButtons(_ aNotification:Notification) {
        previous.isEnabled = true
        seekBackward.isEnabled = true
        seekForward.isEnabled = true
        next.isEnabled = true
    }
    
    
    func displayPauseImage(_ aNotification:Notification) {
        playPause.image = NSImage(byReferencingFile: Bundle.main().pathForResource("Pause", ofType:".png")!)
    }
    
    
    func displayPlayImage(_ aNotification:Notification) {
        playPause.image = NSImage(byReferencingFile: Bundle.main().pathForResource("Play", ofType:".png")!)
    }
}
