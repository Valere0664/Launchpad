//
//  ItunesQueryService.swift
//  MusicList
//
//  Created by Nick Yang on 2022/3/30.
//
import UIKit

class ItunesQueryService {
    
    static var shared = ItunesQueryService()
    
    private let defaultSession = URLSession.shared
    private var dataTask: URLSessionDataTask?
    private(set) var errorMessage = ""
    
    var tracksUpdate: (() -> ())?
    
    var searchText = "Coldplay" {
        didSet {
            if searchText.isEmpty {
                tracks.removeAll()
            } else {
                getSearchResults()
            }
        }
    }
    
    private(set) var tracks: [Track] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tracksUpdate?()
            }
        }
    }
    
    init() {
//        getSearchResults()
    }
    
    private func getSearchResults() {
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search")!
        urlComponents.query = "media=music&entity=song&term=\(searchText)"
        
        guard let url = urlComponents.url else {
            tracks.removeAll()
            return
        }
        dataTask?.cancel()
        errorMessage = ""
        let dataTask = defaultSession.dataTask(with: url) { data, response, error in
            
            if let error = error {
                self.errorMessage += "DataTask error: \(error.localizedDescription)\n"
                self.tracks.removeAll()
            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                var responseDict: [String: Any]?
                var responseTracks: [Track] = []
                
                do {
                    responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                } catch let parseError as NSError {
                    self.errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
                    self.tracks.removeAll()
                    return
                }
                
                guard let array = responseDict!["results"] as? [Any] else {
                    self.errorMessage += "Dictionary does not contain results key\n"
                    self.tracks.removeAll()
                    return
                }
                
                for trackDictionary in array {
                    if let trackDictionary = trackDictionary as? [String: Any],
                       let name = trackDictionary["trackName"] as? String,
                       let artist = trackDictionary["artistName"] as? String,
                       let artworkURLString = trackDictionary["artworkUrl100"] as? String,
                       let artworkURL = URL(string: artworkURLString),
                       let collectionViewURLString = trackDictionary["collectionViewUrl"] as? String,
                       let collectionViewURL = URL(string: collectionViewURLString) {
                        responseTracks.append(Track(name: name, artist: artist, artworkURL: artworkURL, collectionViewURL: collectionViewURL))
                    } else {
                        self.errorMessage += "Problem parsing trackDictionary\n"
                        self.tracks.removeAll()
                    }
                }
                self.tracks = responseTracks
            }
        }
        self.dataTask = dataTask
        dataTask.resume()
    }
}

