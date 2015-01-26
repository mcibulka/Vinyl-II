/*******************************************************************************************************************************************************************************
*
*   Project: Vinyl
*
*   Directory: Vinyl
*   File Name: Song.swift
*
*   Date Created: January 20, 2015
*   Created By: Matthew Cibulka
*
*   Copyright (c) 2015 Matthew Cibulka. All rights reserved.
*
*******************************************************************************************************************************************************************************/

import Foundation

class Song: NSObject
{
    var album: String = ""
    var albumArtist: String = ""
    var artist: String = ""
    var beatsPerMinute: String = ""
    var comments: String = ""
    var composer: String = ""
    var dateAdded: String = ""
    var genre: String = ""
    var grouping: String = ""
    var name: String = ""
    var time: String = ""
    var trackNumber: String = ""
    var year: String = ""
    
    var fileURL: String = ""
    var artwork: String = ""
    
//    init(album: String, albumArtist: String, artist: String, beatsPerMinute: String, comments: String, composer: String, dateAdded: String, genre: String, grouping: String, name: String, time: String, trackNumber: String, year: String, fileURL: String, artwork: String)
//    {
//        self.album = album
//        self.albumArtist = albumArtist
//        self.artist = artist
//        self.beatsPerMinute = beatsPerMinute
//        self.comments = comments
//        self.composer = composer
//        self.dateAdded = dateAdded
//        self.genre = genre
//        self.grouping = grouping
//        self.name = name
//        self.time = time
//        self.trackNumber = trackNumber
//        self.year = year
//        
//        self.fileURL = fileURL
//        self.artwork = artwork
//    }
    
    func toString()->String
    {
        return("\nAlbum: \(self.album)\nAlbum Artist: \(self.albumArtist)\nArtist: \(self.artist)\nBeats Per Minute: \(self.beatsPerMinute)\nComments: \(self.comments)\nComposer: \(self.composer)\nDate Added: \(self.dateAdded)\nGenre: \(self.genre)\nGrouping: \(self.grouping)\nName: \(self.name)\nTime: \(self.time)\nTrack Number: \(self.trackNumber)\nYear: \(self.year)\nFile URL: \(self.fileURL)\nArtwork: \(self.artwork)")
    }
}
