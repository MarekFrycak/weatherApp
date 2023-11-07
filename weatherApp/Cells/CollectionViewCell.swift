//
//  The12HourCollectionViewCell.swift
//  weatherApp
//
//  Created by Marek Fryčák on 19.07.2023.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    
    var hourLabel = UILabel()
    var forecastLabel = UILabel()
    var forecastImageView = UIImageView()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSubviews() {
        contentView.addSubview(hourLabel)
        contentView.addSubview(forecastLabel)
        contentView.addSubview(forecastImageView)
     }
    
    func setupConstraints() {
        hourLabel.translatesAutoresizingMaskIntoConstraints = false
        forecastLabel.translatesAutoresizingMaskIntoConstraints = false
        forecastImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            // Hour label constraints
            hourLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            hourLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            hourLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            hourLabel.heightAnchor.constraint(equalToConstant: 15),

            // Image view constraints
            forecastImageView.topAnchor.constraint(equalTo: hourLabel.bottomAnchor, constant: 7),
            forecastImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            forecastImageView.widthAnchor.constraint(equalToConstant: 50),
            forecastImageView.heightAnchor.constraint(equalTo: forecastImageView.widthAnchor),

            // Temperature label constraints
            forecastLabel.topAnchor.constraint(equalTo: forecastImageView.bottomAnchor, constant: 7),
            forecastLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            forecastLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            forecastLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
