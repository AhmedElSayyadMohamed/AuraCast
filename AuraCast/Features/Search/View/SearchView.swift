import SwiftUI
import Lottie

struct SearchView: View {
    
    @StateObject private var viewModel = SearchViewModel()
    @State private var navigateToFavorites = false

    var searchResults: [Forecast] {
        if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return []
        } else {
            return viewModel.searchResults.map { apiCity in
                Forecast(
                    id: UUID(),
                    date: Date(),
                    weather: .cloudy,
                    probability: 0,
                    temperature: 0,
                    high: Int(apiCity.lat),
                    low: Int(apiCity.lon),
                    lat: apiCity.lat,
                    lon: apiCity.lon,
                    location: "\(apiCity.name), \(apiCity.country)"
                )
            }
        }
    }

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Spacer()
                            .frame(height: 60)
                        
                        VStack(spacing: 16) {
                            LottieView(animationName: "search-image")
                                .frame(width: 200, height: 200)
                            
                            Text("Loading Weather...")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    } else if viewModel.isSearching {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.top, 20)
                    } else {
                        ForEach(searchResults) { forecast in
                            NavigationLink(
                                destination: WeatherDetailView(
                                    viewModel: WeatherDetailViewModel(),
                                    cityName: forecast.location,
                                    lat: forecast.lat,
                                    lon: forecast.lon
                                )
                            ) {
                                SearchCityWidget(forecast: forecast)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                EmptyView()
                    .frame(height: 110)
            }
            
            NavigationLink(
                destination: FavoritesListView(),
                isActive: $navigateToFavorites
            ) {
                EmptyView()
            }
        }
        .overlay {
            NavigationBar(searchText: $viewModel.searchText)
                .environment(\.onHeartTap, { navigateToFavorites = true })
        }
        .navigationBarHidden(true)
    
    }
}


struct SearchCityWidget: View {
    var forecast: Forecast

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(forecast.location)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("H:\(forecast.high)°  L:\(forecast.low)°")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.all, 16)
        .frame(maxWidth: .infinity)
        .background(Color.weatherWidgetBackground)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}
struct LottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .loop

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView(animation: .named(animationName))
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SearchView()
                .preferredColorScheme(.dark)
        }
    }
}

private struct OnHeartTapKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var onHeartTap: (() -> Void)? {
        get { self[OnHeartTapKey.self] }
        set { self[OnHeartTapKey.self] = newValue }
    }
}
