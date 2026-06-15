import Foundation

struct CitySearchResult: Codable, Identifiable {
    
    var id: String {
        return "\(lat),\(lon)"
    }
    
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    
    init(name: String, region: String = "", country: String, lat: Double, lon: Double) {
        self.name = name
        self.region = region
        self.country = country
        self.lat = lat
        self.lon = lon
    }
}
