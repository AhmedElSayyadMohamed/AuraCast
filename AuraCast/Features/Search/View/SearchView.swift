//
//  WeatherView.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 11/06/2026.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if viewModel.isShowingSearchResults {
                            ForEach(viewModel.searchResults) { city in
                                NavigationLink(value: city) {
                                    SearchResultRow(city: city)
                                }
                                .buttonStyle(.plain)
                            }

                            if viewModel.isSearching {
                                ProgressView()
                                    .padding(.top, 24)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        } else {
                            if !viewModel.savedForecasts.isEmpty {
                                ForEach(viewModel.savedForecasts, id: \.location.name) { forecast in
                                    NavigationLink(value: forecast.toSearchResult()) {
                                        WeatherWidget(forecast: forecast)
                                    }
                                    .buttonStyle(.plain)
                                }
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.3))
                                    Text("No Favorite Locations Yet")
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding(.top, 60)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 120)
                }
            }
            .overlay(alignment: .top) {
                NavigationBar(searchText: $viewModel.searchText)
                    .background(
                        Color.background
                            .opacity(0.8)
                            .background(.ultraThinMaterial)
                            .ignoresSafeArea(edges: .top)
                    )
            }
            .onChange(of: viewModel.searchText) { _, newValue in
                viewModel.onSearchTextChanged(newValue)
            }
            .navigationDestination(for: CitySearchResult.self) { city in
                WeatherDetailView(
                    viewModel: WeatherDetailViewModel(name: city.name, lat: city.lat, lon: city.lon)
                )
            }
            .navigationBarHidden(true)
            .task {
                await viewModel.onAppear()
            }
        }
    }
}

struct SearchResultRow: View {
    let city: CitySearchResult
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(city.name)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                if let country = city.country {
                    Text(country)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .preferredColorScheme(.dark)
    }
}
