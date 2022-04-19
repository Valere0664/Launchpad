//
//  Track.swift
//  Launchpad
//
//  Created by Valere on 2022/4/18.
//

import Foundation

struct Track {
    let name: String
    let artist: String
    let artworkURL: URL
    let collectionViewURL: URL
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
}
