//
//  DetailViewController.swift
//  MusicList
//
//  Created by Valere on 2022/4/18.
//

import UIKit
import Combine

class DetailViewController: UIViewController {
    
    private var track: Track
    private var subscribers: [AnyCancellable] = []
    private var imageDispatchQueue = DispatchQueue(label: "image_queue")
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        return scrollView
    }()
    
    private lazy var launchpadView: LaunchpadView = {
        let launchpadView = LaunchpadView(frame: view.bounds)
        launchpadView.translatesAutoresizingMaskIntoConstraints = false
        launchpadView.delegate = self
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
    
    init(track: Track) {
        self.track = track
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        loadLaunchpad()
    }
    
    private func updateLaunchpadButton(x: Int, y: Int) {
        let button = launchpadView.buttonFor(x: x, y: y)
        if let track = TrackStorageManager[x: x, y: y] {
            if track == self.track {
                button.layer.borderWidth = 6
                button.layer.borderColor = UIColor.systemBlue.cgColor
            } else {
                button.layer.borderWidth = 0
                button.layer.borderColor = nil
            }
            imageDispatchQueue.async { [weak button] in
                do {
                    let data = try Data(contentsOf: track.artworkURL)
                    let image = UIImage(data: data)
                    DispatchQueue.main.async { [weak button] in
                        button?.setBackgroundImage(image, for: .normal)
                    }
                } catch {
                    print("Cannot download image")
                }
            }
        } else {
            button.setBackgroundImage(nil, for: .normal)
        }
    }
    
    private func loadLaunchpad() {
        for x in 0..<launchpadView.columnButtonCount {
            for y in 0..<launchpadView.rowButtonCount {
                updateLaunchpadButton(x: x, y: y)
            }
        }
    }
}

extension DetailViewController {
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Details"
        
        let firstRow  = makeRow(of: "Name: ", with: track.name)
        let secondRow = makeRow(of: "Artist: ", with: track.artistName)
        let thirdRow  = makeRow(of: "URL: ", with: track.collectionViewURL.absoluteString)
        let imageView = UIImageView(image: UIImage(systemName: "photo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageDispatchQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try Data(contentsOf: self.track.artworkURL)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    imageView.image = image
                }
            } catch {
                print("Cannot download image")
            }
        }
        
        let contentView = UIStackView(arrangedSubviews: [firstRow, secondRow, thirdRow])
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.distribution = .fill
        contentView.spacing = 10
        
        scrollView.addSubview(imageView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            contentView.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 12),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
        ])
        
        scrollView.addSubview(launchpadView)
        NSLayoutConstraint.activate([
            launchpadView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            launchpadView.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 20),
            launchpadView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            launchpadView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor)
        ])
        
        view.layoutIfNeeded()
        scrollView.contentSize = CGSize(width: launchpadView.frame.maxX, height: launchpadView.frame.maxY)
        
        // setup Stepper View
        let rowStepper = StepperRowView(count: launchpadView.rowButtonCount)
        let columnStepper = StepperRowView(count: launchpadView.columnButtonCount)
        rowStepper.valueChange = { count in
            UserDefaults.rowButtonCount = count
        }
        columnStepper.valueChange = { count in
            UserDefaults.columnButtonCount = count
        }
        
        let stepperContentView = UIStackView(arrangedSubviews: [rowStepper, columnStepper])
        stepperContentView.axis = .vertical
        stepperContentView.backgroundColor = .systemBackground
        stepperContentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stepperContentView)
        NSLayoutConstraint.activate([
            stepperContentView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            stepperContentView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            stepperContentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let divider = UIView()
        divider.backgroundColor = .gray
        divider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(divider)
        NSLayoutConstraint.activate([
            divider.leftAnchor.constraint(equalTo: view.leftAnchor),
            divider.rightAnchor.constraint(equalTo: view.rightAnchor),
            divider.bottomAnchor.constraint(equalTo: stepperContentView.topAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    private func makeLabel(with text: String) -> UILabel {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.text = text
        return label
    }
    
    private func makeRow(of title: String, with content: String) -> UIView {
        let titleLabel = makeLabel(with: title)
        let contentLabel = makeLabel(with: content)
        let contentView = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .horizontal
        contentView.distribution = .fillProportionally
        contentView.alignment = .top
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
        return contentView
    }
}

extension DetailViewController: LaunchpadViewDelegate {
    func didSelectRowAt(x: Int, y: Int) {
        if let track = TrackStorageManager[x: x, y: y], track == self.track {
            TrackStorageManager[x: x, y: y] = nil
        } else {
            TrackStorageManager[x: x, y: y] = self.track
            TrackStorageManager.shared.downloadPreview(self.track)
        }
        updateLaunchpadButton(x: x, y: y)
    }
}
