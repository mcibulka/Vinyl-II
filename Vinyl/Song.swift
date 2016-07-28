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
        path = "\(newAsset.url)"
        dateAdded = Date().description(with: nil)
        
        // Get song's time
        let cmTimeSecs = CMTimeGetSeconds(newAsset.duration)
        let intTime = Int64(round(cmTimeSecs))
        let minutes = (intTime % 3600) / 60
        let seconds = (intTime % 3600) % 60
        var timeStr = "\(minutes):"
        
        if seconds < 10 { timeStr += "0" }   // pad seconds with zero
        timeStr += "\(seconds)"
        
        time = timeStr
    }
    
    
    init(path: String, dateAdded: String, time: String) {
        self.path = path
        self.dateAdded = dateAdded
        self.time = time
    }
    
    
    func extractMetaData(_ asset: AVURLAsset) {
        func splitTrackNumbers(_ trackNumberStr: String) {
            let trackNumbers = trackNumberStr.components(separatedBy: "/")   // track number string is represented as "#/#"
            
            if trackNumbers.count >= 1 { // track number available
                if trackNumbers.count == 2 { totalTracks = trackNumbers[1] }    // total track numbers available
                
                trackNumber = trackNumbers[0]
            }
        }
        
        
        func splitReleaseDate(_ date: String) {
            let components = date.components(separatedBy: "-")
            year = components[0]
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
                            album = metadataItem.stringValue
                        case ID3AlbumArtistIdentifier?, ID3AlbumArtistIdentifierII?:              // Album Artist
                            albumArtist = metadataItem.stringValue
                        case ID3ArtistIdentifier?, ID3ArtistIdentifierII?:                        // Artist
                            artist = metadataItem.stringValue
                        case ID3BeatsPerMinuteIdentiifier?, ID3BeatsPerMinuteIdentiifierII?:      // Beats Per Minute
                            BPM = metadataItem.stringValue
                        case ID3CommentsIdentifier?, ID3CommentsIdentifierII?:                    // Comments
                            comments = metadataItem.stringValue
                        case ID3ComposerIdentifier?, ID3ComposerIdentifierII?:                    // Composer
                            composer = metadataItem.stringValue
                        case ID3GenreIdentifier?, ID3GenreIdentifierII?:                          // Genre
                            genre = metadataItem.stringValue
                        case ID3GroupingIdentifier?, ID3GroupingIdentifierII?:                    // Grouping
                            grouping = metadataItem.stringValue
                        case ID3NameIdentifier?, ID3NameIdentifierII?:                            // Name
                            name = metadataItem.stringValue
                        case ID3TrackNumberIdentifier?, ID3TrackNumberIdentifierII?:              // Track Number
                            splitTrackNumbers(metadataItem.stringValue!)
                        case ID3YearIdentifier?, ID3YearIdentifierII?, ID3YearIdentifierIII?:     // Year
                            year = metadataItem.stringValue
                        case ID3AlbumArtworkIdentifier?, ID3AlbumArtworkIdentifierII?:            // Album Artwork
                            artwork = "Artwork"
                        default:
                            break
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            else if format == AVMetadataFormatiTunesMetadata {
                let metadataItemArray = asset.metadata(forFormat: AVMetadataFormatiTunesMetadata)
                
                for metadataItem in metadataItemArray {
                    if #available(OSX 10.10, *) {

                        if metadataItem.commonKey == AVMetadataCommonKeyArtwork {
                            artwork = "Artwork"
                        }

                        switch metadataItem.identifier! {
                        case AVMetadataItem.identifier(forKey: AVMetadataiTunesMetadataKeyAlbum, keySpace: AVMetadataKeySpaceiTunes)!:              // Album
                            album = metadataItem.stringValue
                        case AVMetadataItem.identifier(forKey: AVMetadataiTunesMetadataKeyAlbumArtist, keySpace: AVMetadataKeySpaceiTunes)!:        // Album Artist
                            albumArtist = metadataItem.stringValue
                        case AVMetadataItem.identifier(forKey: AVMetadataiTunesMetadataKeyArtist, keySpace: AVMetadataKeySpaceiTunes)!:             // Artist
                            artist = metadataItem.stringValue
                        case AVMetadataItem.identifier(forKey: AVMetadataiTunesMetadataKeyBeatsPerMin, keySpace: AVMetadataKeySpaceiTunes)!:        // Beats Per Minute
                            BPM = metadataItem.stringValue
                        case AVMetadataItem.identifier(forKey: AVMetadataiTunesMetadataKeyUserComment, keySpace: AVMetadataKeySpaceiTunes)!:        // Comments
                            comments = metadataItem.stringValue
                        case AVMetadataItem.identifier(forKey: AVMetadataiTunesMetadataKeyComposer, keySpace: AVMetadataKeySpaceiTunes)!:           // Composer
                            composer = metadataItem.stringValue
                        case AVMetadataItem.identifier(forKey: AVMetadataiTunesMetadataKeyGenreID, keySpace: AVMetadataKeySpaceiTunes)!:            // Genre
                            genre = metadataItem.stringValue
                        case AVMetadataItem.identifier(forKey: AVMetadataiTunesMetadataKeyGrouping, keySpace: AVMetadataKeySpaceiTunes)!:           // Grouping
                            grouping = metadataItem.stringValue
                        case AVMetadataItem.identifier(forKey: AVMetadataiTunesMetadataKeySongName, keySpace: AVMetadataKeySpaceiTunes)!:           // Name
                            name = metadataItem.stringValue
                        case AVMetadataItem.identifier(forKey: AVMetadataiTunesMetadataKeyTrackNumber, keySpace: AVMetadataKeySpaceiTunes)!:        // Track Number, default to 0 until able to extract
                            trackNumber = "0"
                        case AVMetadataItem.identifier(forKey: AVMetadataiTunesMetadataKeyReleaseDate, keySpace: AVMetadataKeySpaceiTunes)!:        // Year
                            splitReleaseDate(metadataItem.stringValue!)
                        default:
                            break
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
        
        
        if albumArtist == nil { albumArtist = artist }
        if name == nil { name = (asset.url.lastPathComponent! as NSString).deletingPathExtension }
    }
    
    
    func toString()->String
    {
        return("\nAlbum: \(album)\nAlbum Artist: \(albumArtist)\nArtist: \(artist)\nBeats Per Minute: \(BPM)\nComments: \(comments)\nComposer: \(composer)\nDate Added: \(dateAdded)\nGenre: \(genre)\nGrouping: \(grouping)\nName: \(name)\nTime: \(time)\nTrack Number: \(trackNumber)\nYear: \(year)\nFile URL: \(path)\nArtwork: \(artwork)")
    }
}
