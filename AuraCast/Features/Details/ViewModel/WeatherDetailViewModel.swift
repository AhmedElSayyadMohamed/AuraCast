//
//  WeatherDetailViewModel.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 12/06/2026.
//

import Foundation
import Combine

@MainActor
class WeatherDetailViewModel: ObservableObject {
    @Published var cityName: String
    @Published var lat: Double
    @Published var lon: Double
    @Published var weatherDetails: WeatherResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: WeatherRepositoryProtocol
    
    init(name: String, lat: Double, lon: Double, repository: WeatherRepositoryProtocol = WeatherRepository()) {
        self.cityName = name
        self.lat = lat
        self.lon = lon
        self.repository = repository
    }
    
    func fetchWeatherDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await repository.getWeatherForecast(lat: lat, lon: lon, days: 3)
            self.weatherDetails = result
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
