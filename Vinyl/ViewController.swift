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
*   Copyright (c) 2015 Matthew Cibulka. All rights reserved.
*
*******************************************************************************************************************************************************************************/

import Cocoa
import AVFoundation

class ViewController: NSViewController
{    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func playSong(sender: AnyObject)
    {
        let songURL = NSURL(string: "file:///Users/Matthew/Google%20Drive/Vinyl/Sample%20Music%20Library/M4A/03%20Sun%20&%20Moon.m4a")
        println(songURL)
        
        audioPlayer = AVAudioPlayer(contentsOfURL: songURL, error: nil)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
}

