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
*   Copyright (c) 2016 Matthew Cibulka. All rights reserved.
*
*******************************************************************************************************************************************************************************/

import Foundation
import AVFoundation

class Song: NSObject
{
    var dateAdded: String
    var path: String
    var time: String

    var album: String?
    var albumArtist: String?
    var artist: String?
    var BPM: String?
    var comments: String?
    var composer: String?
    var genre: String?
    var grouping: String?
    var name: String?
    var trackNumber: String?
    var totalTracks: String?
    var year: String?
    
    var artwork: String?
    
    
    init(newAsset: AVURLAsset) {
        self.path = "\(newAsset.url)"
        self.dateAdded = Date().description(with: nil)
        
        // Get song's time
        let cmTimeSecs = CMTimeGetSeconds(newAsset.duration)
        let intTime = Int64(round(cmTimeSecs))
        let minutes = (intTime % 3600) / 60
        let seconds = (intTime % 3600) % 60
        var time = "\(minutes):"
        
        if seconds < 10 {   // pad seconds with zero
            time += "0"
        }
        time += "\(seconds)"
        
        self.time = time
    }
    
    
    init(path: String, dateAdded: String, time: String) {
        self.path = path
        self.dateAdded = dateAdded
        self.time = time
    }
    
    
    func extractMetaData(_ asset: AVURLAsset) {
        func splitTrackNumbers(_ trackNumberString: String) {
            let trackNumbers = trackNumberString.components(separatedBy: "/")   // track number string is represented as "#/#"
            
            if trackNumbers.count >= 1 { // track number available
                if trackNumbers.count == 2 {    // total track numbers available
                    self.totalTracks = trackNumbers[1]
                }
                
                self.trackNumber = trackNumbers[0]
            }
        }
        
        
        // Identifiers for ID3 version 2.2
        let ID3AlbumIdentifier = "id3/%00TAL"
        let ID3AlbumArtistIdentifier = "id3/%00TP2"
        let ID3ArtistIdentifier = "id3/%00TP1"
        let ID3BeatsPerMinuteIdentiifier = "id3/%00BPM"
        let ID3CommentsIdentifier = "id3/%00COM"
        let ID3ComposerIdentifier = "id3/%00TCM"
        let ID3GenreIdentifier = "id3/%00TCO"
        let ID3GroupingIdentifier = "id3/%00TT1"
        let ID3NameIdentifier = "id3/%00TT2"
        let ID3TrackNumberIdentifier = "id3/%00TRK"
        let ID3YearIdentifier = "id3/%00TYE"
        let ID3AlbumArtworkIdentifier = "id3/%00PIC"
        
        // Identifiers for ID3 versions 2.3 and 2.4
        let ID3AlbumIdentifierII = "id3/TALB"
        let ID3AlbumArtistIdentifierII = "id3/TPE2"
        let ID3ArtistIdentifierII = "id3/TPE1"
        let ID3BeatsPerMinuteIdentiifierII = "id3/TBPM"
        let ID3CommentsIdentifierII = "id3/COMM"
        let ID3ComposerIdentifierII = "id3/TCOM"
        let ID3GenreIdentifierII = "id3/TCON"
        let ID3GroupingIdentifierII = "id3/TIT1"
        let ID3NameIdentifierII = "id3/TIT2"
        let ID3TrackNumberIdentifierII = "id3/TRCK"
        let ID3YearIdentifierII = "id3/TYER"
        let ID3YearIdentifierIII = "id3/TDRC"           // TYER was deprecated in 2.4
        let ID3AlbumArtworkIdentifierII = "id3/APIC"

        
        // Extract metadata based on file type of song
        let formats = asset.availableMetadataFormats
        
        for format in formats {
            if format == AVMetadataFormatID3Metadata {
                let metadataItemArray = asset.metadata(forFormat: AVMetadataFormatID3Metadata)
                
                for metadataItem in metadataItemArray {
                    if #available(OSX 10.10, *) {
                        switch metadataItem.identifier {
                        case ID3AlbumIdentifier?, ID3AlbumIdentifierII?:                          // Album
                            self.album = metadataItem.stringValue
                        case ID3AlbumArtistIdentifier?, ID3AlbumArtistIdentifierII?:              // Album Artist
                            self.albumArtist = metadataItem.stringValue
                        case ID3ArtistIdentifier?, ID3ArtistIdentifierII?:                        // Artist
                            self.artist = metadataItem.stringValue
                        case ID3BeatsPerMinuteIdentiifier?, ID3BeatsPerMinuteIdentiifierII?:      // Beats Per Minute
                            self.BPM = metadataItem.stringValue
                        case ID3CommentsIdentifier?, ID3CommentsIdentifierII?:                    // Comments
                            self.comments = metadataItem.stringValue
                        case ID3ComposerIdentifier?, ID3ComposerIdentifierII?:                    // Composer
                            self.composer = metadataItem.stringValue
                        case ID3GenreIdentifier?, ID3GenreIdentifierII?:                          // Genre
                            self.genre = metadataItem.stringValue
                        case ID3GroupingIdentifier?, ID3GroupingIdentifierII?:                    // Grouping
                            self.grouping = metadataItem.stringValue
                        case ID3NameIdentifier?, ID3NameIdentifierII?:                            // Name
                            self.name = metadataItem.stringValue
                        case ID3TrackNumberIdentifier?, ID3TrackNumberIdentifierII?:              // Track Number
                            splitTrackNumbers(metadataItem.stringValue!)
                        case ID3YearIdentifier?, ID3YearIdentifierII?, ID3YearIdentifierIII?:     // Year
                            self.year = metadataItem.stringValue
                        case ID3AlbumArtworkIdentifier?, ID3AlbumArtworkIdentifierII?:            // Album Artwork
                            self.artwork = "Artwork"
                        default:
                            break
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            else {
                print("\nERROR. Unable to extract metadata for the file format: \(format)\n\n")
            }
        }
        
        
        if self.albumArtist == nil {
            self.albumArtist = self.artist
        }
        
        if self.name == nil {
            self.name = (asset.url.lastPathComponent! as NSString).deletingPathExtension
        }
    }
    
    
    func toString()->String
    {
        return("\nAlbum: \(self.album)\nAlbum Artist: \(self.albumArtist)\nArtist: \(self.artist)\nBeats Per Minute: \(self.BPM)\nComments: \(self.comments)\nComposer: \(self.composer)\nDate Added: \(self.dateAdded)\nGenre: \(self.genre)\nGrouping: \(self.grouping)\nName: \(self.name)\nTime: \(self.time)\nTrack Number: \(self.trackNumber)\nYear: \(self.year)\nFile URL: \(self.path)\nArtwork: \(self.artwork)")
    }
}
