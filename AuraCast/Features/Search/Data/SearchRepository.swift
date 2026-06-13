//
//  SearchRepository.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 12/06/2026.
//

import Foundation

protocol WeatherRepositoryProtocol {
    func getWeatherForecast(lat: Double, lon: Double, days: Int) async throws -> WeatherResponse
}
