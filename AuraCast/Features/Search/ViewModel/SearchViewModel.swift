//
//  SearchViewModel.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 10/06/2026.
//

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [CitySearchResult] = []
    @Published var isSearching = false
    @Published var selectedCityWeather: WeatherResponse?
    
    private let service = WeatherService()
    private var cancellables = Set<AnyCancellable>()
    
    var isShowingSearchResults: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isMorning: Bool {
        let hour = Calendar.current.component(.hour, from: .now)
        return hour >= 5 && hour < 18
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
        defer { isSearching = false }
        do {
            self.searchResults = try await service.searchCities(query: query)
        } catch {
            print("Search failed: \(error.localizedDescription)")
            self.searchResults = []
        }
    }
    
}
