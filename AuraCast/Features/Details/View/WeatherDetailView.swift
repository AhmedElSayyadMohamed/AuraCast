import SwiftUI

struct WeatherDetailView: View {
    @ObservedObject var viewModel: WeatherDetailViewModel
    
    let cityName: String
    let lat: Double
    let lon: Double
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDay: ForecastDay?
    @State private var navigateToHourly = false
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            Image(viewModel.isMorning ? "Light-Background": "Background" )
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
                            
                            HStack(spacing: 50) {
                                if let url = viewModel.detailConditionIconURL {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable().scaledToFit()
                                        case .failure(_), .empty:
                                            ProgressView()
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(width: 100, height: 100)
                                }
                                Text(viewModel.detailTemperature)
                                    .font(.system(size: 80, weight: .thin, design: .rounded))
                                
                                Spacer()
                            }
                            
                            Text(viewModel.detailConditionText)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(viewModel.isMorning ? .black.opacity(0.6) : .secondary)
                            
                            Text(viewModel.detailHighLowText)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(viewModel.isMorning ? .black : .white)
                        .padding(.top, 40)
                        
                        HStack {
                            Text("3-DAY FORECAST")
                                .font(.caption.weight(.semibold))
                            Spacer()
                        }
                        .foregroundColor(viewModel.isMorning ? .black.opacity(0.6) : .white.opacity(0.6))
                        .padding(.horizontal, 20)
                        .padding(.top, 4)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(viewModel.detailForecastDays.enumerated()), id: \.element.date) { index, day in
                                    NavigationLink(
                                        destination: HourlyDetailView(day: day)
                                    ) {
                                        DayForecastCard(day: day, index: index, isMorning: viewModel.isMorning)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        
                        VStack(spacing: 12) {
                            Text("CURRENT CONDITIONS")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(viewModel.isMorning ? .black.opacity(0.6) : .white.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            LazyVGrid(
                                columns: [GridItem(.flexible()), GridItem(.flexible())],
                                spacing: 12
                            ) {
                                StatTile(icon: "eye.fill", title: "VISIBILITY", value: viewModel.selectedCityWeather?.current.vis_km != nil ? "\(Int(viewModel.selectedCityWeather!.current.vis_km)) km" : "--", isMorning: viewModel.isMorning)
                                StatTile(icon: "humidity.fill", title: "HUMIDITY", value: viewModel.selectedCityWeather?.current.humidity != nil ? "\(viewModel.selectedCityWeather!.current.humidity)%" : "--", isMorning: viewModel.isMorning)
                                StatTile(icon: "thermometer.medium", title: "FEELS LIKE", value: viewModel.selectedCityWeather?.current.feelslike_c != nil ? "\(Int(viewModel.selectedCityWeather!.current.feelslike_c))°" : "--", isMorning: viewModel.isMorning)
                                StatTile(icon: "gauge.medium", title: "PRESSURE", value: viewModel.selectedCityWeather?.current.pressure_mb != nil ? "\(Int(viewModel.selectedCityWeather!.current.pressure_mb)) hPa" : "--", isMorning: viewModel.isMorning)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
                .transition(.opacity)
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
        .onAppear {
            Task {
                await viewModel.fetchCityDetails(lat: lat, lon: lon)
            }
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
