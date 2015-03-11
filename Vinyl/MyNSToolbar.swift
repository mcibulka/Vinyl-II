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
*   Copyright (c) 2015 Matthew Cibulka. All rights reserved.
*
*******************************************************************************************************************************************************************************/

import Cocoa

class MyNSToolbar: NSToolbar
{
    @IBOutlet weak var playToolbarItem: NSToolbarItem!
    
    let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
    let mainBundle = NSBundle.mainBundle()
    
    
    override func validateVisibleItems()
    {
        defaultNotificationCenter.addObserver(self, selector: "displayPauseImage:", name:"DisplayPauseImage", object: nil)
        defaultNotificationCenter.addObserver(self, selector: "displayPlayImage:", name:"DisplayPlayImage", object: nil)
        playToolbarItem.validate()
    }
    
    
    func displayPauseImage(notification: NSNotification)
    {
        playToolbarItem.image = NSImage(byReferencingFile: mainBundle.pathForResource("Pause", ofType: ".png")!)
    }
    
    
    func displayPlayImage(notification: NSNotification)
    {
        playToolbarItem.image = NSImage(byReferencingFile: mainBundle.pathForResource("Play", ofType: ".png")!)
    }
}
