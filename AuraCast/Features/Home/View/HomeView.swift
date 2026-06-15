//
//  HomeView.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 10/06/2026.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()

    @State private var bottomSheetPosition: BottomSheetPosition = .middle
    @State private var bottomSheetTranslation: CGFloat = BottomSheetPosition.middle.rawValue
    @State private var hasDragged: Bool = false
    
    @State private var navigateToFavorites = false

    var bottomSheetTranslationProrated: CGFloat {
        (bottomSheetTranslation - BottomSheetPosition.middle.rawValue) /
        (BottomSheetPosition.top.rawValue - BottomSheetPosition.middle.rawValue)
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let screenHeight = geometry.size.height
                    + geometry.safeAreaInsets.top
                    + geometry.safeAreaInsets.bottom
                let imageOffset = screenHeight + 30

                ZStack {
                    Color.background.ignoresSafeArea()

                    Image(viewModel.isMorning ? "Light-Background" : "Background")
                        .resizable()
                        .ignoresSafeArea()
                        .offset(y: -bottomSheetTranslationProrated * imageOffset)

                    Image("House")
                        .frame(maxHeight: .infinity, alignment: .top)
                        .padding(.top, 265)
                        .offset(y: -bottomSheetTranslationProrated * imageOffset)

                    VStack(spacing: 4) {
                        HStack {
                            Spacer()
                            
                            Button {
                                navigateToFavorites = true
                            } label: {
                                Image(systemName: "bookmark.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(viewModel.isMorning ? .black : .white)
                                    .padding(.trailing, 20)
                            }
                        }
                        
                        if hasDragged {
                            Text(viewModel.locationName)
                                .foregroundColor(.white)
                                .font(.largeTitle.weight(.medium)).padding(.top)
                            Text(currentFormattedDate)
                                .foregroundColor(.white)
                                .font(.subheadline.weight(.medium))
                        } else {
                            Text(viewModel.locationName)
                                .font(.largeTitle.weight(.medium))
                            Text(currentFormattedDate)
                                .font(.subheadline.weight(.medium))
                        }

                        HStack(alignment: .top, spacing: 35) {
                            if let url = viewModel.conditionIconURL {
                                AsyncImage(url: url) { img in
                                    img.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 120, height: 100)
                                .opacity(1 - bottomSheetTranslationProrated)
                            }
                            Text(attributedString)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                      
                        Text("\(viewModel.highTemp)   \(viewModel.lowTemp)")
                            .font(.title3.weight(.semibold))
                            .opacity(1 - bottomSheetTranslationProrated)

                        Spacer()
                    }
                    .padding(.top, 20)
                    .offset(y: -bottomSheetTranslationProrated * 46)
                    .foregroundColor(viewModel.isMorning ? .black.opacity(0.8) : .white)

                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: viewModel.isMorning ? .black.opacity(0.8) : .white))
                            .scaleEffect(1.5)
                    }

                    BottomSheet(
                        screenHeight: screenHeight,
                        position: $bottomSheetPosition,
                        translation: $bottomSheetTranslation,
                        hasDragged: $hasDragged
                    ) {
                        ForecastView(bottomSheetTranslationProrated: bottomSheetTranslationProrated)
                    }

                    TabBar(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            bottomSheetPosition = .top
                            bottomSheetTranslation = BottomSheetPosition.top.rawValue
                            hasDragged = true
                        }
                    })
                    .offset(y: bottomSheetTranslationProrated * 115)
                    
                    NavigationLink(
                        destination: FavoritesListView(),
                        isActive: $navigateToFavorites
                    ) {
                        EmptyView()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.startLocationServices()
            }
            .alert("Location Error",
                   isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                   )) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .environmentObject(viewModel)
    }

    private var currentFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    private var attributedString: AttributedString {
        let tempStr = viewModel.temperature
        let condStr = viewModel.conditionText
        
        let primaryColor: Color = viewModel.isMorning ? .black.opacity(0.8) : .white
//        let secondaryColor: Color = viewModel.isMorning ? .black.opacity(0.6) : .secondary
        
        var string = AttributedString(tempStr + (hasDragged ? " | " : "\n") + condStr)

        if let temp = string.range(of: tempStr) {
            string[temp].font = .system(
                size: 96 - (bottomSheetTranslationProrated * (96 - 20)),
                weight: hasDragged ? .semibold : .thin
            )
            if hasDragged {
                string[temp].foregroundColor = .white
            } else {
                string[temp].foregroundColor = primaryColor
            }
        }
        
        if let pipe = string.range(of: " | ") {
            string[pipe].font = .title3.weight(.semibold)
            if hasDragged {
                string[pipe].foregroundColor = .white
            } else {
                string[pipe].foregroundColor = .black
            }
           
        }
        
        if let weather = string.range(of: condStr) {
            string[weather].font = .title3.weight(.semibold)
            string[weather].foregroundColor = .white
        }
        return string
    }
}
