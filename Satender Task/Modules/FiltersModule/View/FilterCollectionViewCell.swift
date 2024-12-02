//
//  FilterCollectionViewCell.swift
//  Satender Task
//
//  Created by Satender Dagar on 01/12/24.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "FilterCollectionViewCell"
        
    private let label = UILabel()
    private let checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark"))
    private let stackView = UIStackView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Label setup
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        // Checkmark setup
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.tintColor = .black
        checkmarkImageView.isHidden = true
        
        // Stack View setup
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.addArrangedSubview(checkmarkImageView)
        stackView.addArrangedSubview(label)
        
        // Add StackView to contentView
        contentView.addSubview(stackView)
        
        // Capsule shape (rounded corners)
        contentView.layer.cornerRadius = 25
        contentView.layer.masksToBounds = true
        
        // Layout constraints for stack view
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
    
    func configure(with filterConfig: FilterData?) {
        label.text = filterConfig?.name
        checkmarkImageView.isHidden = !(filterConfig?.isSelected ?? false)
        contentView.backgroundColor = filterConfig?.isSelected ?? false ? UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 1) : UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
    }
}
