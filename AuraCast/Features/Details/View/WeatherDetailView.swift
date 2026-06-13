//
//  CityDetailView.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 12/06/2026.
//

import SwiftUI

struct WeatherDetailView: View {
    @ObservedObject var viewModel: SearchViewModel
    let cityName: String
    let lat: Double
    let lon: Double
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            Image(viewModel.isMorning ? "Light-Background" : "Background")
                .resizable()
                .ignoresSafeArea()
            
            if viewModel.isLoadingDetail {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: viewModel.isMorning ? .black : .white))
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 6) {
                            Text(cityName)
                                .font(.system(size: 34, weight: .medium, design: .rounded))
                            
                            Text(viewModel.detailTemperature)
                                .font(.system(size: 80, weight: .thin, design: .rounded))
                            
                            Text(viewModel.detailConditionText)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(viewModel.isMorning ? .black.opacity(0.6) : .secondary)
                            
                            Text(viewModel.detailHighLowText)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(viewModel.isMorning ? .black : .white)
                        .padding(.top, 40)
                        
                        if let url = viewModel.detailConditionIconURL {
                            AsyncImage(url: url) { img in
                                img.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("3-DAY FORECAST")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .tracking(1.2)
                                .foregroundColor(viewModel.isMorning ? .black.opacity(0.6) : .white.opacity(0.6))
                                .padding(.horizontal, 8)
                            
                            ForEach(viewModel.detailForecastDays, id: \.date) { day in
                                DetailForecastRow(day: day, isMorning: viewModel.isMorning)
                            }
                        }
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .background(viewModel.isMorning ? Color.white.opacity(0.3) : Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(viewModel.isMorning ? Color.black.opacity(0.05) : Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(viewModel.isMorning ? .black : .white)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.toggleSaveDetailCity()
                } label: {
                    Image(systemName: viewModel.isDetailCitySaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(viewModel.isMorning ? .black : .white)
                }
            }
        }
        .task {
            await viewModel.fetchCityDetails(lat: lat, lon: lon)
        }
    }
}

struct DetailForecastRow: View {
    let day: ForecastDay
    let isMorning: Bool
    
    var body: some View {
        HStack {
            Text(day.date)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(isMorning ? .black : .white)
                .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("H:\(Int(day.day.maxtemp_c))°")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(isMorning ? .black : .white)
                
                Text("L:\(Int(day.day.mintemp_c))°")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(isMorning ? .black.opacity(0.6) : .white.opacity(0.6))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
    }
}
