import Foundation
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var favoriteCities: [Forecast] = []
    
    let repository: WeatherRepositoryProtocol
    
    init(repository: WeatherRepositoryProtocol = WeatherRepository()) {
        self.repository = repository
        loadFavorites()
    }
    
    func loadFavorites() {
        self.favoriteCities = repository.getFavoriteLocations()
    }
    
    func removeCity(at offsets: IndexSet) {
        for index in offsets {
            let city = favoriteCities[index]
            repository.removeLocationFromFavorites(lat: city.lat, lon: city.lon)
        }
        
        loadFavorites()
    }
    
}
