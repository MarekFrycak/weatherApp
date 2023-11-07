// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let actualWeather = try? JSONDecoder().decode(ActualWeather.self, from: jsonData)

import Foundation

// MARK: - ActualWeatherElement
struct ActualWeatherElement: Codable {
    let localObservationDateTime: String
    let epochTime: Int
    let weatherText: String
    let weatherIcon: Int
    let isDayTime: Bool
    let temperature2: Temperature2?
    let mobileLink, link: String

    enum CodingKeys: String, CodingKey {
        case localObservationDateTime = "LocalObservationDateTime"
        case epochTime = "EpochTime"
        case weatherText = "WeatherText"
        case weatherIcon = "WeatherIcon"
        case isDayTime = "IsDayTime"
        case temperature2 = "Temperature"
        case mobileLink = "MobileLink"
        case link = "Link"
    }
}

// MARK: - Temperature
struct Temperature2: Codable {
    let metric, imperial: Imperial

    enum CodingKeys: String, CodingKey {
        case metric = "Metric"
        case imperial = "Imperial"
    }
}

// MARK: - Imperial
struct Imperial: Codable {
    let value: Double
    let unit: String
    let unitType: Int
    
    enum CodingKeys: String, CodingKey {
        case value = "Value"
        case unit = "Unit"
        case unitType = "UnitType"
    }
}

typealias ActualWeather = [ActualWeatherElement]
