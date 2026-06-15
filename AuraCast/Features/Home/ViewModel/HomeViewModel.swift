//
//  HomeViewModel.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 10/06/2026.
//
import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {

    @Published var currentWeather: WeatherResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var weatherRepository : WeatherRepositoryProtocol
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()

    init() {
        weatherRepository = WeatherRepository()
        setupLocationObserver()
    }
    var isMorning: Bool {
        let hour = Calendar.current.component(.hour, from: .now)
//        return hour >= 5 && hour < 18
        return false
    }
    
    var locationName: String { currentWeather?.location.name ?? "" }
    
    var temperature: String {
        guard let t = currentWeather?.current.temp_c else { return "" }
        return "\(Int(t))°"
    }
    
    var conditionText: String { currentWeather?.current.condition.text ?? "" }
    
    var conditionIconURL: URL? {
        guard let icon = currentWeather?.current.condition.icon else { return nil }
        return URL(string: "https:\(icon)")
    }
    
    var highTemp: String {
        guard let d = currentWeather?.forecast.forecastday.first?.day.maxtemp_c else { return "" }
        return "H:\(Int(d))°"
    }
    
    var lowTemp: String {
        guard let d = currentWeather?.forecast.forecastday.first?.day.mintemp_c else { return "" }
        return "L:\(Int(d))°"
    }

    var forecastDays: [ForecastDay] {
        currentWeather?.forecast.forecastday ?? []
    }

    private func setupLocationObserver() {
        locationManager.$location
            .compactMap { $0 }
            .sink { [weak self] location in
                guard let self = self else { return }
                Task {
                    await self.fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                }
            }
            .store(in: &cancellables)
    }

    func startLocationServices() {
        locationManager.requestLocationPermission()
    }

    private func fetchWeather(lat: Double, lon: Double) async {
        isLoading = true
        errorMessage = nil
        do {
            currentWeather = try await weatherRepository.getWeatherForecast(lat: lat, lon: lon)

        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
