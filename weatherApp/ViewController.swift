//
//  ViewController.swift
//  weatherApp
//
//  Created by Marek Fryčák on 11.05.2023.
//

import UIKit
import CoreLocation
import Alamofire
import Foundation


class ViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIApplicationDelegate, UICollectionViewDelegateFlowLayout {
    
    let localizationLabel           = UILabel()
    let mainActualTemperatureLabel  = UILabel()
    let actualWeatherText1Label     = UILabel()
    let weatherImage                = UIImageView()
    let the12HourHeadLineLabel      = UILabel()
    let backgroundImage             = UIImageView()
    let loadingView                 = UIView()
    
    
    @IBOutlet weak var the12HourCollectionView: UICollectionView!
    
    
    //let apiKey = "i8MpoGveIdZPG3gDWasL7a1QVeh0BhrE"
    let apiKey = "Br5Tsp8LESxMZWW2ks7RqJIXPWcztpkE"
    
    let locationManager = CLLocationManager()
    
    var locationCityKey = ""
    
    var locationName = ""
    
    var actualWeather = [ActualWeatherElement]()
    
    var the12HourForecast = [The12HourForecastElement]()
    
    var weatherIconNumber = 1
    
    var isDayTime = Bool()
    
    var curentLatitude: Double = 0 //50.073658
    
    var curentLongitude: Double = 0 //14.41854
    
    var currentConstraints: [NSLayoutConstraint] = []
    
