//
//  ViewController.swift
//  Launchpad
//
//  Created by Valere on 2022/4/14.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    lazy var launchpadView: LaunchpadView = {
        let launchpadView = LaunchpadView(frame: view.bounds)
        launchpadView.columnButtonCount = UserDefaults.columnButtonCount
        launchpadView.rowButtonCount = UserDefaults.rowButtonCount
        UserDefaults.$columnButtonCount
            .assign(to: \.columnButtonCount, on: launchpadView)
            .store(in: &subscribers)
        UserDefaults.$rowButtonCount
            .assign(to: \.rowButtonCount, on: launchpadView)
            .store(in: &subscribers)
        return launchpadView
    }()
    private var subscribers: [AnyCancellable] = []

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


}

