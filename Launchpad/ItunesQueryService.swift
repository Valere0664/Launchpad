//
//  ItunesQueryService.swift
//  MusicList
//
//  Created by Nick Yang on 2022/3/30.
//
import UIKit

class ItunesQueryService {
    
    static let shared = ItunesQueryService()
    
    private let defaultSession = URLSession.shared
    private var dataTask: URLSessionDataTask?
    private(set) var errorMessage = ""
    
    var tracksUpdate: (() -> ())?
    
    var searchText = "" {
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
    
    private init() { }
    
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
                
                do {
                    self.tracks = (try JSONDecoder().decode(ITunesAPIResponse.self, from: data)).results
                } catch let parseError as NSError {
                    self.errorMessage += "JSONDecoder error: \(parseError.localizedDescription)\n"
                    self.tracks.removeAll()
                    return
                }
            }
        }
        self.dataTask = dataTask
        dataTask.resume()
    }
}

