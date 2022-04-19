//
//  Track.swift
//  Launchpad
//
//  Created by Valere on 2022/4/18.
//

import Foundation

struct Track: Decodable {
    let id: Int
    let name: String
    
    let artistId: Int
    let artistName: String
    let artistViewURL: URL
    
    let artworkURL: URL
    let previewURL: URL
    
    let collectionId: Int
    let collectionName: String
    let collectionViewURL: URL
    
    private enum CodingKeys: String, CodingKey {
        case trackId, trackName, artistId, artistName, artistViewUrl, artworkUrl100, previewUrl, collectionId, collectionName, collectionViewUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .trackId)
        name = try container.decode(String.self, forKey: .trackName)
        artistId = try container.decode(Int.self, forKey: .artistId)
        artistName = try container.decode(String.self, forKey: .artistName)
        artistViewURL = try container.decode(URL.self, forKey: .artistViewUrl)
        artworkURL = try container.decode(URL.self, forKey: .artworkUrl100)
        previewURL = try container.decode(URL.self, forKey: .previewUrl)
        collectionId = try container.decode(Int.self, forKey: .collectionId)
        collectionName = try container.decode(String.self, forKey: .collectionName)
        collectionViewURL = try container.decode(URL.self, forKey: .collectionViewUrl)
    }
}

class TrackStorageManager {
    
    static var shared = TrackStorageManager()
    static subscript(x column: Int, y row: Int) -> Track? {
        get {
            shared.tracksBuffer[IndexPath(row: row, section: column)]
        }
        set {
            shared.tracksBuffer[IndexPath(row: row, section: column)] = newValue
        }
    }
    
    private var tracksBuffer: [IndexPath: Track] = [:]
    private var previewBuffer: [URL: URL] = [:]
}
