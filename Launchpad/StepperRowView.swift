//
//  StepperRowView.swift
//  Launchpad
//
//  Created by Valere on 2022/4/21.
//

import UIKit

class StepperRowView: UIView {
    
    let stepper = UIStepper()
    let numberLabel = UILabel()
    var valueChange: ((Int) -> ())?
    
    init(count: Int) {
        super.init(frame: .zero)
        stepper.value = Double(count)
        numberLabel.text = String(count)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        stepper.minimumValue = 1
        stepper.addTarget(self, action: #selector(stepperValueChange), for: .valueChanged)
        stepper.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stepper)
        addSubview(numberLabel)
        NSLayoutConstraint.activate([
            numberLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 18),
            numberLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stepper.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -18),
            stepper.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func stepperValueChange() {
        let newValue = Int(stepper.value)
        numberLabel.text = String(newValue)
        self.valueChange?(newValue)
    }
}
