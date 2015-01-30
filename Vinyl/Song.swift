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

class Song
{
    private let dateAdded: String
    private let fileURL: String
    private let time: String

    private var album: String?
    private var albumArtist: String?
    private var artist: String?
    private var beatsPerMinute: String?
    private var comments: String?
    private var composer: String?
    private var genre: String?
    private var grouping: String?
    private var name: String?
    private var trackNumber: String?
    private var year: String?
    
    private var artwork: String?
    
    
    init(asset: AVURLAsset)
    {
        /* Get song's file path */
        var newstring = "\(asset.URL)"
        newstring = newstring.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newstring = newstring.stringByReplacingOccurrencesOfString("Optional(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newstring = newstring.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        self.fileURL = "\(newstring)\n"
        
        
        /* Get time and date of when song is added to the library */
        let dateAdded: NSDate = NSDate(timeIntervalSinceNow: 0.0)
        let dateAddedStr: NSString = dateAdded.descriptionWithCalendarFormat("%Y-%m-%d %H:%M:%S", timeZone: nil, locale: nil)!
        
        self.dateAdded = dateAddedStr
        
        
        /* Get song's time */
        let cmTime: CMTime = asset.duration
        let cmTimeSecs: Float64 = CMTimeGetSeconds(cmTime)
        let intTime: Int64 = Int64(round(cmTimeSecs))
        let minutes = (intTime % 3600) / 60
        let seconds = (intTime % 3600) % 60
        let timeStr: NSString = "\(minutes):\(seconds)"
        
        self.time = timeStr
        
        
        extractSongInfo(asset)
    }
    
    
    func extractSongInfo(asset: AVURLAsset)
    {
        var metadataItemArray: NSArray
        
        // Extract metadata based on file type of song
        var formats: NSArray = asset.availableMetadataFormats
        for format in formats
        {
            if format as NSString == AVMetadataFormatID3Metadata    // MP3
            {
                metadataItemArray = asset.metadataForFormat(AVMetadataFormatID3Metadata)
                
                for metadataItem in metadataItemArray as [AVMetadataItem]
                {
                    switch metadataItem.key() as NSString
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
                        self.trackNumber = metadataItem.stringValue
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
