//
//  ContentView.swift
//  DryTime
//
//  Created by Rubén Kumar Tandon Ramirez on 09/12/24.
//

import SwiftUI

struct MainView: View {
    
    var location: String = "Location"
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: LocationView()) {
                    Text("\(location)")
                        .font(.title)
                }
            }
            .padding()
        }
    }
}

#Preview {
    MainView()
}
