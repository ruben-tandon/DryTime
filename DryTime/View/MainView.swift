//
//  ContentView.swift
//  DryTime
//
//  Created by Rubén Kumar Tandon Ramirez on 09/12/24.
//

import SwiftUI

struct MainView: View {
    
    @State var location: String = "Select Location"
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: LocationView(location: $location)) {
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
