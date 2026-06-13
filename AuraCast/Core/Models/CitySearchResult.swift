//
//  CitySearchResult.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 11/06/2026.
//

import Foundation

struct CitySearchResult: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var region: String
    var country: String
    var lat: Double
    var lon: Double
    
    init(id: String = UUID().uuidString, name: String, region: String = "", country: String, lat: Double, lon: Double) {
        self.id = id
        self.name = name
        self.region = region
        self.country = country
        self.lat = lat
        self.lon = lon
    }
}
