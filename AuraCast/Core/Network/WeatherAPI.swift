//
//  WeatherService.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 11/06/2026.
//

import Foundation

class WeatherService {
    private let apiKey = "e556076f89ba4df2a9e220219261006"
    private let baseURL = "https://api.weatherapi.com/v1"
    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        
        let urlString = "\(baseURL)/forecast.json?key=\(apiKey)&q=\(lat),\(lon)&days=3&aqi=yes&alerts=no"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
    
    func fetchWeatherByCity(city: String) async throws -> WeatherResponse {
      
        let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        
        let urlString = "\(baseURL)/forecast.json?key=\(apiKey)&q=\(encoded)&days=3&aqi=yes&alerts=no"
        
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
    
    func searchCities(query: String) async throws -> [CitySearchResult] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/search.json?key=\(apiKey)&q=\(encoded)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([CitySearchResult].self, from: data)
    }
}
