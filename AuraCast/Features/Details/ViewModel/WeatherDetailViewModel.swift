import Foundation
import Combine

@MainActor
class WeatherDetailViewModel: ObservableObject {
    @Published var selectedCityWeather: WeatherResponse?
    @Published var isLoadingDetail = false
    @Published var detailErrorMessage: String?
    @Published var isDetailCitySaved = false
    @Published var cityName: String = ""
    
    let repository: WeatherRepositoryProtocol
    
    init(repository: WeatherRepositoryProtocol = WeatherRepository(), initialWeather: WeatherResponse? = nil,initialCityName: String = "") {
        self.repository = repository
        self.selectedCityWeather = initialWeather
        self.cityName = initialCityName
        
    }
    
    func fetchCityDetails(lat: Double, lon: Double) async {
        isLoadingDetail = true
        detailErrorMessage = nil
        do {
            let weather = try await repository.getWeatherForecast(lat: lat, lon: lon)
            self.selectedCityWeather = weather
        } catch {
            detailErrorMessage = error.localizedDescription
        }
        isLoadingDetail = false
    }
    
    var isMorning: Bool {
        let hour = Calendar.current.component(.hour, from: .now)
//        return hour >= 5 && hour < 18
        return false
    }
    
    var detailTemperature: String {
        guard let t = selectedCityWeather?.current.temp_c else { return "--" }
        return "\(Int(t))°"
    }
    
    var detailConditionText: String { selectedCityWeather?.current.condition.text ?? "--" }
    
    var detailHighLowText: String {
        guard let d = selectedCityWeather?.forecast.forecastday.first?.day else { return "H:--  L:--" }
        return "H:\(Int(d.maxtemp_c))°  L:\(Int(d.mintemp_c))°"
    }
    
    var detailConditionIconURL: URL? {
        guard let icon = selectedCityWeather?.current.condition.icon else { return nil }
        return URL(string: "https:\(icon)")
    }
    
    var detailForecastDays: [ForecastDay] { selectedCityWeather?.forecast.forecastday ?? [] }
    
    func load(cityName: String, lat: Double, lon: Double) async {
        self.cityName = cityName
        self.isDetailCitySaved = repository.checkIsFavorite(lat: lat, lon: lon)
        
        if selectedCityWeather == nil {
            await fetchCityDetails(lat: lat, lon: lon)
        }
    }
    
    func toggleSaveDetailCity() {
        guard let weather = selectedCityWeather else { return }
        let lat = weather.location.lat
        let lon = weather.location.lon
        
        if isDetailCitySaved {
            repository.removeLocationFromFavorites(lat: lat, lon: lon)
        } else {
            let dayForecast = weather.forecast.forecastday.first?.day
            let forecastDomainModel = Forecast(
                id: UUID(),
                date: Date(),
                weather: Weather(rawValue: weather.current.condition.text) ?? .cloudy,
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
