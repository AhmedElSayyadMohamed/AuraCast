import SwiftUI

struct FavoritesListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var itemToDelete: IndexSet?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Weather")
                        }
                        .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Favorites")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.trailing, 40)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                
                if viewModel.favoriteCities.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No Favorite Cities Yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.favoriteCities) { forecast in
                            ZStack {
                                FavouriteWidget(forecast: forecast)
                                
                                NavigationLink(
                                    destination: WeatherDetailView(
                                        viewModel: WeatherDetailViewModel(repository: viewModel.repository),
                                        cityName: forecast.location,
                                        lat: forecast.lat,
                                        lon: forecast.lon
                                    )
                                ) {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    if let index = viewModel.favoriteCities.firstIndex(where: { $0.id == forecast.id }) {
                                        itemToDelete = IndexSet(integer: index)
                                        showDeleteConfirmation = true
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadFavorites()
        }
        .alert("Delete Favorite", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                itemToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let offsets = itemToDelete {
                    viewModel.removeCity(at: offsets)
                }
                itemToDelete = nil
            }
        } message: {
            Text("Are you sure you want to remove this city from your favorites?")
        }
    }
}
