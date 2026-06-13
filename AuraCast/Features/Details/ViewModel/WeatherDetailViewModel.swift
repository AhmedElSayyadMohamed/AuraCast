import Foundation
import Combine

@MainActor
class WeatherDetailViewModel: ObservableObject {
    @Published var selectedCityWeather: WeatherResponse?
    @Published var isLoadingDetail = false
    @Published var detailErrorMessage: String?
    @Published var isDetailCitySaved = false
    
    private let repository: WeatherRepositoryProtocol
    
    init(repository: WeatherRepositoryProtocol = WeatherRepository()) {
        self.repository = repository
    }
    
    var isMorning: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 5 && hour < 18
    }
    
    var detailTemperature: String {
        guard let t = selectedCityWeather?.current.temp_c else { return "--" }
        return "\(Int(t))°"
    }
    
    var detailConditionText: String {
        selectedCityWeather?.current.condition.text ?? "--"
    }
    
    var detailHighLowText: String {
        guard let d = selectedCityWeather?.forecast.forecastday.first?.day else { return "H:--   L:--" }
        return "H:\(Int(d.maxtemp_c))°   L:\(Int(d.mintemp_c))°"
    }
    
    var detailConditionIconURL: URL? {
        guard let icon = selectedCityWeather?.current.condition.icon else { return nil }
        return URL(string: "https:\(icon)")
    }
    
    var detailForecastDays: [ForecastDay] {
        selectedCityWeather?.forecast.forecastday ?? []
    }
    
    func fetchCityDetails(lat: Double, lon: Double) async {
        isLoadingDetail = true
        detailErrorMessage = nil
        do {
            let weather = try await repository.getWeatherForecast(lat: lat, lon: lon)
            self.selectedCityWeather = weather
            
            self.isDetailCitySaved = repository.checkIsFavorite(lat: lat, lon: lon)
        } catch {
            detailErrorMessage = error.localizedDescription
        }
        isLoadingDetail = false
    }
    
    func toggleSaveDetailCity() {
        guard let weather = selectedCityWeather else { return }
        let lat = weather.location.lat
        let lon = weather.location.lon
        
        if isDetailCitySaved {
            repository.removeLocationFromFavorites(lat: lat, lon: lon)
        } else {
            let dayForecast = weather.forecast.forecastday.first?.day
            let conditionString = weather.current.condition.text
            
            let forecastDomainModel = Forecast(
                id: UUID(),
                date: Date(),
                weather: Weather(rawValue: conditionString) ?? .cloudy,
                probability: 0,
                temperature: Int(weather.current.temp_c),
                high: Int(dayForecast?.maxtemp_c ?? 0),
                low: Int(dayForecast?.mintemp_c ?? 0),
                lat: lat,
                lon: lon,
                location: weather.location.name
            )
            
            repository.addLocationToFavorites(forecast: forecastDomainModel)
        }
        isDetailCitySaved.toggle()
    }
}
