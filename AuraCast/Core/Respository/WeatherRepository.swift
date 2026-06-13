//
//  WeatherRepository.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 12/06/2026.
//


protocol WeatherRepositoryProtocol {
    func getWeatherForecast(lat: Double, lon: Double, days: Int) async throws -> WeatherResponse
}
