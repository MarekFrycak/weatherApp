//
//  WeatherCollectionViewCell.swift
//  weatherApp
//
//  Created by Marek Fryčák on 14.07.2023.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    static let identifier = "WeatherCollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    
    func configure(with model: The12HourForecastElement) {
        self.tempLabel.text = "\(model.temperature3)"
       // self.iconImageView.contentMode = .scaleToFill
      //  self.iconImageView.image = UIImage
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
