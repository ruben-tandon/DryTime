//
//  ContentView.swift
//  DryTime
//
//  Created by Rubén Kumar Tandon Ramirez on 09/12/24.
//

import SwiftUI

struct MainView: View {
    
    @AppStorage("location") private var location: String = "Select Location"
    @AppStorage("latitude") private var latitude: Double?
    @AppStorage("longitude") private var longitude: Double?
    @State private var navigationPath = [Int]()
    
    @StateObject private var weatherViewModel = WeatherManager()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                VStack {
                    NavigationLink(value: 1) {
                        VStack {
                            Text("\(location)")
                                .font(.title)
                                .padding()
                                .background(
                                    .thinMaterial, in: RoundedRectangle(cornerRadius: 20)
                                )
                        }
                        .padding(.top)
                    }
                    
                    if let latitude, let longitude {
//                        Text("\(latitude) / \(longitude)")
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: . leading) {
                                Label("10-day forecast".uppercased(), systemImage: "calendar")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding([.top, .leading])
                                    .onAppear {
                                        weatherViewModel.updateLocation(latitude: latitude, longitude: longitude)
                                    }
                                
                                VStack {
                                    ForEach (weatherViewModel.tenDayForecast, id: \.self) { weather in
                                        HStack {
                                            Text(weather.day)
                                                .frame(width: 48, alignment: .leading)
                                            
                                            Image (systemName: "\(weather.symbolName).fill")
                                                .font(.title2)
                                                .padding(.horizontal)
                                                .symbolRenderingMode(.multicolor)
                                            
                                            ZStack(alignment: .trailing) {
                                                Capsule()
                                                LinearGradient(gradient: Gradient(colors:[.blue, .yellow]), startPoint: .leading, endPoint: .trailing)
                                                    .clipShape (Capsule())
                                                    .frame (width: 72)
                                            }
                                            .frame (height: 6)
                                        }
                                        .padding()
                                    }
                                }
                            }
                            .background(
                                .thinMaterial, in: RoundedRectangle(cornerRadius: 20)
                            )
                        }
                    } else {
                        Text("No coordinates to display")
                    }
                }
                .padding()
                .navigationDestination(for: Int.self) {_ in
                    LocationView(location: $location, latitude: $latitude, longitude: $longitude, navigationPath: $navigationPath)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
