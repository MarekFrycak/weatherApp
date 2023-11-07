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
    
    let localizationLabel = UILabel()
    let mainActualTemperatureLabel = UILabel()
    let actualWeatherText1Label = UILabel()
    let weatherImage = UIImageView()
    let forecastHeadLineLabel = UILabel()
    var forecastCollectionView: UICollectionView!
    let loadingView = UIView()
    let loadingLabel = UILabel()
    
    let locationManager = CLLocationManager()
    var locationCityKey = ""
    var locationName = ""
    var actualWeather = [ActualWeatherElement]()
    var forecast = [The12HourForecastElement]()
    var weatherIconNumber = 1
    var isDayTime = Bool()
    var curentLatitude: Double = 0
    var curentLongitude: Double = 0
    var currentConstraints: [NSLayoutConstraint] = []
    let customFont = UIFont(name: "Chocolate Bar Demo", size: 60) ?? UIFont.systemFont(ofSize: 60)
    var apiKey1 = Bundle.main.object(forInfoDictionaryKey: "ApiKey1") as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        initializeCollectionView()
        forecastCollectionView.dataSource = self
        forecastCollectionView.delegate = self
    }
    
    func initializeCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        forecastCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        forecastCollectionView.register(ForecastCollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            curentLatitude = latitude
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
        if let url1 = URL(string:"https://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=\(String(describing: apiKey1!))&q=\(curentLatitude)%2C\(curentLongitude)&language=cs-cz") {
            do {
                let result = try await AF.request(url1, method: .get).serializingDecodable(LocalizedInfo.self).value
                locationCityKey = result.key
                locationName = result.parentCity?.localizedName ?? "Vaše město"
                return
            } catch {
                print("Error fetching with Api Key 1: \(error)")
            }
        } else {
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
        if let url1 = URL(string:"https://dataservice.accuweather.com/currentconditions/v1/\(locationCityKey)?apikey=\(String(describing: apiKey1!))&language=cs-cz") {
            do {
                let actualWeatherData = try await AF.request(url1, method: .get).serializingDecodable([ActualWeatherElement].self).value
                actualWeather = actualWeatherData
                weatherIconNumber = actualWeatherData[0].weatherIcon
                isDayTime = actualWeatherData[0].isDayTime
                return
            } catch {
                print("Error fetching with Api Key 1: \(error)")
            }
        } else {
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

    func getForecastData() async throws {
        if let url1 = URL(string: "https://dataservice.accuweather.com/forecasts/v1/hourly/12hour/\(locationCityKey)?apikey=\(String(describing: apiKey1!))&metric=true") {
            do {
                let hourForecastData =  try await AF.request(url1, method: .get).serializingDecodable([The12HourForecastElement].self).value
                forecast = hourForecastData
            } catch {
                print("Error getForecastData fetching with Api Key 1: \(error)")
            }
        }
        else {
            do {
                let mockData = try fetchForecastMockData()
                forecast = mockData
                print("getForecastData used backup JSON data")
            } catch {
                throw error
            }
        }
    }
    
    func fetchForecastMockData() throws -> [The12HourForecastElement] {
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
            addSubviews()
            try await getLocalizedInfo()
            try await getActualWeatherData()
            try await getForecastData()
            forecastCollectionView.reloadData()
            setupUI()
            styleUI()
            hideLoadingView()
            } catch {
            print(error)
        }
    }
    
    func addSubviews() {
        view.addSubview(weatherImage)
        view.addSubview(mainActualTemperatureLabel)
        view.addSubview(actualWeatherText1Label)
        view.addSubview(localizationLabel)
        view.addSubview(forecastHeadLineLabel)
        view.addSubview(forecastCollectionView)
        view.addSubview(loadingView)
        view.addSubview(loadingLabel)
        
        loadingView.backgroundColor = UIColor(red: 93/255, green: 139/255, blue: 255/255, alpha: 1)
        loadingView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        loadingView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        loadingView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        loadingLabel.text = "n a č í t á m"
        loadingLabel.textColor = .white
        loadingLabel.font = customFont.withSize(30)
        loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        weatherImage.translatesAutoresizingMaskIntoConstraints = false
        actualWeatherText1Label.translatesAutoresizingMaskIntoConstraints = false
        mainActualTemperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        localizationLabel.translatesAutoresizingMaskIntoConstraints = false
        forecastHeadLineLabel.translatesAutoresizingMaskIntoConstraints = false
        forecastCollectionView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
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
        case (.compact, .compact):
            setupCommonConstraints()
            setupConstraintsForCompactWidthCompactHeight()
        case (.regular, .compact):
            setupCommonConstraints()
            setupConstraintsForRegularWidthCompactHeight()
        case (.regular, .regular):
            setupCommonConstraints()
            setupConstraintsForRegularWidthRegularHeight()
        default:
            break
        }
        NSLayoutConstraint.activate(currentConstraints)
        view.layoutIfNeeded()
    }
    
    func styleUI() {
        setBackgroundColor()
        
        self.localizationLabel.text = self.locationName.description
        localizationLabel.textColor = .white
        localizationLabel.shadowColor = .black
        localizationLabel.font = customFont.withSize(25)
        localizationLabel.textAlignment = .center
        applyShadow(to: localizationLabel.layer)
        
        let actualTemperature = Int(self.actualWeather[0].temperature2!.metric.value.rounded()).description
        self.mainActualTemperatureLabel.text = (" \(actualTemperature)°")
        
        mainActualTemperatureLabel.textColor = .white
        mainActualTemperatureLabel.textAlignment = .center
        mainActualTemperatureLabel.shadowColor = .black
        mainActualTemperatureLabel.font = customFont.withSize(140)
        applyShadow(to: mainActualTemperatureLabel.layer)

        self.actualWeatherText1Label.text = self.actualWeather[0].weatherText
        actualWeatherText1Label.textColor = .white
        actualWeatherText1Label.shadowColor = .black
        actualWeatherText1Label.textAlignment = .center
        actualWeatherText1Label.font = customFont.withSize(25)
        applyShadow(to: actualWeatherText1Label.layer)
        
        weatherImage.image = UIImage(named: weatherIconNumber.description)
        weatherImage.contentMode = .scaleAspectFit
        applyShadow(to: weatherImage.layer)
        
        forecastHeadLineLabel.text = "12hodinová předpověď:"
        forecastHeadLineLabel.textAlignment = .center
        forecastHeadLineLabel.textColor = .white
        forecastHeadLineLabel.shadowColor = .black
        forecastHeadLineLabel.font = customFont.withSize(25)
        applyShadow(to: forecastHeadLineLabel.layer)
    }
    
    func applyShadow(to layer: CALayer, shadowOffset: CGSize = CGSize(width: -5, height: 10)) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! ForecastCollectionViewCell
        let date = Date(timeIntervalSince1970: TimeInterval(forecast[indexPath.row].epochDateTime))
        let calendar = Calendar.current
        
        cell.hourLabel.text = calendar.component(.hour, from: date).description
        cell.hourLabel.font = customFont.withSize(20)
        cell.hourLabel.textAlignment = .center
        cell.hourLabel.textColor = .white
        cell.hourLabel.shadowColor = .black.withAlphaComponent(8)
        applyShadow(to: cell.hourLabel.layer)
        
        cell.forecastLabel.text = (" \(Int(forecast[indexPath.row].temperature3.value.rounded()).description)°")
        cell.forecastLabel.textAlignment = .center
        cell.forecastLabel.textColor = .white
        cell.forecastLabel.shadowColor = .black
        cell.forecastLabel.font = customFont.withSize(20)
        applyShadow(to: cell.forecastLabel.layer)
        
        cell.forecastImageView.image = UIImage(named: forecast[indexPath.row].weatherIcon.description)
        cell.forecastImageView.contentMode = .scaleAspectFit
        applyShadow(to: cell.forecastImageView.layer)
        
        cell.layer.cornerRadius = 25
        cell.backgroundColor = .white.withAlphaComponent(0.3)
        collectionView.backgroundColor = .none
        collectionView.layer.masksToBounds = false
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
            // forecastHeadLineLabel Constraints
            forecastHeadLineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forecastHeadLineLabel.bottomAnchor.constraint(equalTo: forecastCollectionView.topAnchor, constant: 0),
            forecastHeadLineLabel.widthAnchor.constraint(equalToConstant: 350),
             // forecastCollectionView Constraints
            forecastCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            forecastCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
        ]
    }

    func setupConstraintsForCompactWidthRegularHeight() {
            currentConstraints += [
            weatherImage.topAnchor.constraint(equalTo: actualWeatherText1Label.bottomAnchor, constant: 0),
            weatherImage.leftAnchor.constraint(equalTo: view.leftAnchor),
            weatherImage.rightAnchor.constraint(equalTo: view.rightAnchor),
            weatherImage.bottomAnchor.constraint(equalTo: forecastHeadLineLabel.topAnchor),
            mainActualTemperatureLabel.heightAnchor.constraint(equalToConstant: 150),
            actualWeatherText1Label.heightAnchor.constraint(equalToConstant: 30),
            forecastHeadLineLabel.heightAnchor.constraint(equalToConstant: 20),
            forecastCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            forecastCollectionView.heightAnchor.constraint(equalToConstant: 140)
        ]
    }

    func setupConstraintsForCompactWidthCompactHeight() {
            currentConstraints += [
            weatherImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            weatherImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            weatherImage.widthAnchor.constraint(equalToConstant: 215),
            weatherImage.heightAnchor.constraint(equalToConstant: 215),
            mainActualTemperatureLabel.heightAnchor.constraint(equalToConstant: 120),
            actualWeatherText1Label.heightAnchor.constraint(equalToConstant: 30),
            forecastHeadLineLabel.heightAnchor.constraint(equalToConstant: 30),
            forecastCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            forecastCollectionView.heightAnchor.constraint(equalToConstant: 140)
        ]
    }

    func setupConstraintsForRegularWidthCompactHeight() {
            currentConstraints += [
            weatherImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            weatherImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 60),
            weatherImage.widthAnchor.constraint(equalToConstant: 270),
            weatherImage.heightAnchor.constraint(equalToConstant: 270),
            mainActualTemperatureLabel.heightAnchor.constraint(equalToConstant: 150),
            actualWeatherText1Label.heightAnchor.constraint(equalToConstant: 30),
            forecastHeadLineLabel.heightAnchor.constraint(equalToConstant: 25),
            forecastCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            forecastCollectionView.heightAnchor.constraint(equalToConstant: 140)
        ]
    }

    func setupConstraintsForRegularWidthRegularHeight() {
          currentConstraints +=  [
            weatherImage.topAnchor.constraint(equalTo: actualWeatherText1Label.bottomAnchor, constant: 0),
            weatherImage.leftAnchor.constraint(equalTo: view.leftAnchor),
            weatherImage.rightAnchor.constraint(equalTo: view.rightAnchor),
            weatherImage.bottomAnchor.constraint(equalTo: forecastHeadLineLabel.topAnchor),
            mainActualTemperatureLabel.heightAnchor.constraint(equalToConstant: 120),
            actualWeatherText1Label.heightAnchor.constraint(equalToConstant: 35),
            forecastHeadLineLabel.heightAnchor.constraint(equalToConstant: 20),
            forecastHeadLineLabel.heightAnchor.constraint(equalToConstant: 20),
            forecastCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            forecastCollectionView.heightAnchor.constraint(equalToConstant: 140)        ]
     }

}
