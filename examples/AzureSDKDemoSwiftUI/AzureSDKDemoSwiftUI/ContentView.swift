//
//  ContentView.swift
//  AzureSDKDemoSwiftUI
//
//  Created by Joshua Lai on 2021-01-25.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingDetailView = false
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: Text("Second View"), isActive:  $isShowingDetailView) { EmptyView() }
                Button("Please log in") {
                    self.isShowingDetailView = true
                }
            }.navigationBarItems(
                leading:
                    Button("Log Out") {
                        print("-1")
                    }.font(.title3),
                trailing:
                    Button("Media") {
                        print("+1")
                    }.font(.title3)
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
