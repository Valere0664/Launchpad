//
//  TrackTableViewCell.swift
//  Launchpad
//
//  Created by Valere on 2022/4/15.
//

import UIKit

class TrackTableViewCell: UITableViewCell {

    func configCell(_ track: Track, image: UIImage? = nil) {
        var content = self.defaultContentConfiguration()
        content.text = "\(track.name)"
        content.secondaryText = track.artist
        DispatchQueue.global().async { [weak self] in
            self?.downloadImage(with: track.artworkURL) { [weak self] image in
                DispatchQueue.main.async {
                    content.image = image
                    self?.contentConfiguration = content
                }
            }
        }
        let image = UIImage(systemName: "photo")
        content.image = image
        content.imageProperties.reservedLayoutSize = CGSize(width: 64, height: 64)
        content.imageProperties.maximumSize = CGSize(width: 64, height: 64)
        self.contentConfiguration = content
    }
    
    func downloadImage(with url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                completion(image)
            }
        }
        task.resume()
    }
}
