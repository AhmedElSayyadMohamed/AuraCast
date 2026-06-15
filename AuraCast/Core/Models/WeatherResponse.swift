import Foundation

struct WeatherResponse: Decodable {
    let location: LocationInfo
    let current: CurrentWeather
    let forecast: ForecastData
}

struct LocationInfo: Decodable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let localtime: String
}

struct CurrentWeather: Decodable {
    let temp_c: Double
    let feelslike_c: Double
    let humidity: Int
    let vis_km: Double
    let pressure_mb: Double
    let condition: Condition
}

struct Condition: Decodable {
    let text: String
    let icon: String
    let code: Int
}

struct ForecastData: Decodable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Decodable {
    let date: String
    let day: DaySummary
    let hour: [HourWeather]
}

struct DaySummary: Decodable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let condition: Condition
}

struct HourWeather: Decodable {
    let time: String
    let temp_c: Double
    let condition: Condition
}

extension WeatherResponse {
    func toSearchResult() -> CitySearchResult {
        return CitySearchResult(
            name: location.name,
            region: location.region,
            country: location.country,
            lat: location.lat,
            lon: location.lon
        )
    }
}
