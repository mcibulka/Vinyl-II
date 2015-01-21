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
    var album: String
    var albumArtist: String
    var artist: String
    var comments: String
    var composer: String
    var dateAdded: String
    var genre: String
    var grouping: String
    var name: String
    var time: String
    var year: String
    
    var fileURL: String
    
    init(album: String, albumArtist: String, artist: String, comments: String, composer: String, dateAdded: String, genre: String, grouping: String, name: String, time: String, year: String, fileURL: String)
    {
        self.album = album
        self.albumArtist = albumArtist
        self.artist = artist
        self.comments = comments
        self.composer = composer
        self.dateAdded = dateAdded
        self.genre = genre
        self.grouping = grouping
        self.name = name
        self.time = time
        self.year = year
        
        self.fileURL = fileURL
    }
}
