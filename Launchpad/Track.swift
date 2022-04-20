//
//  Track.swift
//  Launchpad
//
//  Created by Valere on 2022/4/18.
//

import Foundation

struct Track: Decodable, Equatable {
    let id: Int
    let name: String
    
    let artistId: Int
    let artistName: String
    let artistViewURL: URL
    
    let artworkURL: URL
    let previewURL: URL
    var downloadPreviewURL: URL? {
        if case let .success(url) = TrackStorageManager.shared.previewBuffer[previewURL] {
            return url
        }
        return nil
    }
    
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
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }
}

class TrackStorageManager: NSObject {
    
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
    private(set) var previewBuffer: [URL: PreviewStatus] = [:]
    
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private lazy var downloadsSession: URLSession = {
      let configuration = URLSessionConfiguration.background(withIdentifier:
        "iTunes.bgSession")
      return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
}

// MARK: - Preview function
extension TrackStorageManager {
    enum PreviewStatus {
        case loading(URLSessionDownloadTask, [(URL?) -> ()])
        case failed
        case success(URL)
    }
    
    func downloadPreview(_ track: Track, completion: ((URL?) -> ())? = nil) {
        if let previewStatus = previewBuffer[track.previewURL] {
            switch previewStatus {
            case .success(let url):
                completion?(url)
            case .failed:
                completion?(nil)
            case .loading(let tesk, var completions):
                if let completion = completion {
                    completions.append(completion)
                    previewBuffer[track.previewURL] = .loading(tesk, completions)
                }
            }
        } else {
            let tesk = downloadsSession.downloadTask(with: track.previewURL)
            if let completion = completion {
                previewBuffer[track.previewURL] = .loading(tesk, [completion])
            } else {
                previewBuffer[track.previewURL] = .loading(tesk, [])
            }
            tesk.resume()
        }
    }
}

extension TrackStorageManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("urlSession downloadTask", location, downloadTask.originalRequest)
        guard let sourceURL = downloadTask.originalRequest?.url else {
            return
        }
        
        let destinationURL = documentsPath.appendingPathComponent(sourceURL.lastPathComponent)
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        if let stetus = previewBuffer[sourceURL] {
            if case let .loading(_, completions) = stetus {
                previewBuffer[sourceURL] = .success(destinationURL)
                for completion in completions {
                    completion(location)
                }
            }
        }
    }
}
