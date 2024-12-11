//
//  LocationManager.swift
//  DryTime
//
//  Created by Rubén Kumar Tandon Ramirez on 10/12/24.
//

import SwiftUI
import CoreLocation
import MapKit
//Combine framework is imported to watch Textfield change
import Combine

class LocationManager: NSObject, ObservableObject, MKMapViewDelegate, CLLocationManagerDelegate {
    //Properties
    @Published var mapView: MKMapView = .init()
    @Published var manager: CLLocationManager = .init()
    
    //Search bar text
    @Published var searchText: String = ""
    var cancellable : AnyCancellable?
    @Published var fetchedPlaces: [CLPlacemark]?
    
    //User location
    @Published var userLocation: CLLocation?
    
    //Final location
    @Published var pickedLocation: CLLocation?
    @Published var pickedPlaceMark: CLPlacemark?
    
    override init() {
        super.init()
        //Setting delegates
        manager.delegate = self
        mapView.delegate = self
        
        //Requesting location access
        manager.requestWhenInUseAuthorization()
        
        //Search textfield watching
        cancellable = $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self = self else { return }
                if value != "" {
                    self.fetchPlaces(value: value)
                } else {
                    DispatchQueue.main.async {
                        self.fetchedPlaces = nil
                    }
                }
            }
    }
    
    func fetchPlaces(value: String) {
        Task {
            do {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = value.lowercased()
                let response = try await MKLocalSearch(request: request).start()
                await MainActor.run {
                    self.fetchedPlaces = response.mapItems.compactMap { $0.placemark }
                }
            } catch {
                await MainActor.run {
                    self.fetchedPlaces = nil
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //Handle errors
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        self.userLocation = currentLocation
    }
    
    //Location authorization
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways: manager.requestLocation()
        case .authorizedWhenInUse: manager.requestLocation()
        case .denied: handleLocationError()
        case .notDetermined: manager.requestWhenInUseAuthorization()
        default: ()
        }
    }
    
    func handleLocationError() {
        //Handle error
    }
    
    //Add draggable pin to mapview
    func addDraggablePin(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Drying clothes location"
        
        mapView.addAnnotation(annotation)
    }
    
    //Enable dragging
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        marker.isDraggable = true
        marker.canShowCallout = false
        
        return marker
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        guard let newLocation = view.annotation?.coordinate else { return }
        self.pickedLocation = .init(latitude: newLocation.latitude, longitude: newLocation.longitude)
        updatePlacemark(location: .init(latitude: newLocation.latitude, longitude: newLocation.longitude))
    }
    
    func updatePlacemark(location: CLLocation) {
        Task {
            do {
                guard let place = try await reverseLocationCoordinates(location: location) else { return }
                await MainActor.run(body: {
                    self.pickedPlaceMark = place
                })
            } catch {
                //Handle error
            }
        }
    }
    
    //Displaying new location data
    func reverseLocationCoordinates(location: CLLocation)async throws -> CLPlacemark? {
        let place = try await CLGeocoder().reverseGeocodeLocation(location).first
        return place
    }
}
