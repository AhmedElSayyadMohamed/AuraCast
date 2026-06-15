import Foundation

protocol WeatherRepositoryProtocol {
    func getWeatherForecast(lat: Double, lon: Double) async throws -> WeatherResponse
    func searchCities(query: String) async throws -> [CitySearchResult]
    func getFavoriteLocations() -> [Forecast]
    func addLocationToFavorites(forecast: Forecast)
    func removeLocationFromFavorites(lat: Double, lon: Double)
    func checkIsFavorite(lat: Double, lon: Double) -> Bool
}

class WeatherRepository: WeatherRepositoryProtocol {
    
    private let networkHelper: NetworkHelper
    private let coreDataManager: CoreDataManager

    init(networkHelper: NetworkHelper = NetworkHelper(),
         coreDataManager: CoreDataManager = .shared) {
        self.networkHelper = networkHelper
        self.coreDataManager = coreDataManager
    }
    
    func getWeatherForecast(lat: Double, lon: Double) async throws -> WeatherResponse {
        return try await networkHelper.fetchWeather(lat: lat, lon: lon)
    }
    
    func searchCities(query: String) async throws -> [CitySearchResult] {
        return try await networkHelper.searchCities(query: query)
    }
    func getFavoriteLocations() -> [Forecast] {
        let savedEntities = coreDataManager.fetchAllLocations()
        
        return savedEntities.map { entity in
            Forecast(
                id: UUID(),
                date: entity.dateAdded ?? Date(),
                weather: Weather(rawValue: entity.weatherCondition ?? "") ?? .cloudy,
                probability: 0,
                temperature: Int(entity.temperature),
                high: Int(entity.high),
                low: Int(entity.low),
                lat: entity.lat,
                lon: entity.lon,
                location: entity.name ?? "Unknown Location"
            )
        }
    }
        
    func addLocationToFavorites(forecast: Forecast) {
        coreDataManager.saveLocation(
            name: forecast.location,
            lat: forecast.lat,
            lon: forecast.lon,
            temperature: forecast.temperature,
            high: forecast.high,
            low: forecast.low,
            weatherCondition: forecast.weather.rawValue
        )
    }
        
    func removeLocationFromFavorites(lat: Double, lon: Double) {
        coreDataManager.deleteLocation(matching: lat, lon)
    }
        
    func checkIsFavorite(lat: Double, lon: Double) -> Bool {
        return coreDataManager.isFavorite(lat: lat, lon: lon)
    }
}
