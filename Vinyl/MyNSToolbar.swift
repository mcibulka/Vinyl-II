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
    @IBOutlet weak var repeater: NSToolbarItem!
    @IBOutlet weak var shuffler: NSToolbarItem!
    
    
    override func validateVisibleItems() {
        let defaultNC = NotificationCenter.default
        defaultNC.addObserver(self, selector:#selector(MyNSToolbar.disableOtherPlaybackButtons(_:)), name:Notification.Name(rawValue:"DisableOtherPlaybackButtons"), object:nil)
        defaultNC.addObserver(self, selector:#selector(MyNSToolbar.enableOtherPlaybackButtons(_:)), name:Notification.Name(rawValue:"EnableOtherPlaybackButtons"), object:nil)
        
        defaultNC.addObserver(self, selector:#selector(MyNSToolbar.disableNext(_:)), name:Notification.Name(rawValue:"DisableNext"), object:nil)
        defaultNC.addObserver(self, selector:#selector(MyNSToolbar.checkNextEnabled(_:)), name:Notification.Name(rawValue:"CheckNextEnabled"), object:nil)
        
        defaultNC.addObserver(self, selector:#selector(MyNSToolbar.displayPauseImage(_:)), name:Notification.Name(rawValue:"DisplayPauseImage"), object:nil)
        defaultNC.addObserver(self, selector:#selector(MyNSToolbar.displayPlayImage(_:)), name:Notification.Name(rawValue:"DisplayPlayImage"), object:nil)
        
        defaultNC.addObserver(self, selector:#selector(MyNSToolbar.displayRepeatImage(_:)), name:Notification.Name(rawValue:"DisplayRepeatImage"), object:nil)
        defaultNC.addObserver(self, selector:#selector(MyNSToolbar.displayRepeatSingleImage(_:)), name:Notification.Name(rawValue:"DisplayRepeatSingleImage"), object:nil)
        defaultNC.addObserver(self, selector:#selector(MyNSToolbar.displayRepeatAllImage(_:)), name:Notification.Name(rawValue:"DisplayRepeatAllImage"), object:nil)
        
        defaultNC.addObserver(self, selector:#selector(MyNSToolbar.displayShuffleOnImage(_:)), name:Notification.Name(rawValue:"DisplayShuffleOnImage"), object:nil)
        defaultNC.addObserver(self, selector:#selector(MyNSToolbar.displayShuffleOffImage(_:)), name:Notification.Name(rawValue:"DisplayShuffleOffImage"), object:nil)
    }
    
    
    func disableOtherPlaybackButtons( _ aNotification:Notification) {
        previous.isEnabled = false
        seekBackward.isEnabled = false
        seekForward.isEnabled = false
        next.isEnabled = false
    }
    
    
    func enableOtherPlaybackButtons(_ aNotification:Notification) {
        previous.isEnabled = true
        seekBackward.isEnabled = true
        seekForward.isEnabled = true
        next.isEnabled = true
    }
    
    
    func disableNext( _ aNotification:Notification) {
        next.isEnabled = false
    }
    
    
    func checkNextEnabled( _ aNotification:Notification) {
        if !next.isEnabled { next.isEnabled = true }
    }
    
    
    func displayPauseImage(_ aNotification:Notification) {
        playPause.image = NSImage(byReferencingFile:Bundle.main.path(forResource:"Pause", ofType:".png")!)
    }
    
    
    func displayPlayImage(_ aNotification:Notification) {
        playPause.image = NSImage(byReferencingFile:Bundle.main.path(forResource:"Play", ofType:".png")!)
    }

    
    func displayRepeatImage(_ aNotification:Notification) {
        repeater.image = NSImage(named:"Repeat")
    }
    
    
    func displayRepeatSingleImage(_ aNotification:Notification) {
        repeater.image = NSImage(named:"Repeat-Single")
    }
    
    
    func displayRepeatAllImage(_ aNotification:Notification) {
        repeater.image = NSImage(named:"Repeat-All")
    }
    
    
    func displayShuffleOnImage(_ aNotification:Notification) {
        shuffler.image = NSImage(named:"Shuffle-On")
    }
    
    
    func displayShuffleOffImage(_ aNotification:Notification) {
        shuffler.image = NSImage(named:"Shuffle-Off")
    }
}
