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
    
    
    override func validateVisibleItems()
    {
        let defaultNotificationCenter = NSNotificationCenter.defaultCenter()

        defaultNotificationCenter.addObserver(self, selector: #selector(MyNSToolbar.enableOtherPlaybackButtons(_:)), name:"EnableOtherPlaybackButtons", object: nil)
        defaultNotificationCenter.addObserver(self, selector: #selector(MyNSToolbar.displayPauseImage(_:)), name:"DisplayPauseImage", object: nil)
        defaultNotificationCenter.addObserver(self, selector: #selector(MyNSToolbar.displayPlayImage(_:)), name:"DisplayPlayImage", object: nil)
    }
    
    
    func enableOtherPlaybackButtons(aNotification: NSNotification)
    {
        print("YES")
        previous.enabled = true
        seekBackward.enabled = true
        seekForward.enabled = true
        next.enabled = true
    }
    
    
    func displayPauseImage(aNotification: NSNotification)
    {
        let mainBundle = NSBundle.mainBundle()
     
        playPause.image = NSImage(byReferencingFile: mainBundle.pathForResource("Pause", ofType: ".png")!)
    }
    
    
    func displayPlayImage(aNotification: NSNotification)
    {
        let mainBundle = NSBundle.mainBundle()
        
        playPause.image = NSImage(byReferencingFile: mainBundle.pathForResource("Play", ofType: ".png")!)
    }
}
