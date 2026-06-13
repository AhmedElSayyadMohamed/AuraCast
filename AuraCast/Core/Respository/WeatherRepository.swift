import Foundation

protocol WeatherRepositoryProtocol {
    func getWeatherForecast(lat: Double, lon: Double) async throws -> WeatherResponse
    
    func getFavoriteLocations() -> [Forecast]
    func addLocationToFavorites(forecast: Forecast)
    func removeLocationFromFavorites(lat: Double, lon: Double)
    func checkIsFavorite(lat: Double, lon: Double) -> Bool
}

class WeatherRepository: WeatherRepositoryProtocol {
    private let weatherService: WeatherService
    private let coreDataManager: CoreDataManager

    init(weatherService: WeatherService = WeatherService(),
         coreDataManager: CoreDataManager = .shared) {
        self.weatherService = weatherService
        self.coreDataManager = coreDataManager
    }
    
    func getWeatherForecast(lat: Double, lon: Double) async throws -> WeatherResponse {
        return try await weatherService.fetchWeather(lat: lat, lon: lon)
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
