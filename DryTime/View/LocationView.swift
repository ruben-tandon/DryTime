//
//  LocationView.swift
//  DryTime
//
//  Created by Rubén Kumar Tandon Ramirez on 10/12/24.
//

import SwiftUI
import MapKit

struct LocationView: View {
    @State var locationManager: LocationManager = .init()
    @State var navigationTag: String?

    var body: some View {
        VStack {
            headerView
            searchBarView
            contentView
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background {
            NavigationLink(tag: "MAPVIEW", selection: $navigationTag) {
                MapViewSelection()
                    .environmentObject(locationManager)
            } label: {
                EmptyView()
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Choose location")
                .font(.title3)
                .fontWeight(.semibold)
        }
    }

    private var searchBarView: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Find locations here", text: $locationManager.searchText)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(.gray)
        }
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var contentView: some View {
        if let places = locationManager.fetchedPlaces, !places.isEmpty {
            List {
                ForEach(places, id: \.self) { place in
                    locationButton(for: place)
                }
            }
            .listStyle(.plain)
        } else {
            liveLocationButton
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
    }

    private var liveLocationButton: some View {
        Button {
            if let coordinate = locationManager.userLocation?.coordinate {
                locationManager.mapView.region = .init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                locationManager.addDraggablePin(coordinate: coordinate)
                locationManager.updatePlacemark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                navigationTag = "MAPVIEW"
            }
        } label: {
            Label {
                Text("Use Current Location")
                    .font(.callout)
            } icon: {
                Image(systemName: "location.north.circle.fill")
            }
            .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MapViewSelection: View {
    @EnvironmentObject var locationManager: LocationManager
    var body: some View {
        ZStack {
            MapViewHelper()
                .environmentObject(locationManager)
                .ignoresSafeArea()
            
            if let place = locationManager.pickedPlaceMark {
                VStack(spacing: 15) {
                    Text("Confirm location")
                        .font(.title2.bold())
                    
                    HStack(spacing: 15) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(place.name ?? "")
                                .font(.title3.bold())
                            
                            Text(place.locality ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    
                    Button {
                        // Add confirm action here
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
    LocationView()
}
