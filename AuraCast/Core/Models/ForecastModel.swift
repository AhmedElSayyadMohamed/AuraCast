
import Foundation

enum ForecastPeriod {
    case hourly
    case daily
}

enum Weather: String {
    case clear = "Clear"
    case cloudy = "Cloudy"
    case rainy = "Mid Rain"
    case stormy = "Showers"
    case sunny = "Sunny"
    case tornado = "Tornado"
    case windy = "Fast Wind"
}

struct Forecast: Identifiable,Hashable {
 
    var id = UUID()
    var date: Date
    var weather: Weather
    var probability: Int
    var temperature: Int
    var high: Int
    var low: Int
    var lat: Double = 0
    var lon: Double = 0
    var location: String
    
    var icon: String {
        switch weather {
        case .clear:
            return "Moon"
        case .cloudy:
            return "Cloud"
        case .rainy:
            return "Moon cloud mid rain"
        case .stormy:
            return "Sun cloud angled rain"
        case .sunny:
            return "Sun"
        case .tornado:
            return "Tornado"
        case .windy:
            return "Moon cloud fast wind"
        }
    }
}

extension Forecast {
    static let hour: TimeInterval = 60 * 60
    static let day: TimeInterval = 60 * 60 * 24
    
    static let hourly: [Forecast] = [
        Forecast(date: .init(timeIntervalSinceNow: hour * -1), weather: .rainy, probability: 30, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
        Forecast(date: .now, weather: .rainy, probability: 0, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
        Forecast(date: .init(timeIntervalSinceNow: hour * 1), weather: .windy, probability: 0, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
        Forecast(date: .init(timeIntervalSinceNow: hour * 2), weather: .rainy, probability: 0, temperature: 18, high: 24, low: 18, location: "Montreal, Canada"),
        Forecast(date: .init(timeIntervalSinceNow: hour * 3), weather: .rainy, probability: 0, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
        Forecast(date: .init(timeIntervalSinceNow: hour * 4), weather: .rainy, probability: 0, temperature: 19, high: 24, low: 18, location: "Montreal, Canada")
    ]
    
    static let daily: [Forecast] = [
        Forecast(date: .init(timeIntervalSinceNow: 0), weather: .rainy, probability: 30, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
        Forecast(date: .init(timeIntervalSinceNow: day * 1), weather: .rainy, probability: 0, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
        Forecast(date: .init(timeIntervalSinceNow: day * 2), weather: .stormy, probability: 100, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
        Forecast(date: .init(timeIntervalSinceNow: day * 3), weather: .stormy, probability: 50, temperature: 18, high: 24, low: 18, location: "Montreal, Canada"),
        Forecast(date: .init(timeIntervalSinceNow: day * 4), weather: .rainy, probability: 0, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
        Forecast(date: .init(timeIntervalSinceNow: day * 5), weather: .rainy, probability: 0, temperature: 19, high: 24, low: 18, location: "Montreal, Canada")
    ]
    
    static let cities: [Forecast] = [
        Forecast(date: .now, weather: .rainy, probability: 0, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
        Forecast(date: .now, weather: .windy, probability: 0, temperature: 20, high: 21, low: 19, location: "Toronto, Canada"),
        Forecast(date: .now, weather: .stormy, probability: 0, temperature: 13, high: 16, low: 8, location: "Tokyo, Japan"),
        Forecast(date: .now, weather: .tornado, probability: 0, temperature: 23, high: 26, low: 16, location: "Tennessee, United States")
    ]
}
//extension Forecast {
//    init(name: String, lat: Double, lon: Double, weather: WeatherResponse) {
//        let current = weather.current
//        let today = weather.forecast.forecastday.first?.day
//
//        self.date = .now
//        self.location = name
//        self.lat = lat
//        self.lon = lon
//        self.temperature = Int(current.tempC.rounded())
//        self.high = Int(today?.maxtempC.rounded() ?? current.tempC.rounded())
//        self.low = Int(today?.mintempC.rounded() ?? current.tempC.rounded())
//        self.probability = today?.dailyChanceOfRain ?? 0
//        self.weather = Forecast.weatherType(
//            code: current.condition.code,
//            isDay: current.isDay == 1,
//            windKph: current.windKph
//        )
//    }

func weatherType(code: Int, isDay: Bool, windKph: Double) -> Weather {
        switch code {
        case 1000:
            return isDay ? .sunny : .clear

        case 1003, 1006, 1009:
            return .cloudy

        case 1030, 1135, 1147:
            return .cloudy
            
        case 1063, 1150, 1153, 1168, 1171,
             1180, 1183, 1186, 1189, 1192, 1195,
             1198, 1201, 1240, 1243, 1246:
            return .rainy

        case 1066, 1069, 1072, 1114, 1117,
             1204, 1207, 1210, 1213, 1216, 1219,
             1222, 1225, 1237, 1249, 1252, 1255,
             1258, 1261, 1264:
            return .rainy
            
        case 1087, 1273, 1276, 1279, 1282:
            return .stormy

        default:
            return windKph > 30 ? .windy : .cloudy
        }
    }
//}
