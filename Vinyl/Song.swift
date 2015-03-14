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
import AVFoundation

class Song: NSObject
{
    var dateAdded: String
    var fileURL: String
    var time: String

    var album: String?
    var albumArtist: String?
    var artist: String?
    var beatsPerMinute: String?
    var comments: String?
    var composer: String?
    var genre: String?
    var grouping: String?
    var name: String?
    var trackNumber: String?
    var totalTracks: String?
    var year: String?
    
    var artwork: String?
    
    
    init(newAsset: AVURLAsset)
    {
        // Get song's file path
        var fileURLString = "\(newAsset.URL)"
        fileURLString = fileURLString.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        fileURLString = fileURLString.stringByReplacingOccurrencesOfString("Optional(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        fileURLString = fileURLString.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        self.fileURL = fileURLString
        
        
        // Get time and date of when song is added to the library
        let dateAdded = NSDate(timeIntervalSinceNow: 0.0)
        let dateAddedString = dateAdded.descriptionWithCalendarFormat("%Y-%m-%d %H:%M:%S", timeZone: nil, locale: nil)!
        
        self.dateAdded = dateAddedString
        
        
        // Get song's time
        let cmTimeSecs = CMTimeGetSeconds(newAsset.duration)
        let intTime = Int64(round(cmTimeSecs))
        let minutes = (intTime % 3600) / 60
        let seconds = (intTime % 3600) % 60
        var timeString = "\(minutes):"
        
        // Pad seconds with a zero if a single digit
        if seconds < 10 {
            timeString += "0"
        }
        timeString += "\(seconds)"
        
        self.time = timeString
    }
    
    
    init(fileURLString: String, dateAddedString: String, timeString: String)
    {
        println("Hello")
        self.fileURL = fileURLString
        self.dateAdded = dateAddedString
        self.time = timeString
    }
    
    
    func extractMetaData(asset: AVURLAsset)
    {
        func splitTrackNumbers(trackNumberString: String)
        {
            let trackNumbers = trackNumberString.componentsSeparatedByString("/")
            println(trackNumbers)
            
            if trackNumbers.count >= 1
            {
                if trackNumbers.count == 2 {
                    self.totalTracks = trackNumbers[1]
                }
                
                self.trackNumber = trackNumbers[0]
            }
        }
        
        
        // Extract metadata based on file type of song
        var formats: NSArray = asset.availableMetadataFormats
        
        for format in formats as [NSString]
        {
            if format == AVMetadataFormatID3Metadata
            {
                let metadataItemArray = asset.metadataForFormat(AVMetadataFormatID3Metadata)
                                
                for metadataItem in metadataItemArray as [AVMetadataItem]
                {
                    switch metadataItem.key() as String
                    {
                    case AVMetadataID3MetadataKeyAlbumTitle:                    // Album
                        self.album = metadataItem.stringValue
                    case AVMetadataID3MetadataKeyLeadPerformer:                 // Album Artist
                        self.artist = metadataItem.stringValue
                    case AVMetadataID3MetadataKeyBand:                          // Artist
                        self.albumArtist = metadataItem.stringValue
                    case AVMetadataID3MetadataKeyBeatsPerMinute:                // Beats Per Minute
                        self.beatsPerMinute = metadataItem.stringValue
                    case AVMetadataID3MetadataKeyComments:                      // Comments
                        self.comments = metadataItem.stringValue
                    case AVMetadataID3MetadataKeyComposer:                      // Composer
                        self.composer = metadataItem.stringValue
                    case AVMetadataID3MetadataKeyContentType:                   // Genre
                        self.genre = metadataItem.stringValue
                    case AVMetadataID3MetadataKeyContentGroupDescription:       // Grouping
                        self.grouping = metadataItem.stringValue
                    case AVMetadataID3MetadataKeyTitleDescription:              // Name
                        self.name = metadataItem.stringValue
                    case AVMetadataID3MetadataKeyTrackNumber:                   // Track Number
                        splitTrackNumbers(metadataItem.stringValue)
                    case AVMetadataID3MetadataKeyRecordingTime,                 // Year
                         AVMetadataID3MetadataKeyYear:
                        self.year = metadataItem.stringValue
                    case AVMetadataID3MetadataKeyAttachedPicture:               // Album Artwork
                        self.artwork = "Artwork"
                    default:
                        break
                    }
                }
            }
            else
            {
                println("\nERROR. Unrecognized file format: \(format)\n\n")
            }
        }
    }
    
    
    func toString()->String
    {
        return("\nAlbum: \(self.album)\nAlbum Artist: \(self.albumArtist)\nArtist: \(self.artist)\nBeats Per Minute: \(self.beatsPerMinute)\nComments: \(self.comments)\nComposer: \(self.composer)\nDate Added: \(self.dateAdded)\nGenre: \(self.genre)\nGrouping: \(self.grouping)\nName: \(self.name)\nTime: \(self.time)\nTrack Number: \(self.trackNumber)\nYear: \(self.year)\nFile URL: \(self.fileURL)\nArtwork: \(self.artwork)")
    }
}
