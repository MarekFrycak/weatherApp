// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let key = try? JSONDecoder().decode(Key.self, from: jsonData)

import Foundation

// MARK: - Key
struct LocalizedInfo: Codable {

    let key: String
    let localizedName, englishName, primaryPostalCode: String?
    let region, country: Country
    let parentCity: ParentCity?
    
    enum CodingKeys: String, CodingKey {
        case key = "Key"
        case localizedName = "LocalizedName"
        case englishName = "EnglishName"
        case primaryPostalCode = "PrimaryPostalCorde"
        case region = "Region"
        case country = "Country"
        case parentCity = "ParentCity"
    }
}

struct Country: Codable {
    let id, localizedName, englishName: String

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case localizedName = "LocalizedName"
        case englishName = "EnglishName"
    }
}

// MARK: - ParentCity
struct ParentCity: Codable {
    let key, localizedName, englishName: String

    enum CodingKeys: String, CodingKey {
        case key = "Key"
        case localizedName = "LocalizedName"
        case englishName = "EnglishName"
    }
}
