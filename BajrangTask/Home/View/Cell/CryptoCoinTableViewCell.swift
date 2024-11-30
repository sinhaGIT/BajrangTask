//
//  CryptoCoinTableViewCell.swift
//  BajrangTask
//
//  Created by Bajrang Sinha on 28/11/24.
//

import UIKit

class CryptoCoinTableViewCell: UITableViewCell {
    
    //For showing coin name text
    private let cryptoCoinNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18.0)
        label.textAlignment = .left
        label.textColor = UIColor(hex: 0xA6A6A6)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "dummy data"
        
        return label
    }()
    
    //For showing coin type text
    private let cryptoCoinSymbolLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15.0)
        label.textAlignment = .left
        label.textColor = UIColor(hex: 0x9A9A9A)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "dummy data"
        
        return label
    }()
    
    //For showing coin type image
    private let cryptoCoinTypeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    //For showing new coin
    private let cryptoCoinNewTagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private var viewModel: CryptoCoinCellViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        contentView.addSubview(cryptoCoinNameLabel)
        contentView.addSubview(cryptoCoinSymbolLabel)
        contentView.addSubview(cryptoCoinTypeImageView)
        contentView.addSubview(cryptoCoinNewTagImageView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(to viewModel: CryptoCoinCellViewModel) {
        self.viewModel = viewModel
        displayCellData()
    }
    
    private func displayCellData() {
        assert(viewModel != nil, "Cell view model is not found!!")
        
        cryptoCoinNameLabel.text = viewModel.getCryptoCoinName()
        cryptoCoinSymbolLabel.text = viewModel.getCryptoCoinSymbol()
        cryptoCoinTypeImageView.image = viewModel.getCryptoCoinTypeImage()
        cryptoCoinNewTagImageView.image = viewModel.getCryptoCoinNewTagImage()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cryptoCoinNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            cryptoCoinNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cryptoCoinNameLabel.trailingAnchor.constraint(equalTo: cryptoCoinTypeImageView.leadingAnchor, constant: -12),
            
            cryptoCoinSymbolLabel.topAnchor.constraint(equalTo: cryptoCoinNameLabel.bottomAnchor, constant: 10),
            cryptoCoinSymbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cryptoCoinSymbolLabel.trailingAnchor.constraint(greaterThanOrEqualTo: cryptoCoinTypeImageView.leadingAnchor, constant: -12),
            cryptoCoinSymbolLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            cryptoCoinTypeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12.0),
            cryptoCoinTypeImageView.heightAnchor.constraint(equalToConstant: 34.0),
            cryptoCoinTypeImageView.widthAnchor.constraint(equalToConstant: 34.0),
            cryptoCoinTypeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            cryptoCoinNewTagImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0.0),
            cryptoCoinNewTagImageView.heightAnchor.constraint(equalToConstant: 28.0),
            cryptoCoinNewTagImageView.widthAnchor.constraint(equalToConstant: 28.0),
            cryptoCoinNewTagImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0)
            
        ])
    }
}
