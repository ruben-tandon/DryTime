//
//  ContentView.swift
//  DryTime
//
//  Created by Rubén Kumar Tandon Ramirez on 09/12/24.
//

import SwiftUI

struct MainView: View {
    
    @AppStorage("location") private var location: String = "Select Location"
    @State private var navigationPath = [Int]()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                NavigationLink(value: 1) {
                    Text("\(location)")
                        .font(.title)
                }
            }
            .padding()
            .navigationDestination(for: Int.self) {_ in
                LocationView(location: $location, navigationPath: $navigationPath)
            }
        }
    }
}

#Preview {
    MainView()
}
