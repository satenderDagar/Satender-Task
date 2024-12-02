//
//  CoinCell.swift
//  Satender Task
//
//  Created by Satender Dagar on 01/12/24.
//

import UIKit

class CoinCell: UITableViewCell {
    
    static let reuseIdentifier: String = "CoinCell"
    
    private var nameLabel = UILabel()
    private var symbolLabel = UILabel()
    private var imageForNew = UIImageView(image: UIImage(named: ImageConstants.new))
    private var imageForCoin = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        imageForNew.contentMode = .scaleAspectFit
        imageForCoin.contentMode = .scaleAspectFit
        
        imageForNew.translatesAutoresizingMaskIntoConstraints = false
        imageForCoin.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(imageForNew)
        contentView.addSubview(imageForCoin)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            
            
            symbolLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            symbolLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            symbolLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // Constraints for imageForNew (Right side of the label)
            imageForNew.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageForNew.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),

            imageForNew.widthAnchor.constraint(equalToConstant: 24),
            imageForNew.heightAnchor.constraint(equalToConstant: 24),
            
            // Constraints for imageForCoin (Next to imageForNew)
            imageForCoin.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageForCoin.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            imageForCoin.widthAnchor.constraint(equalToConstant: 40),
            imageForCoin.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with coin: CoinData?) {
        nameLabel.text = coin?.name
        symbolLabel.text = coin?.symbol
                
        guard var coin = coin else {
            return
        }
        imageForNew.isHidden = !coin.isNew
        imageForCoin.image = UIImage(named: coin.imageName)
    }
}
