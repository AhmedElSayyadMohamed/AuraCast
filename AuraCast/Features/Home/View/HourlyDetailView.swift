import SwiftUI


struct HourlyDetailView: View {
    
    let day: ForecastDay?
    
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss

    var hours: [HourWeather] { day?.hour ?? [] }

    var dayTitle: String {
        guard let d = day else { return "Hourly Forecast" }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: d.date) else { return d.date }
        let out = DateFormatter(); out.dateFormat = "EEEE, MMM d"
        return out.string(from: date)
    }

    var body: some View {
        ZStack {
            Image(viewModel.isMorning ? "Light-Background": "Background" )
                .resizable()
                .ignoresSafeArea()

            Color.black.opacity(0.2)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Back")
                                .font(.body)
                        }
                        .foregroundColor(.white)
                    }

                    Spacer()

                    Text(dayTitle)
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .opacity(0)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                Divider().background(.white.opacity(0.3))

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(Array(hours.enumerated()), id: \.offset) { index, hour in
                            HourRow(hour: hour)

                            if index < hours.count - 1 {
                                Divider()
                                    .background(.white.opacity(0.15))
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .navigationBarHidden(true)
    }
}


struct HourRow: View {
    let hour: HourWeather

    var isNow: Bool {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd HH:mm"
        guard let date = f.date(from: hour.time) else { return false }
        return Calendar.current.isDate(date, equalTo: .now, toGranularity: .hour)
    }

    var timeLabel: String {
        if isNow { return "Now" }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd HH:mm"
        guard let date = f.date(from: hour.time) else { return hour.time }
        let out = DateFormatter(); out.dateFormat = "h a"
        return out.string(from: date)
    }

    var iconURL: URL? { URL(string: "https:\(hour.condition.icon)") }

    var body: some View {
        HStack(spacing: 16) {
            Text(timeLabel)
                .font(.body.weight(isNow ? .bold : .regular))
                .foregroundColor(.white)
                .frame(width: 65, alignment: .leading)

            if let url = iconURL {
                AsyncImage(url: url) { img in
                    img.resizable().scaledToFit()
                } placeholder: {
                    Color.clear
                }
                .frame(width: 36, height: 36)
            }

            Text(hour.condition.text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(1)

            Spacer()

            Text("\(Int(hour.temp_c))°")
                .font(.title2.weight(isNow ? .bold : .regular))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(isNow ? .white.opacity(0.12) : .clear)
    }
}

// MARK: - Previews
struct HourlyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        HourlyDetailView(day: nil)
            .environmentObject(HomeViewModel())
    }
}
