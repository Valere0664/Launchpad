//
//  SearchTableViewController.swift
//  Launchpad
//
//  Created by Valere on 2022/4/14.
//

import UIKit

class SearchTableViewController: UITableViewController {

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.searchBar.placeholder = "Song, Artist, ..."
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    let service = ItunesQueryService.shared
    private var searchWorkTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.searchController = searchController
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: "Cell")
        service.tracksUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.searchBar.text == "" {
            return 0
        }
        return service.tracks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRow", indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let cell = cell as? TrackTableViewCell {
            let track = service.tracks[indexPath.row]
            cell.configCell(track)
        }
        return cell
    }
}


// MARK: - UISearchControllerDelegate, UISearchResultsUpdating
extension SearchTableViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchedText = searchController.searchBar.text ?? ""
        if searchedText.isEmpty {
            tableView.reloadData()
        } else {
            searchWorkTimer?.invalidate()
            searchWorkTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performSearch), userInfo: nil, repeats: false)
        }
    }
    
    @objc private func performSearch() {
        if let searchedText = searchController.searchBar.text,
           !searchedText.isEmpty {
            service.searchText = searchedText
        }
    }
}
