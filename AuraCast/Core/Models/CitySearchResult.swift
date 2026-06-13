//
//  CitySearchResult.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 11/06/2026.
//

import Foundation

struct CitySearchResult: Codable, Identifiable, Hashable {
    var id: String {
        return "\(lat),\(lon)"
    }
    
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    
    enum CodingKeys: String, CodingKey {
        case name
        case region
        case country
        case lat
        case lon
    }
    
    init(name: String, region: String = "", country: String, lat: Double, lon: Double) {
        self.name = name
        self.region = region
        self.country = country
        self.lat = lat
        self.lon = lon
    }
}
