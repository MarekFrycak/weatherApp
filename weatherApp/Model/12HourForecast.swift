// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let the12HourForecast = try? JSONDecoder().decode(The12HourForecast.self, from: jsonData)

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseThe12HourForecastElement { response in
//     if let the12HourForecastElement = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - The12HourForecastElement
struct The12HourForecastElement: Decodable {
   // let dateTime: Date
    let epochDateTime, weatherIcon: Int
    let iconPhrase: String
    let hasPrecipitation, isDaylight: Bool
    let temperature3: Temperature3
    let precipitationProbability: Int
    let mobileLink, link: String
    let precipitationType, precipitationIntensity: String?

    enum CodingKeys: String, CodingKey {
   //     case dateTime = "DateTime"
        case epochDateTime = "EpochDateTime"
        case weatherIcon = "WeatherIcon"
        case iconPhrase = "IconPhrase"
        case hasPrecipitation = "HasPrecipitation"
        case isDaylight = "IsDaylight"
        case temperature3 = "Temperature"
        case precipitationProbability = "PrecipitationProbability"
        case mobileLink = "MobileLink"
        case link = "Link"
        case precipitationType = "PrecipitationType"
        case precipitationIntensity = "PrecipitationIntensity"
    }
}


// MARK: - Temperature
struct Temperature3: Decodable {
    let value: Double
    let unit: Unit
    let unitType: Int

    enum CodingKeys: String, CodingKey {
        case value = "Value"
        case unit = "Unit"
        case unitType = "UnitType"
    }
}

enum Unit: String, Codable {
    case c = "C"
}

typealias The12HourForecast = [The12HourForecastElement]

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

