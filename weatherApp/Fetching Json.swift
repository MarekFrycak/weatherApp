//
//  Fetching Json.swift
//  weatherApp
//
//  Created by Marek Fryčák on 12.05.2023.
//

import Foundation

// MARK: - WelcomeElement
struct WelcomeElement: Codable {
    let id, localizedName, englishName: String
    let level: Int
    let localizedType, englishType, countryID: String

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case localizedName = "LocalizedName"
        case englishName = "EnglishName"
        case level = "Level"
        case localizedType = "LocalizedType"
        case englishType = "EnglishType"
        case countryID = "CountryID"
    }
}

typealias Welcome = [WelcomeElement]

let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)
