//
//  SearchViewModel.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 12/06/2026.
//

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [CitySearchResult] = []
    @Published var savedForecasts: [WeatherResponse] = []
    @Published var isSearching = false
    
    @Published var selectedCityWeather: WeatherResponse?
    @Published var isLoadingDetail = false
    @Published var detailErrorMessage: String?
    @Published var isDetailCitySaved = false
    
    private let service = WeatherService()
    private var cancellables = Set<AnyCancellable>()
    
    var isShowingSearchResults: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isMorning: Bool {
        let hour = Calendar.current.component(.hour, from: .now)
        return hour >= 5 && hour < 18
    }
    
    var detailTemperature: String {
        guard let t = selectedCityWeather?.current.temp_c else { return "--" }
        return "\(Int(t))°"
    }
    
    var detailConditionText: String { selectedCityWeather?.current.condition.text ?? "--" }
    
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
    
    init() {
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .sink { [weak self] query in
                guard let self = self else { return }
                if query.isEmpty {
                    self.searchResults = []
                } else {
                    Task { await self.performSearch(query: query) }
                }
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) async {
        isSearching = true
        isSearching = false
    }
    
    func fetchCityDetails(lat: Double, lon: Double) async {
        isLoadingDetail = true
        detailErrorMessage = nil
        do {
            selectedCityWeather = try await service.fetchWeather(lat: lat, lon: lon)
            isDetailCitySaved = false
        } catch {
            detailErrorMessage = error.localizedDescription
        }
        isLoadingDetail = false
    }
    
    func toggleSaveDetailCity() {
        isDetailCitySaved.toggle()
    }
    
    func onSearchTextChanged(_ text: String) {}
    
    func onAppear() async {}
}
