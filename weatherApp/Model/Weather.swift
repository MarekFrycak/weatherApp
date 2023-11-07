// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let weather = try? JSONDecoder().decode(Weather.self, from: jsonData)

import Foundation

// MARK: - Weather
struct Weather: Codable {
    let headline: Headline?
    let dailyForecasts: [DailyForecast]?

    enum CodingKeys: String, CodingKey {
        case headline = "Headline"
        case dailyForecasts = "DailyForecasts"
    }
}

// MARK: - DailyForecast
struct DailyForecast: Codable {
    let epochDate: Int?
    let temperature: Temperature?
    let day, night: Day?
    let sources: [String]?
    let mobileLink, link: String?

    enum CodingKeys: String, CodingKey {
        case epochDate = "EpochDate"
        case temperature = "Temperature"
        case day = "Day"
        case night = "Night"
        case sources = "Sources"
        case mobileLink = "MobileLink"
        case link = "Link"
    }
}

// MARK: - Day
struct Day: Codable {
    let icon: Int?
    let iconPhrase: String?
    let hasPrecipitation: Bool?

    enum CodingKeys: String, CodingKey {
        case icon = "Icon"
        case iconPhrase = "IconPhrase"
        case hasPrecipitation = "HasPrecipitation"
    }
}

// MARK: - Temperature
struct Temperature: Codable {
    let minimum, maximum: Imum?

    enum CodingKeys: String, CodingKey {
        case minimum = "Minimum"
        case maximum = "Maximum"
    }
}

// MARK: - Imum
struct Imum: Codable {
    let value: Double?
    let unit: String?
    let unitType: Int?

    enum CodingKeys: String, CodingKey {
        case value = "Value"
        case unit = "Unit"
        case unitType = "UnitType"
    }
}

// MARK: - Headline
struct Headline: Codable {
    let text: String?

    enum CodingKeys: String, CodingKey {
        case text = "Text"
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    @propertyWrapper public struct NilOnFail<T: Codable>: Codable {
        
        public let wrappedValue: T?
        public init(from decoder: Decoder) throws {
            wrappedValue = try? T(from: decoder)
        }
        public init(_ wrappedValue: T?) {
            self.wrappedValue = wrappedValue
        }
    }
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into hasher: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
