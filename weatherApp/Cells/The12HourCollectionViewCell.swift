//
//  The12HourCollectionViewCell.swift
//  weatherApp
//
//  Created by Marek Fryčák on 19.07.2023.
//

import UIKit

class The12HourCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var The12HourTemperatureLabel: UILabel!
    @IBOutlet weak var The12HourImageView: UIImageView!
    
    
 

    override func awakeFromNib() {
        super.awakeFromNib()
        setupConstraints()
    }
    
    func setupConstraints() {
        // Step 1: Disable autoresizing masks
        hourLabel.translatesAutoresizingMaskIntoConstraints = false
        The12HourTemperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        The12HourImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Step 2: Define constraints
        let constraints = [
            // Hour label constraints
            hourLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            hourLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            hourLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            hourLabel.heightAnchor.constraint(equalToConstant: 15),
            
            
            // Image view constraints
            The12HourImageView.topAnchor.constraint(equalTo: hourLabel.bottomAnchor, constant: 7),
            The12HourImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            The12HourImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            // Assuming square image
            
           
      

            // Temperature label constraints
            The12HourTemperatureLabel.topAnchor.constraint(equalTo: The12HourImageView.bottomAnchor, constant: 7),
            The12HourTemperatureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            The12HourTemperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            The12HourTemperatureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ]

        // Step 3: Activate constraints
        NSLayoutConstraint.activate(constraints)
    }
}
