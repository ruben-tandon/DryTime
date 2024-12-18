//
//  LocationView.swift
//  DryTime
//
//  Created by Rubén Kumar Tandon Ramirez on 10/12/24.
//

import SwiftUI
import MapKit

struct LocationView: View {
    @ObservedObject var locationManager: LocationManager = .init()
    @State var navigationTag: String?
    @Binding var location: String
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    @Binding var navigationPath: [Int]

    var body: some View {
        VStack {
            headerView
            searchBarView
            contentView
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background {
            ZStack {
                NavigationLink(tag: "MAPVIEW", selection: $navigationTag) {
                    MapViewSelection(location: $location, latitude: $latitude, longitude: $longitude, navigationPath: $navigationPath)
                        .environmentObject(locationManager)
                } label: {
                    EmptyView()
                        .accessibilityHidden(true)
                }
            }
            .accessibilityHidden(true)
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Choose location")
                .font(.title3)
                .fontWeight(.semibold)
                .accessibilityHidden(true)
        }
    }

    private var searchBarView: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .accessibilityHidden(true)
            
            TextField("Search locations here", text: $locationManager.searchText)
                .accessibilityHint("This is a text field where you can type to find locations")
                .submitLabel(.search)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(.gray)
        }
        .padding(.vertical, 10)
    }

    private var contentView: some View {
        Group {
            if let places = locationManager.fetchedPlaces, !places.isEmpty {
                List(places, id: \.self) { place in
                    locationButton(for: place)
                }
                .listStyle(.plain)
            } else {
                liveLocationButton
            }
        }
    }

    private func locationButton(for place: CLPlacemark) -> some View {
        Button {
            if let coordinate = place.location?.coordinate {
                locationManager.pickedLocation = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
                locationManager.mapView.region = .init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                locationManager.addDraggablePin(coordinate: coordinate)
                locationManager.updatePlacemark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
            }
            navigationTag = "MAPVIEW"
        } label: {
            HStack(spacing: 15) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.gray)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(place.name ?? "")
                        .font(.body)
                    
                    Text(place.locality ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .accessibilityHint("Double-tap to select this location.")
    }

    private var liveLocationButton: some View {
        Button(action: handleLiveLocationButtonTapped) {
            Label("Use Current Location", systemImage: "location.north.circle.fill")
                .foregroundColor(.green)
                .font(.callout)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityLabel("Use current location")
        .accessibilityHint("Double-tap to set your location to the current position.")
    }

    private func handleLiveLocationButtonTapped() {
        guard let coordinate = locationManager.userLocation?.coordinate else { return }
        
        locationManager.mapView.region = .init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        locationManager.addDraggablePin(coordinate: coordinate)
        locationManager.updatePlacemark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
        navigationTag = "MAPVIEW"
    }
}

struct MapViewSelection: View {
    @EnvironmentObject var locationManager: LocationManager
    @Binding var location: String
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    @Binding var navigationPath: [Int]
    var body: some View {
        ZStack {
            MapViewHelper()
                .environmentObject(locationManager)
                .ignoresSafeArea()
                .accessibilityHidden(true)
            
            if let place = locationManager.pickedPlaceMark {
                VStack(spacing: 15) {
                    Text("Confirm location")
                        .font(.title2.bold())
                        .accessibilityHidden(true)
                    
                    HStack(spacing: 15) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                            .accessibilityHidden(true)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(place.name ?? "")
                                .font(.title3.bold())
                            
                            Text(place.locality ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .accessibilityHidden(true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    
                    Button {
                        location = place.name ?? "Select Location"
                        latitude = place.location?.coordinate.latitude
                        longitude = place.location?.coordinate.longitude
                        navigationPath.removeAll()
                    } label: {
                        Text("Confirm location")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.green)
                            }
                            .overlay(alignment: .trailing) {
                                Image(systemName: "arrow.right")
                                    .font(.title3.bold())
                                    .padding(.trailing)
                            }
                            .foregroundColor(.white)
                    }
                    .accessibilityLabel("Confirm the selected location \((place.name!))")
                    .accessibilityHint("Double-tap to confirm and set the location.")
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white)
                        .ignoresSafeArea()
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .onDisappear {
            locationManager.pickedLocation = nil
            locationManager.pickedPlaceMark = nil
            locationManager.mapView.removeAnnotations(locationManager.mapView.annotations)
        }
    }
}

//UIKit MapView
struct MapViewHelper: UIViewRepresentable {
    @EnvironmentObject var locationManager: LocationManager
    func makeUIView(context: Context) -> MKMapView {
        return locationManager.mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}

#Preview {
    LocationView(location: .constant("Location"), latitude: .constant(0.0), longitude: .constant(0.0), navigationPath: .constant([1])
    ).environmentObject(LocationManager())
}
