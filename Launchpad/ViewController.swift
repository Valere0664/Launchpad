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
    
    var players: [AVPlayer?] = []

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
        launchpadView.columnButtonCount = UserDefaults.columnButtonCount
        launchpadView.rowButtonCount = UserDefaults.rowButtonCount
        
        players = Array(repeating: nil, count: launchpadView.columnButtonCount * launchpadView.rowButtonCount)
    }
}

extension ViewController: LaunchpadViewDelegate {
    func didSelectRowAt(x: Int, y: Int) {
        if let url = TrackStorageManager[x: x, y: y]?.downloadPreviewURL {
            let player = AVPlayer(url: url)
            player.play()
            players[y + x * launchpadView.rowButtonCount] = player
        }
    }
}