    let customFont = UIFont(name: "Chocolate Bar Demo", size: 60) ?? UIFont.systemFont(ofSize: 60)

    
    
    
//      MUSIM DODELAT:
//    
//    CATCH ERRORS
//    CollectionView programatically
//    
//    
//               !!!!
//
//
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        the12HourCollectionView.dataSource = self
        the12HourCollectionView.delegate = self
        
// Note: func NotificationCenter bellow reload data everytime the app is going active. func is off because limited API calls
//      NotificationCenter.default.addObserver(self, selector: #selector(getDataWrapper), name: Notification.Name("getData"), object: nil)
            
    }
      
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager was called")
        if let location = locations.last {
            let latitude    = location.coordinate.latitude
            let longitude   = location.coordinate.longitude
            curentLatitude  = latitude
            curentLongitude = longitude
            print("curren Latitude:" + "\(curentLatitude)")
            print("curren Latitude:" + "\(curentLongitude)")
            manager.stopUpdatingLocation()
            getDataWrapper()
            print("getData from locationManager was called")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error with location manager: \(error)")
    }
    
    @objc func getDataWrapper() {
        Task {
            await getData()
            
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass || traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
            // Update the font size based on the new traitCollection
            let newFontSize: CGFloat = calculateNewFontSize() // Replace with your logic to calculate the new font size
            
            // Animate the font size change
            UIView.transition(with: mainActualTemperatureLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.mainActualTemperatureLabel.font = self.customFont.withSize(newFontSize)
            }, completion: nil)
            
            UIView.transition(with: actualWeatherText1Label, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.actualWeatherText1Label.font = self.customFont.withSize(newFontSize)
            }, completion: nil)
            
            setupUI()
            styleUI()
        }
    }

    func calculateNewFontSize() -> CGFloat {
        // Replace this logic with your own to calculate the new font size based on traitCollection changes.
        // You can use traitCollection.horizontalSizeClass and traitCollection.verticalSizeClass to determine the new size.
        // For example:
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            return 100
        } else {
            return 100.0
        }
    }

    
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//
//        if traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass || traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
//            setupUI()
//            styleUI()
//        }
//    }
    
    func addSubviews() {
        
        view.addSubview(backgroundImage)
        view.addSubview(weatherImage)
        view.addSubview(mainActualTemperatureLabel)
        view.addSubview(actualWeatherText1Label)
        view.addSubview(localizationLabel)
        view.addSubview(the12HourHeadLineLabel)
        view.addSubview(the12HourCollectionView)
        view.addSubview(loadingView)
        
        
        loadingView.backgroundColor = UIColor.black
        loadingView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        loadingView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        loadingView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        backgroundImage.translatesAutoresizingMaskIntoConstraints             = false
        weatherImage.translatesAutoresizingMaskIntoConstraints                = false
        actualWeatherText1Label.translatesAutoresizingMaskIntoConstraints     = false
        mainActualTemperatureLabel.translatesAutoresizingMaskIntoConstraints  = false
        localizationLabel.translatesAutoresizingMaskIntoConstraints           = false
        the12HourHeadLineLabel.translatesAutoresizingMaskIntoConstraints      = false
        the12HourCollectionView.translatesAutoresizingMaskIntoConstraints     = false
        loadingView.translatesAutoresizingMaskIntoConstraints                 = false
        
        
    }
    
    // Alamofire
    func getForecastKey() async throws {
        let url = URL(string:"https://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=\(apiKey)&q=\(curentLatitude)%2C\(curentLongitude)&language=cs-cz")
        print(url)
        let result = try await AF.request(url!, method: .get).serializingDecodable(LocalizedInfo.self).value
        locationCityKey = result.key
        locationName = result.parentCity.localizedName
        print("getForecastKey was called")
        return
    }
    
    func getActualWeatherData() async throws -> [ActualWeatherElement] {
        let url = URL(string: "https://dataservice.accuweather.com/currentconditions/v1/\(locationCityKey)?apikey=\(apiKey)&language=cs-cz")
    //   https://dataservice.accuweather.com/currentconditions/v1/125542?apikey=i8MpoGveIdZPG3gDWasL7a1QVeh0BhrE&language=cs-cz
        let actualWeatherData =  try await AF.request(url!, method: .get).serializingDecodable([ActualWeatherElement].self).value
        actualWeather = actualWeatherData
        weatherIconNumber = actualWeatherData[0].weatherIcon
        isDayTime = actualWeatherData[0].isDayTime
        print("getActualWeatherData was called")
        return actualWeatherData
    }
    
    func get12hourForecastData() async throws -> [The12HourForecastElement] {
        let url = URL(string: "https://dataservice.accuweather.com/forecasts/v1/hourly/12hour/\(locationCityKey)?apikey=\(apiKey)&metric=true")
        let the12HourForecastData =  try await AF.request(url!, method: .get).serializingDecodable([The12HourForecastElement].self).value
        the12HourForecast = the12HourForecastData
        print("get12hourForecastData was called")
        return the12HourForecastData
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return the12HourForecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "The12HourCollectionViewCell", for: indexPath) as! The12HourCollectionViewCell
        let date = Date(timeIntervalSince1970: TimeInterval(the12HourForecast[indexPath.row].epochDateTime))
        let calendar = Calendar.current
        
        cell.hourLabel.text = calendar.component(.hour, from: date).description
        cell.The12HourTemperatureLabel.text = (" \(Int(the12HourForecast[indexPath.row].temperature3.value.rounded()).description)°")
        cell.The12HourImageView.image       = UIImage(named: the12HourForecast[indexPath.row].weatherIcon.description)
        cell.The12HourImageView.contentMode = .scaleAspectFit
        collectionView.backgroundColor      = .none
        cell.layer.cornerRadius             = 25
        cell.backgroundColor = .white.withAlphaComponent(0.3)
        
        cell.hourLabel.textAlignment                 = .center
        cell.hourLabel.textColor                     = .white
        cell.hourLabel.shadowColor                   = .black.withAlphaComponent(8)
        
        cell.The12HourTemperatureLabel.textAlignment = .center
        cell.The12HourTemperatureLabel.textColor     = .white
        cell.The12HourTemperatureLabel.shadowColor   = .black
        cell.hourLabel.font = customFont.withSize(20)
        cell.The12HourTemperatureLabel.font = customFont.withSize(20)
        
        cell.The12HourImageView.layer.shadowColor   = UIColor.black.cgColor
        cell.The12HourImageView.layer.shadowOffset  = CGSize(width: 0, height: 4) // You can adjust this
        cell.The12HourImageView.layer.shadowRadius  = 5 // This makes the shadow wider/larger
        cell.The12HourImageView.layer.shadowOpacity = 0.6 // Adjust the opacity as needed
        cell.The12HourImageView.layer.masksToBounds = false
        
        cell.The12HourTemperatureLabel.layer.shadowColor   = UIColor.black.cgColor
        cell.The12HourTemperatureLabel.layer.shadowOffset  = CGSize(width: 0, height: 4) // You can adjust this
        cell.The12HourTemperatureLabel.layer.shadowRadius  = 5 // This makes the shadow wider/larger
        cell.The12HourTemperatureLabel.layer.shadowOpacity = 0.6 // Adjust the opacity as needed
        cell.The12HourTemperatureLabel.layer.masksToBounds = false
        
        cell.hourLabel.layer.shadowColor   = UIColor.black.cgColor
        cell.hourLabel.layer.shadowOffset  = CGSize(width: 0, height: 4) // You can adjust this
        cell.hourLabel.layer.shadowRadius  = 5 // This makes the shadow wider/larger
        cell.hourLabel.layer.shadowOpacity = 0.6 // Adjust the opacity as needed
        cell.hourLabel.layer.masksToBounds = false
        

        return cell
    }
    
    
    func hideLoadingView () {
        UIView.animate(withDuration: 0.5, animations: { [self] in
            self.loadingView.alpha = 0.0
        }) {  (completed) in
            if completed {
                self.loadingView.isHidden = true
            }
        }
    }
    
    @MainActor
    func getData() async {
        do {
                self.addSubviews()
            try await getForecastKey()
            try await getActualWeatherData()
            try await get12hourForecastData()
            DispatchQueue.main.async {
                self.the12HourCollectionView.reloadData()
                self.setupUI()
                self.styleUI()
          //      self.loadingView.isHidden = true
               self.hideLoadingView()
            }
 
        } catch {
            print(error)
        }
    }
    
    
    func setupUI() {
        NSLayoutConstraint.deactivate(currentConstraints)
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.compact, .regular):
            currentConstraints = setupConstraintsForCompactWidthRegularHeight()
        case (.compact, .compact):
            currentConstraints = setupConstraintsForCompactWidthCompactHeight()
        case (.regular, .compact):
            currentConstraints = setupConstraintsForRegularWidthCompactHeight()
        case (.regular, .regular):
            currentConstraints = setupConstraintsForRegularWidthRegularHeight()
        default:
            break
        }
        
        NSLayoutConstraint.activate(currentConstraints)
        view.layoutIfNeeded()
        
    }
    
    func setupConstraintsForCompactWidthRegularHeight() -> [NSLayoutConstraint] {
        // Set up constraints for iPhone portrait
        return [
            
            backgroundImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            
            weatherImage.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            weatherImage.topAnchor.constraint(
                equalTo: view.topAnchor, constant: 280),
            weatherImage.widthAnchor.constraint(
                equalToConstant: 350),
            weatherImage.heightAnchor.constraint(
                equalToConstant: 350),
            
            
            mainActualTemperatureLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            mainActualTemperatureLabel.topAnchor.constraint(
                equalTo: view.topAnchor, constant: 70),
            mainActualTemperatureLabel.widthAnchor.constraint(
                equalToConstant: 400),
            mainActualTemperatureLabel.heightAnchor.constraint(
                equalToConstant: 250),
            
            
            
            actualWeatherText1Label.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            actualWeatherText1Label.topAnchor.constraint(
                equalTo: view.topAnchor, constant: 250),
            actualWeatherText1Label.widthAnchor.constraint(
                equalToConstant: 300),
            actualWeatherText1Label.heightAnchor.constraint(
                equalToConstant: 35),
            
            
            localizationLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            localizationLabel.topAnchor.constraint(
                equalTo: view.topAnchor, constant: 100),
            localizationLabel.widthAnchor.constraint(
                equalToConstant: 200),
            localizationLabel.heightAnchor.constraint(
                equalToConstant: 15),
            
            
            the12HourHeadLineLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            the12HourHeadLineLabel.bottomAnchor.constraint(
                equalTo: the12HourCollectionView.topAnchor, constant: 0),
            the12HourHeadLineLabel.widthAnchor.constraint(
                equalToConstant: 350),
            the12HourHeadLineLabel.heightAnchor.constraint(
                equalToConstant: 20),
            
            
            the12HourCollectionView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            the12HourCollectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            the12HourCollectionView.leftAnchor.constraint(
                equalTo: view.leftAnchor, constant: 20),
            the12HourCollectionView.rightAnchor.constraint(
                equalTo: view.rightAnchor, constant: -20),
            the12HourCollectionView.heightAnchor.constraint(
                equalToConstant: 140),
            

        ]
    }
    
    func setupConstraintsForCompactWidthCompactHeight() -> [NSLayoutConstraint] {
        // Set up constraints for iPhone landscape
        // ...
        return[
            
   
            
            backgroundImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            weatherImage.topAnchor.constraint(
                equalTo: view.topAnchor, constant: 10),
            weatherImage.leftAnchor.constraint(
                equalTo: view.leftAnchor, constant: 80),
            weatherImage.widthAnchor.constraint(
                equalToConstant: 215),
            weatherImage.heightAnchor.constraint(
                equalToConstant: 215),
            
            
            mainActualTemperatureLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            mainActualTemperatureLabel.topAnchor.constraint(
                equalTo: view.topAnchor, constant: 30),
            mainActualTemperatureLabel.widthAnchor.constraint(
                equalToConstant: 400),
            mainActualTemperatureLabel.heightAnchor.constraint(
                equalToConstant: 120),
            
            
            actualWeatherText1Label.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            actualWeatherText1Label.topAnchor.constraint(
                equalTo: mainActualTemperatureLabel.bottomAnchor, constant: 0),
            actualWeatherText1Label.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: 0.5),
            actualWeatherText1Label.heightAnchor.constraint(
                equalToConstant: 30),
            
            
            localizationLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            localizationLabel.topAnchor.constraint(
                equalTo: view.topAnchor, constant: 20),
            localizationLabel.widthAnchor.constraint(
                equalToConstant: 200),
            localizationLabel.heightAnchor.constraint(
                equalToConstant: 30),
            
            
            the12HourHeadLineLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            the12HourHeadLineLabel.bottomAnchor.constraint(
                equalTo: the12HourCollectionView.topAnchor, constant: 0),
            the12HourHeadLineLabel.widthAnchor.constraint(
                equalToConstant: 350),
            the12HourHeadLineLabel.heightAnchor.constraint(
                equalToConstant: 20),
            
            
            the12HourCollectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            the12HourCollectionView.leftAnchor.constraint(
                equalTo: view.leftAnchor, constant: 20),
            the12HourCollectionView.rightAnchor.constraint(
                equalTo: view.rightAnchor, constant: -50),
            the12HourCollectionView.heightAnchor.constraint(
                equalToConstant: 140),
            

        
        ]
    }
    
    func setupConstraintsForRegularWidthCompactHeight() -> [NSLayoutConstraint] {
        // Set up constraints for iPhone MAX landscape
        // ...
        return [
            
            backgroundImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            
            weatherImage.topAnchor.constraint(
                equalTo: view.topAnchor, constant: 10),
            weatherImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 80),
           
            weatherImage.widthAnchor.constraint(
                equalToConstant: 270),
            weatherImage.heightAnchor.constraint(
                equalToConstant: 270),
            
            mainActualTemperatureLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            mainActualTemperatureLabel.topAnchor.constraint(
                equalTo: view.topAnchor, constant: 30),
            mainActualTemperatureLabel.widthAnchor.constraint(
                equalToConstant: 400),
            mainActualTemperatureLabel.heightAnchor.constraint(
                equalToConstant: 150),
            
            
            actualWeatherText1Label.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            actualWeatherText1Label.topAnchor.constraint(
                equalTo: mainActualTemperatureLabel.bottomAnchor, constant: 0),
            actualWeatherText1Label.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: 0.5),
            actualWeatherText1Label.heightAnchor.constraint(
                equalToConstant: 30),
            
            
            localizationLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            localizationLabel.topAnchor.constraint(
                equalTo: view.topAnchor, constant: 20),
            localizationLabel.widthAnchor.constraint(
                equalToConstant: 200),
            localizationLabel.heightAnchor.constraint(
                equalToConstant: 30),
            
            
            the12HourHeadLineLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            the12HourHeadLineLabel.bottomAnchor.constraint(
                equalTo: the12HourCollectionView.topAnchor, constant: 0),
            the12HourHeadLineLabel.widthAnchor.constraint(
                equalToConstant: 350),
            the12HourHeadLineLabel.heightAnchor.constraint(
                equalToConstant: 25),
            
            
            the12HourCollectionView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            the12HourCollectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            the12HourCollectionView.leftAnchor.constraint(
                equalTo: view.leftAnchor, constant: 20),
            the12HourCollectionView.rightAnchor.constraint(
                equalTo: view.rightAnchor, constant: -50),
            the12HourCollectionView.heightAnchor.constraint(
                equalToConstant: 140),
    

        ]
        
    }
    
    func setupConstraintsForRegularWidthRegularHeight() -> [NSLayoutConstraint] {
        // Set up constraints for iPad landscape
        // ...
        return [
            

            
            backgroundImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            
            weatherImage.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            weatherImage.topAnchor.constraint(
                equalTo: actualWeatherText1Label.bottomAnchor, constant: 0),
            weatherImage.bottomAnchor.constraint(equalTo: the12HourHeadLineLabel.topAnchor, constant: 0),
            
            weatherImage.widthAnchor.constraint(
                equalToConstant: 500),
            
      
            
            mainActualTemperatureLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            mainActualTemperatureLabel.topAnchor.constraint(
                equalTo: view.topAnchor, constant: 50),
            mainActualTemperatureLabel.widthAnchor.constraint(
                equalToConstant: 400),
            mainActualTemperatureLabel.heightAnchor.constraint(
                equalToConstant: 110),
            
            
            
            actualWeatherText1Label.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            actualWeatherText1Label.topAnchor.constraint(
                equalTo: mainActualTemperatureLabel.bottomAnchor, constant: 0),
            actualWeatherText1Label.widthAnchor.constraint(
                equalToConstant: 300),
            actualWeatherText1Label.heightAnchor.constraint(
                equalToConstant: 35),
            
            
            localizationLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            localizationLabel.bottomAnchor.constraint(
                equalTo: mainActualTemperatureLabel.topAnchor, constant: 0),
            localizationLabel.widthAnchor.constraint(
                equalToConstant: 200),
            localizationLabel.heightAnchor.constraint(
                equalToConstant: 15),
            
            
            the12HourHeadLineLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            the12HourHeadLineLabel.bottomAnchor.constraint(
                equalTo: the12HourCollectionView.topAnchor, constant: 0),
            the12HourHeadLineLabel.widthAnchor.constraint(
                equalToConstant: 350),
            the12HourHeadLineLabel.heightAnchor.constraint(
                equalToConstant: 20),
            
            
            the12HourCollectionView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            the12HourCollectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            the12HourCollectionView.leftAnchor.constraint(
                equalTo: view.leftAnchor, constant: 20),
            the12HourCollectionView.rightAnchor.constraint(
                equalTo: view.rightAnchor, constant: -20),
            the12HourCollectionView.heightAnchor.constraint(
                equalToConstant: 140),
            
//            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            loadingView.leftAnchor.constraint(equalTo: view.leftAnchor),
//            loadingView.rightAnchor.constraint(equalTo: view.rightAnchor),
//            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
//            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
    }
    
    func setBackgroundColor() {
        let weatherIcon = actualWeather[0].weatherIcon
        if weatherIcon >= 7 && weatherIcon < 30 && isDayTime {
            view.backgroundColor = UIColor(displayP3Red: 117/255, green: 132/255, blue: 183/255, alpha: 1)
            
        } else if isDayTime {
            view.backgroundColor = UIColor(displayP3Red: 103/255, green: 138/255, blue: 254/255, alpha: 1)
        } else {
            view.backgroundColor = UIColor(displayP3Red: 51/255, green: 44/255, blue: 112/255, alpha: 1)
            
        }
    }
    


    func styleUI() {
        setBackgroundColor()
        backgroundImage.contentMode = .scaleAspectFill
        
      
        
        let actualTemperature = Int(self.actualWeather[0].temperature2!.metric.value.rounded()).description
        self.mainActualTemperatureLabel.text = (" \(actualTemperature)°")
        
        mainActualTemperatureLabel.textColor     = .white
        mainActualTemperatureLabel.textAlignment = .center
        mainActualTemperatureLabel.shadowColor   = .black
        mainActualTemperatureLabel.font = customFont.withSize(150)
        mainActualTemperatureLabel.adjustsFontForContentSizeCategory = true
        mainActualTemperatureLabel.adjustsFontSizeToFitWidth = true
        mainActualTemperatureLabel.minimumScaleFactor = 0.5
        //setup shadow
        mainActualTemperatureLabel.layer.shadowColor = UIColor.black.cgColor
        mainActualTemperatureLabel.layer.shadowOffset = CGSize(width: 0, height: 4) // You can adjust this
        mainActualTemperatureLabel.layer.shadowRadius = 10 // This makes the shadow wider/larger
        mainActualTemperatureLabel.layer.shadowOpacity = 0.6 // Adjust the opacity as needed
        
        
        self.actualWeatherText1Label.text     = self.actualWeather[0].weatherText
        actualWeatherText1Label.textColor     = .white
        actualWeatherText1Label.shadowColor   = .black
        actualWeatherText1Label.textAlignment = .center
        actualWeatherText1Label.font          = customFont.withSize(30)
        //setup shadow
        actualWeatherText1Label.layer.shadowColor   = UIColor.black.cgColor
        actualWeatherText1Label.layer.shadowOffset  = CGSize(width: 0, height: 4) // You can adjust this
        actualWeatherText1Label.layer.shadowRadius  = 10 // This makes the shadow wider/larger
        actualWeatherText1Label.layer.shadowOpacity = 0.6 // Adjust the opacity as needed
        
        self.localizationLabel.text   = self.locationName.description
        localizationLabel.textColor   = .white
        localizationLabel.shadowColor = .black
        localizationLabel.font        = customFont.withSize(20)
        //setup shadow
        localizationLabel.layer.shadowColor     = UIColor.black.cgColor
        localizationLabel.layer.shadowOffset    = CGSize(width: 0, height: 4) // You can adjust this
        localizationLabel.layer.shadowRadius    = 10 // This makes the shadow wider/larger
        localizationLabel.layer.shadowOpacity   = 0.6 // Adjust the opacity as needed
        
        
        weatherImage.image               = UIImage(named: weatherIconNumber.description)
        weatherImage.contentMode         = .scaleAspectFit
        weatherImage.layer.shadowColor   = UIColor.black.cgColor
        weatherImage.layer.shadowOffset  = CGSize(width: -4, height: 4) // You can adjust this
        weatherImage.layer.shadowRadius  = 8 // This makes the shadow wider/larger
        weatherImage.layer.shadowOpacity = 0.6 // Adjust the opacity as needed
        weatherImage.layer.masksToBounds = false
        
        
        the12HourHeadLineLabel.text          = "12hodinová předpověď:"
        the12HourHeadLineLabel.textAlignment = .center
        the12HourHeadLineLabel.textColor     = .white
        the12HourHeadLineLabel.shadowColor   = .black
        the12HourHeadLineLabel.font          = customFont.withSize(20)
        //setup shadow
        the12HourHeadLineLabel.layer.shadowColor = UIColor.black.cgColor
        the12HourHeadLineLabel.layer.shadowOffset = CGSize(width: 0, height: 4) // You can adjust this
        the12HourHeadLineLabel.layer.shadowRadius = 10 // This makes the shadow wider/larger
        the12HourHeadLineLabel.layer.shadowOpacity = 0.8 // Adjust the opacity as needed
        
    }
    
}
