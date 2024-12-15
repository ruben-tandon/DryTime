//
//  ContentView.swift
//  DryTime
//
//  Created by Rubén Kumar Tandon Ramirez on 09/12/24.
//

import SwiftUI

struct MainView: View {
    
    @State var location: String = "Select Location"
    @State private var navigationPath = [Int]()
    private var locationText: some View {
        Text("\(location)")
            .font(.title)
    }
    @State private var indexView: Int = 1
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                NavigationLink(value: indexView) {
                    locationText
                }
            }
            .padding()
            .navigationDestination(for: Int.self) { index in
                LocationView(location: $location, navigationPath: $navigationPath, indexView: $indexView)
            }
        }
    }
}

#Preview {
    MainView()
}
