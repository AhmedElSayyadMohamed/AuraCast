import Foundation

class NetworkHelper {

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
    
    func searchCities(query: String) async throws -> [CitySearchResult] {
        
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/search.json?key=\(apiKey)&q=\(encoded)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([CitySearchResult].self, from: data)
    }
    
    private var apiKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
    }
}
