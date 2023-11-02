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
    var the12HourCollectionView:      UICollectionView!
    let loadingView                 = UIView()
    let loadingLabel                = UILabel()
    
    var apiKey1 = Bundle.main.object(forInfoDictionaryKey: "ApiKey1") as? String
    var apiKey2 = Bundle.main.object(forInfoDictionaryKey: "ApiKey2") as? String
    
    let locationManager = CLLocationManager()
    var locationCityKey = ""
    var locationName = ""
    var actualWeather = [ActualWeatherElement]()
    var the12HourForecast = [The12HourForecastElement]()
    var weatherIconNumber = 1
    var isDayTime = Bool()
    var curentLatitude: Double = 0
    var curentLongitude: Double = 0
    var currentConstraints: [NSLayoutConstraint] = []
    let customFont = UIFont(name: "Chocolate Bar Demo", size: 60) ?? UIFont.systemFont(ofSize: 60)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        initializeCollectionView()
        the12HourCollectionView.dataSource = self
        the12HourCollectionView.delegate = self
    }
    
    func initializeCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        the12HourCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        the12HourCollectionView.register(The12HourCollectionViewCell.self, forCellWithReuseIdentifier: "The12HourCollectionViewCell")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude    = location.coordinate.latitude
            let longitude   = location.coordinate.longitude
            curentLatitude  = latitude
            curentLongitude = longitude
            manager.stopUpdatingLocation()
            getDataWrapper()
        }
    }
    
    @objc func getDataWrapper() {
        Task {
            await fetchData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error.localizedDescription)")
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                print("Location is currently unknown but Core Location will keep trying.")
            case .denied:
                print("Access to location services was denied by the user.")
            case .network:
                print("Network error occurred while trying to fetch location.")
            default:
                print("Another location error occurred: \(error.localizedDescription)")
            }
        }
    }
    
    func getLocalizedInfo() async throws {
        var resolvedURL: URL?
        
         if let url1 = URL(string:"https://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=\(String(describing: apiKey1!))&q=\(curentLatitude)%2C\(curentLongitude)&language=cs-cz") {
            resolvedURL = url1
            do {
                
                let result = try await AF.request(url1, method: .get).serializingDecodable(LocalizedInfo.self).value
                locationCityKey = result.key
                locationName = result.parentCity?.localizedName ?? "Vaše město"
                return
            } catch {
                print("Error fetching with Api Key 1: \(error)")
            }
        }
        
        if let url2 = URL(string: "https://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=\(String(describing: apiKey2!))&q=\(curentLatitude)%2C\(curentLongitude)&language=cs-cz") {
            resolvedURL = url2
            do {
                let result = try await AF.request(url2, method: .get).serializingDecodable(LocalizedInfo.self).value
                locationCityKey = result.key
                locationName = result.parentCity?.localizedName ?? "Vaše město"
            } catch {
                print("Error fetching with Api Key 2: \(error)")
            }
        }

        do {
            let mockData = try fetchLocalizedMockData()
            print("getLocalizedInfo used backup JSON data")
            locationCityKey = mockData.key
            locationName = mockData.parentCity?.localizedName ?? "Vaše město"
        } catch {
            throw error
        }
        return
    }
    
    func fetchLocalizedMockData() throws -> LocalizedInfo {
        guard let url = Bundle.main.url(forResource: "MockJsonLocalizedInfo", withExtension: "json") else {
            throw CustomError.invalidURL
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let mockInfo = try decoder.decode(LocalizedInfo.self, from: data)
            return mockInfo
        } catch {
             throw error
        }
    }
    
    enum CustomError: Error {
        case invalidURL
        case networkError(AFError)
    }
    
    func getActualWeatherData() async throws {
        var resolvedURL: URL?
        
        if let url1 = URL(string:"https://dataservice.accuweather.com/currentconditions/v1/\(locationCityKey)?apikey=\(String(describing: apiKey1!))&language=cs-cz") {
            resolvedURL = url1

            do {
                 let actualWeatherData = try await AF.request(url1, method: .get).serializingDecodable([ActualWeatherElement].self).value
                actualWeather = actualWeatherData
                weatherIconNumber = actualWeatherData[0].weatherIcon
                isDayTime = actualWeatherData[0].isDayTime
                return
            } catch {
                print("Error fetching with Api Key 1: \(error)")
            }
    }
        
        if let url2 = URL(string: "https://dataservice.accuweather.com/currentconditions/v1/\(locationCityKey)?apikey=\(String(describing: apiKey2!))&language=cs-cz") {
            resolvedURL = url2
            do {
                let actualWeatherData = try await AF.request(url2, method: .get).serializingDecodable([ActualWeatherElement].self).value
                    actualWeather = actualWeatherData
                    weatherIconNumber = actualWeatherData[0].weatherIcon
                    isDayTime = actualWeatherData[0].isDayTime
                    return
                
            } catch {
                print("Error fetching with Api Key 2: \(error)")
             }
            }
            do {
                let mockData = try fetchActualWeatherMockData()
                print("getActualWeatherData used backup JSON data")
                actualWeather = mockData
                weatherIconNumber = actualWeather[0].weatherIcon
                isDayTime = actualWeather[0].isDayTime
            } catch {
             throw error
            }
        return
    }

    func fetchActualWeatherMockData() throws -> [ActualWeatherElement] {
        guard let url = Bundle.main.url(forResource: "MockJsonActualWeatherData", withExtension: "json") else {
            print("fetchActualWeatherMockData chyba v url")
            throw CustomError.invalidURL
        }
        
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let mockInfo = try decoder.decode([ActualWeatherElement].self, from: data)
                return mockInfo
            } catch {
                throw error
            }
    }
    
    func get12hourForecastData() async throws -> [The12HourForecastElement] {
        var resolvedURL: URL?

        if let url1 = URL(string: "https://dataservice.accuweather.com/forecasts/v1/hourly/12hour/\(locationCityKey)?apikey=\(String(describing: apiKey1!))&metric=true") {
            resolvedURL = url1
            do {
             let the12HourForecastData =  try await AF.request(url1, method: .get).serializingDecodable([The12HourForecastElement].self).value
                the12HourForecast = the12HourForecastData
                return the12HourForecastData
            } catch {
                print("Error get12hourForecastData fetching with Api Key 1: \(error)")
             }
        }

        if let url2 = URL(string: "https://dataservice.accuweather.com/forecasts/v1/hourly/12hour/\(locationCityKey)?apikey=\(String(describing: apiKey2!))&metric=true") {
            resolvedURL = url2

            do {
                 let the12HourForecastData =  try await AF.request(url2, method: .get).serializingDecodable([The12HourForecastElement].self).value
                the12HourForecast = the12HourForecastData
                print("Api Key 2 was used in URL get12hourForecastData")
                return the12HourForecastData
            } catch {
                print("Error get12hourForecastData fetching with Api Key 2: \(error)")
            }
        }
        
        do {
            let mockData = try fetch12HourForecastMockData()
            the12HourForecast = mockData
            print("get12hourForecastData used backup JSON data")
        } catch {
            throw error
        }
        return the12HourForecast
     }

    func fetch12HourForecastMockData() throws -> [The12HourForecastElement] {
        guard let url = Bundle.main.url(forResource: "MockJson12HourForecastData", withExtension: "json") else {
             throw CustomError.invalidURL
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let mockInfo = try decoder.decode([The12HourForecastElement].self, from: data)
            return mockInfo
        } catch {
            throw error
        }
    }
            
    @MainActor
    func fetchData() async {
        do {
            self.addSubviews()
            try await getLocalizedInfo()
            try await getActualWeatherData()
            try await get12hourForecastData()
            DispatchQueue.main.async {
                self.the12HourCollectionView.reloadData()
                self.setupUI()
                self.styleUI()
                self.hideLoadingView()
            }
        } catch {
            print(error)
        }
    }
    
    func addSubviews() {
        view.addSubview(weatherImage)
        view.addSubview(mainActualTemperatureLabel)
        view.addSubview(actualWeatherText1Label)
        view.addSubview(localizationLabel)
        view.addSubview(the12HourHeadLineLabel)
        view.addSubview(the12HourCollectionView)
        view.addSubview(loadingView)
        view.addSubview(loadingLabel)
        
        loadingView.backgroundColor = UIColor(red: 93/255, green: 139/255, blue: 255/255, alpha: 1)
        loadingView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive     = true
        loadingView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive   = true
        loadingView.topAnchor.constraint(equalTo: view.topAnchor).isActive       = true
        loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        loadingLabel.text       = "n a č í t á m"
        loadingLabel.textColor  = .white
        loadingLabel.font       = customFont.withSize(30)
        loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        weatherImage.translatesAutoresizingMaskIntoConstraints                = false
        actualWeatherText1Label.translatesAutoresizingMaskIntoConstraints     = false
        mainActualTemperatureLabel.translatesAutoresizingMaskIntoConstraints  = false
        localizationLabel.translatesAutoresizingMaskIntoConstraints           = false
        the12HourHeadLineLabel.translatesAutoresizingMaskIntoConstraints      = false
        the12HourCollectionView.translatesAutoresizingMaskIntoConstraints     = false
        loadingView.translatesAutoresizingMaskIntoConstraints                 = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints                = false
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass || traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
            let newFontSize: CGFloat = calculateNewFontSize()
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
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            return 100
        } else {
            return 100
        }
    }
    
    func setupUI() {
        NSLayoutConstraint.deactivate(currentConstraints)
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.compact, .regular):
            setupCommonConstraints()
            setupConstraintsForCompactWidthRegularHeight()
            print("compact regular")
        case (.compact, .compact):
            setupCommonConstraints()
            setupConstraintsForCompactWidthCompactHeight()
            print("compact compact")
        case (.regular, .compact):
            setupCommonConstraints()
            setupConstraintsForRegularWidthCompactHeight()
            print("regular compact")
        case (.regular, .regular):
            setupCommonConstraints()
            setupConstraintsForRegularWidthRegularHeight()
            print("regular regular")
        default:
            break
        }
        NSLayoutConstraint.activate(currentConstraints)
        view.layoutIfNeeded()
    }
    
    func styleUI() {
        setBackgroundColor()
        
        self.localizationLabel.text     = self.locationName.description
        localizationLabel.textColor     = .white
        localizationLabel.shadowColor   = .black
        localizationLabel.font          = customFont.withSize(25)
        localizationLabel.textAlignment = .center
        applyShadow(to: localizationLabel.layer)
        
        let actualTemperature = Int(self.actualWeather[0].temperature2!.metric.value.rounded()).description
        self.mainActualTemperatureLabel.text = (" \(actualTemperature)°")
        
        mainActualTemperatureLabel.textColor                         = .white
        mainActualTemperatureLabel.textAlignment                     = .center
        mainActualTemperatureLabel.shadowColor                       = .black
        mainActualTemperatureLabel.font                              = customFont.withSize(140)
        applyShadow(to: mainActualTemperatureLabel.layer)

        self.actualWeatherText1Label.text     = self.actualWeather[0].weatherText
        actualWeatherText1Label.textColor     = .white
        actualWeatherText1Label.shadowColor   = .black
        actualWeatherText1Label.textAlignment = .center
        actualWeatherText1Label.font          = customFont.withSize(25)
        applyShadow(to: actualWeatherText1Label.layer)
        
        weatherImage.image               = UIImage(named: weatherIconNumber.description)
        weatherImage.contentMode         = .scaleAspectFit
        applyShadow(to: weatherImage.layer)
        
        the12HourHeadLineLabel.text          = "12hodinová předpověď:"
        the12HourHeadLineLabel.textAlignment = .center
        the12HourHeadLineLabel.textColor     = .white
        the12HourHeadLineLabel.shadowColor   = .black
        the12HourHeadLineLabel.font          = customFont.withSize(25)
        applyShadow(to: the12HourHeadLineLabel.layer)
    }
    
    func applyShadow(to layer: CALayer, shadowOffset: CGSize = CGSize(width: -5, height: 10)) {
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOffset  = shadowOffset
        layer.shadowRadius  = 10
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false
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
        
        cell.hourLabel.text                = calendar.component(.hour, from: date).description
        cell.hourLabel.font                = customFont.withSize(20)
        cell.hourLabel.textAlignment       = .center
        cell.hourLabel.textColor           = .white
        cell.hourLabel.shadowColor         = .black.withAlphaComponent(8)
        applyShadow(to: cell.hourLabel.layer)
        
        cell.The12HourTemperatureLabel.text                = (" \(Int(the12HourForecast[indexPath.row].temperature3.value.rounded()).description)°")
        cell.The12HourTemperatureLabel.textAlignment       = .center
        cell.The12HourTemperatureLabel.textColor           = .white
        cell.The12HourTemperatureLabel.shadowColor         = .black
        cell.The12HourTemperatureLabel.font                = customFont.withSize(20)
        applyShadow(to: cell.The12HourTemperatureLabel.layer)
        
        cell.The12HourImageView.image               = UIImage(named: the12HourForecast[indexPath.row].weatherIcon.description)
        cell.The12HourImageView.contentMode         = .scaleAspectFit
        applyShadow(to: cell.The12HourImageView.layer)
        
        cell.layer.cornerRadius             = 25
        cell.backgroundColor                = .white.withAlphaComponent(0.3)
        collectionView.backgroundColor      = .none
        collectionView.layer.masksToBounds  = false
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
        UIView.animate(withDuration: 0.5, animations: { [self] in
            self.loadingLabel.alpha = 0.0
        }) {  (completed) in
            if completed {
                self.loadingLabel.isHidden = true
            }
        }
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
    
    func setupCommonConstraints() {
        currentConstraints = [
            // localizationLabel Constraints
            localizationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            localizationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            localizationLabel.widthAnchor.constraint(equalToConstant: 200),
            localizationLabel.heightAnchor.constraint(equalToConstant: 30),
            
            // mainActualTemperatureLabel Constraints
            mainActualTemperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainActualTemperatureLabel.topAnchor.constraint(equalTo: localizationLabel.bottomAnchor, constant: 0),
            mainActualTemperatureLabel.widthAnchor.constraint(equalToConstant: 300),
            
            // actualWeatherText1Label Constraints
            actualWeatherText1Label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actualWeatherText1Label.topAnchor.constraint(equalTo: mainActualTemperatureLabel.bottomAnchor, constant: 0),
            actualWeatherText1Label.widthAnchor.constraint(equalToConstant: 300),
            
            // the12HourHeadLineLabel Constraints
            the12HourHeadLineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            the12HourHeadLineLabel.bottomAnchor.constraint(equalTo: the12HourCollectionView.topAnchor, constant: 0),
            the12HourHeadLineLabel.widthAnchor.constraint(equalToConstant: 350),
            
            // the12HourCollectionView Constraints
            the12HourCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            the12HourCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
        ]
    }

    func setupConstraintsForCompactWidthRegularHeight() -> [NSLayoutConstraint] {
            currentConstraints += [
            weatherImage.topAnchor.constraint(equalTo: actualWeatherText1Label.bottomAnchor, constant: 0),
            weatherImage.leftAnchor.constraint(equalTo: view.leftAnchor),
            weatherImage.rightAnchor.constraint(equalTo: view.rightAnchor),
            weatherImage.bottomAnchor.constraint(equalTo: the12HourHeadLineLabel.topAnchor),
            mainActualTemperatureLabel.heightAnchor.constraint(equalToConstant: 150),
            actualWeatherText1Label.heightAnchor.constraint(equalToConstant: 30),
            the12HourHeadLineLabel.heightAnchor.constraint(equalToConstant: 20),
            the12HourCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            the12HourCollectionView.heightAnchor.constraint(equalToConstant: 140)
        ]
        return currentConstraints
    }

    func setupConstraintsForCompactWidthCompactHeight() -> [NSLayoutConstraint] {
            currentConstraints += [
            weatherImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            weatherImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 80),
            weatherImage.widthAnchor.constraint(equalToConstant: 215),
            weatherImage.heightAnchor.constraint(equalToConstant: 215),
            mainActualTemperatureLabel.heightAnchor.constraint(equalToConstant: 120),
            actualWeatherText1Label.heightAnchor.constraint(equalToConstant: 30),
            the12HourHeadLineLabel.heightAnchor.constraint(equalToConstant: 30),
            the12HourCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            the12HourCollectionView.heightAnchor.constraint(equalToConstant: 140)
        ]
        return currentConstraints
    }

    func setupConstraintsForRegularWidthCompactHeight() -> [NSLayoutConstraint] {
            currentConstraints += [
            weatherImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            weatherImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 80),
            weatherImage.widthAnchor.constraint(equalToConstant: 270),
            weatherImage.heightAnchor.constraint(equalToConstant: 270),
            mainActualTemperatureLabel.heightAnchor.constraint(equalToConstant: 150),
            actualWeatherText1Label.heightAnchor.constraint(equalToConstant: 30),
            the12HourHeadLineLabel.heightAnchor.constraint(equalToConstant: 25),
            the12HourCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            the12HourCollectionView.heightAnchor.constraint(equalToConstant: 140)
        ]
        return currentConstraints
    }

    func setupConstraintsForRegularWidthRegularHeight() -> [NSLayoutConstraint] {
          currentConstraints +=  [
            weatherImage.topAnchor.constraint(equalTo: actualWeatherText1Label.bottomAnchor, constant: 0),
            weatherImage.leftAnchor.constraint(equalTo: view.leftAnchor),
            weatherImage.rightAnchor.constraint(equalTo: view.rightAnchor),
            weatherImage.bottomAnchor.constraint(equalTo: the12HourHeadLineLabel.topAnchor),
            mainActualTemperatureLabel.heightAnchor.constraint(equalToConstant: 120),
            actualWeatherText1Label.heightAnchor.constraint(equalToConstant: 35),
            the12HourHeadLineLabel.heightAnchor.constraint(equalToConstant: 20),
            the12HourHeadLineLabel.heightAnchor.constraint(equalToConstant: 20),
            the12HourCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            the12HourCollectionView.heightAnchor.constraint(equalToConstant: 140)        ]
        return currentConstraints
    }

}
