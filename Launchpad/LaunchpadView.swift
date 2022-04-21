//
//  LaunchpadView.swift
//  Launchpad
//
//  Created by Valere on 2022/4/14.
//

import UIKit

protocol LaunchpadViewDelegate: AnyObject {
    func didSelectRowAt(x: Int, y: Int)
}

class LaunchpadView: UIView {
    
    private enum Constant {
        static let buttonMarginRatio: CGFloat = 0.02
        static let buttonCornerRadius: CGFloat = 12
    }
    
    var columnButtonCount: Int = 0 {
        didSet {
            updateButtonCount()
        }
    }
    var rowButtonCount: Int = 0 {
        didSet {
            updateButtonCount()
        }
    }
    
    private var buttons: [[UIButton]] = []
    weak var delegate: LaunchpadViewDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.bounds.width.isZero || self.bounds.height.isZero {
            return
        }

        let buttonMargin = min(self.bounds.width, self.bounds.height) * Constant.buttonMarginRatio
        let buttonSuitableWidth = (self.bounds.width - buttonMargin * CGFloat(columnButtonCount + 1)) / CGFloat(columnButtonCount)
        let buttonSuitableHeight = (self.bounds.height - buttonMargin * CGFloat(rowButtonCount + 1)) / CGFloat(rowButtonCount)
        let buttonWidth = min(buttonSuitableWidth, buttonSuitableHeight)
        for (yIndex, rowButtons) in buttons.enumerated() {
            for (xIndex, button) in rowButtons.enumerated() {
                let x = buttonMargin + (buttonWidth + buttonMargin) * CGFloat(xIndex)
                let y = buttonMargin + (buttonWidth + buttonMargin) * CGFloat(yIndex)
                button.frame = CGRect(x: x, y: y, width: buttonWidth, height: buttonWidth)
            }
        }
    }
    
    func buttonFor(x: Int, y: Int) -> UIButton {
        buttons[y][x]
    }
    
    private func updateButtonCount() {
        if rowButtonCount == 0 || columnButtonCount == 0 {
            return
        }
        
        // y count
        while buttons.count != rowButtonCount {
            if buttons.count < rowButtonCount {
                buttons.append([])
            } else {
                let removeButtons = buttons.removeLast()
                removeButtons.forEach {
                    $0.removeFromSuperview()
                }
            }
        }

        // x count
        for yindex in 0..<rowButtonCount {
            while buttons[yindex].count != columnButtonCount {
                if buttons[yindex].count < columnButtonCount {
                    let button = getLaunchPadButton()
                    self.addSubview(button)
                    buttons[yindex].append(button)
                } else {
                    buttons[yindex].removeLast().removeFromSuperview()
                }
            }
        }
        self.layoutSubviews()
    }
    
    private func getLaunchPadButton() -> UIButton {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(launchPadButtonAction), for: .touchUpInside)
        button.backgroundColor = .gray
        button.contentMode = .center
        button.layer.cornerRadius = Constant.buttonCornerRadius
        button.clipsToBounds = true
        return button
    }
    
    @objc private func launchPadButtonAction(_ sender: UIButton) {
        for y in 0..<buttons.count {
            for x in 0..<buttons[y].count {
                if buttons[y][x] === sender {
                    delegate?.didSelectRowAt(x: x, y: y)
                    return
                }
            }
        }
    }
}
