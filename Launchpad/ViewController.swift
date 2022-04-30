//
//  ViewController.swift
//  Launchpad
//
//  Created by Valere on 2022/4/14.
//

import UIKit
import Combine
import AVFoundation

class ViewController: UIViewController {
    
    lazy var launchpadView: LaunchpadView = {
        let launchpadView = LaunchpadView(frame: view.bounds)
        launchpadView.delegate = self
        return launchpadView
    }()
    private var subscribers: [AnyCancellable] = []
    private var players: [AVAudioPlayer?] = []
    private var imageDispatchQueue = DispatchQueue(label: "view_controller_image_queue")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        launchpadView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(launchpadView)
        NSLayoutConstraint.activate([
            launchpadView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            launchpadView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            launchpadView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            launchpadView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadLaunchpadData()
    }
    
    private func reloadLaunchpadData() {
        launchpadView.columnButtonCount = UserDefaults.columnButtonCount
        launchpadView.rowButtonCount = UserDefaults.rowButtonCount
        
        players = Array(repeating: nil, count: launchpadView.columnButtonCount * launchpadView.rowButtonCount)
        
        for x in 0..<launchpadView.columnButtonCount {
            for y in 0..<launchpadView.rowButtonCount {
                let button = launchpadView.buttonFor(x: x, y: y)
                button.backgroundColor = .gray
                let imageView: UIImageView!
                if let view = button.viewWithTag(5) as? UIImageView {
                    imageView = view
                } else {
                    let newImageView = UIImageView()
                    newImageView.tag = 5
                    newImageView.clipsToBounds = true
                    newImageView.layer.cornerRadius = 8
                    button.addSubview(newImageView)
                    imageView = newImageView
                }
                let imageWidth = button.bounds.width / 3.5
                let imageOffset = button.bounds.width - imageWidth * 1.3
                imageView.frame = CGRect(x: imageOffset, y: imageOffset, width: imageWidth, height: imageWidth)
                
                if let track = TrackStorageManager[x: x, y: y] {
                    imageDispatchQueue.async {
                        do {
                            let data = try Data(contentsOf: track.artworkURL)
                            let image = UIImage(data: data)
                            DispatchQueue.main.async {
                                imageView.image = image
                            }
                        } catch {
                            print("Cannot download image")
                        }
                    }
                } else {
                    imageView.image = nil
                }
            }
        }
    }
    
    @IBAction func editAction(_ sender: Any) {
        let editViewController = SearchTableViewController()
        let editNavigationController = UINavigationController(rootViewController: editViewController)
        editNavigationController.transitioningDelegate = self
        
        present(editNavigationController, animated: true)
        players.removeAll()
    }
}

extension ViewController: LaunchpadViewDelegate {
    func didSelectRowAt(x: Int, y: Int) {
        guard players[y + x * launchpadView.rowButtonCount] == nil else {
            players[y + x * launchpadView.rowButtonCount] = nil
            launchpadView.buttonFor(x: x, y: y).backgroundColor = .gray
            return
        }
        if let url = TrackStorageManager[x: x, y: y]?.downloadPreviewURL,
        let player = try? AVAudioPlayer(contentsOf: url) {
            player.delegate = self
            player.play()
            players[y + x * launchpadView.rowButtonCount] = player
            launchpadView.buttonFor(x: x, y: y).backgroundColor = .yellow
        }
    }
}

extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        for x in 0..<launchpadView.columnButtonCount {
            for y in 0..<launchpadView.rowButtonCount {
                if player === players[y + x * launchpadView.rowButtonCount] {
                    players[y + x * launchpadView.rowButtonCount] = nil
                    launchpadView.buttonFor(x: x, y: y).backgroundColor = .gray
                    return
                }
            }
        }
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        reloadLaunchpadData()
        return nil
    }
}

