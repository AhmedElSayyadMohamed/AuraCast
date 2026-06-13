import SwiftUI

struct FavouriteWidget: View {
    var forecast: Forecast

    private var favoriteIconName: String {
        switch forecast.weather {
        case .clear:
            return "Moon large"
        case .cloudy:
            return "Cloud large"
        case .rainy:
            return "Moon cloud mid rain large"
        case .stormy:
            return "Sun cloud angled rain large"
        case .sunny:
            return "Sun large"
        case .tornado:
            return "Tornado large"
        case .windy:
            return "Moon cloud fast wind large"
        }
    }

    private var defaultSystemIconName: String {
        switch forecast.weather {
        case .clear: return "moon.stars.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .stormy: return "cloud.bolt.rain.fill"
        case .sunny: return "sun.max.fill"
        case .tornado: return "tornado"
        case .windy: return "wind"
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Trapezoid()
                .fill(Color.weatherWidgetBackground)
                .frame(width: 342, height: 174)

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(forecast.temperature)°")
                        .font(.system(size: 64))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("H:\(forecast.high)°  L:\(forecast.low)°")
                            .font(.footnote)
                            .foregroundColor(.secondary)

                        Text(forecast.location)
                            .font(.body)
                            .lineLimit(1)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if UIImage(named: favoriteIconName) != nil {
                        Image(favoriteIconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(.trailing, 4)
                    } else {
                        Image(systemName: defaultSystemIconName)
                            .resizable()
                            .scaledToFit()
                            .symbolRenderingMode(.multicolor)
                            .frame(width: 76, height: 76)
                            .padding(.trailing, 16)
                            .padding(.bottom, 12)
                    }

                    Text(forecast.weather.rawValue)
                        .font(.footnote)
                        .padding(.trailing, 24)
                }
            }
            .foregroundColor(.white)
            .padding(.bottom, 20)
            .padding(.leading, 20)
        }
        .frame(width: 342, height: 184, alignment: .bottom)
    }
}
