import SwiftUI

struct ForecastView: View {
    
    var bottomSheetTranslationProrated: CGFloat = 0
    
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var selectedDay: ForecastDay? = nil
    @State private var navigateToHourly = false

    var isExpanded: Bool { bottomSheetTranslationProrated > 0.5 }

    private var sheetBackgroundStyle: AnyShapeStyle {
//        if viewModel.isMorning {
//            return AnyShapeStyle(Color.bottomSheetBackground)
//        } else {
//            return AnyShapeStyle(Color.bottomSheetBackground)
//        }
        return AnyShapeStyle(Color.bottomSheetBackground)

    }

    private var sheetStrokeStyle: AnyShapeStyle {
        if viewModel.isMorning {
            return AnyShapeStyle(Color.black.opacity(0.05))
        } else {
            return AnyShapeStyle(Color.bottomSheetBorderTop)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                RoundedRectangle(cornerRadius: 10)
                    .fill(viewModel.isMorning ? Color.black.opacity(0.2) : Color.black.opacity(0.3))
                    .frame(width: 48, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                if isExpanded {
                    StatsGridView(isMorning: viewModel.isMorning)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                } else {

                    HStack {
                        Text("3-DAY FORECAST")
                            .font(.caption.weight(.semibold))
                        Spacer()
                        Text("Tap a day for hourly")
                            .font(.caption2)
                            .opacity(0.6)
                    }
                    .foregroundColor(viewModel.isMorning ? .black.opacity(0.6) : .white.opacity(0.6))
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                    // Day cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(viewModel.forecastDays.enumerated()), id: \.offset) { index, day in
                                DayForecastCard(day: day, index: index, isMorning: viewModel.isMorning)
                                    .onTapGesture {
                                        selectedDay = day
                                        navigateToHourly = true
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: isExpanded)
        .backgroundBlur(radius: 25, opaque: true)
        .background(sheetBackgroundStyle)
        .clipShape(RoundedRectangle(cornerRadius: 44))
        .innerShadow(
            shape: RoundedRectangle(cornerRadius: 44),
            color: Color.white.opacity(0.5) ,
            lineWidth: 1, offsetX: 0, offsetY: 1,
            blur: 0, blendMode: .overlay,
            opacity: 1 - bottomSheetTranslationProrated
        )
        .overlay {
            RoundedRectangle(cornerRadius: 44)
                .stroke(sheetStrokeStyle, lineWidth: 1)
                .blendMode(.overlay)
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .background(
            NavigationLink(
                destination: HourlyDetailView(day: selectedDay),
                isActive: $navigateToHourly
            ) { EmptyView() }
            .opacity(0)
        )
    }
}

struct DayForecastCard: View {
    let day: ForecastDay
    let index: Int
    let isMorning: Bool

    var isToday: Bool { index == 0 }

    var dayLabel: String {
        switch index {
        case 0: return "Today"
        case 1: return "Tomorrow"
        default:
            let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
            guard let date = f.date(from: day.date) else { return day.date }
            let out = DateFormatter(); out.dateFormat = "EEE"
            return out.string(from: date)
        }
    }

    var iconURL: URL? { URL(string: "https:\(day.day.condition.icon)") }

    private var cardFillStyle: AnyShapeStyle {
        if isMorning {
            return AnyShapeStyle(Color.black.opacity(0.08))
        } else {
            return AnyShapeStyle(Color.forecastCardBackground.opacity(isToday ? 1 : 0.2))
        }
    }

    private var cardStrokeStyle: AnyShapeStyle {
        if isMorning {
            return AnyShapeStyle(Color.black.opacity(0.1))
        } else {
            return AnyShapeStyle(Color.white.opacity(isToday ? 0.5 : 0.2))
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(cardFillStyle)
                .frame(width: 80, height: 160)
                .shadow(color: .black.opacity(isMorning ? 0.05 : 0.25), radius: 10, x: 5, y: 4)
                .overlay {
                    RoundedRectangle(cornerRadius: 30)
                        .strokeBorder(cardStrokeStyle)
                        .blendMode(.overlay)
                }
                .innerShadow(
                    shape: RoundedRectangle(cornerRadius: 30),
                    color: isMorning ? .black.opacity(0.05) : .white.opacity(0.25),
                    lineWidth: 1, offsetX: 1, offsetY: 1,
                    blur: 0, blendMode: .overlay
                )

            VStack(spacing: 10) {
                Text(dayLabel)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(isMorning ? .black : .white)

                if let url = iconURL {
                    AsyncImage(url: url) { img in
                        img.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                            .scaleEffect(0.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: isMorning ? .black : .white))
                    }
                    .frame(width: 36, height: 36)
                }

                Text("\(Int(day.day.maxtemp_c))°")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(isMorning ? .black : .white)

                Rectangle()
                    .fill(isMorning ? Color.black.opacity(0.1) : .white.opacity(0.2))
                    .frame(width: 40, height: 1)

                Text("\(Int(day.day.mintemp_c))°")
                    .font(.subheadline)
                    .foregroundColor(isMorning ? .black : .white)
            }
            .padding(.vertical, 16)
            .frame(width: 80, height: 160)
        }
        .overlay(alignment: .bottom) {
            Image(systemName: "chevron.up")
                .font(.system(size: 9))
                .foregroundColor(isMorning ? .black.opacity(0.3) : .white.opacity(0.4))
                .padding(.bottom, 5)
        }
    }
}

// MARK: - Stats Grid View
struct StatsGridView: View {
    let isMorning: Bool
    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text("CURRENT CONDITIONS")
                .font(.caption.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                StatTile(icon: "eye.fill", title: "VISIBILITY", value: viewModel.currentWeather?.current.vis_km != nil ? "\(Int(viewModel.currentWeather!.current.vis_km)) km" : "--", isMorning: isMorning)
                StatTile(icon: "humidity.fill", title: "HUMIDITY", value: viewModel.currentWeather?.current.humidity != nil ? "\(viewModel.currentWeather!.current.humidity)%" : "--", isMorning: isMorning)
                StatTile(icon: "thermometer.medium", title: "FEELS LIKE", value: viewModel.currentWeather?.current.feelslike_c != nil ? "\(Int(viewModel.currentWeather!.current.feelslike_c))°" : "--", isMorning: isMorning)
                StatTile(icon: "gauge.medium", title: "PRESSURE", value: viewModel.currentWeather?.current.pressure_mb != nil ? "\(Int(viewModel.currentWeather!.current.pressure_mb)) hPa" : "--", isMorning: isMorning)
            }
        }
    }
}

struct StatTile: View {
    let icon: String
    let title: String
    let value: String
    let isMorning: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(.white)

            Text(value)
                .font(.title2.bold())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            Color.white.opacity(0.06),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}
