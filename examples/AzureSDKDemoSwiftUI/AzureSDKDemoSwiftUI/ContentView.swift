//
//  ContentView.swift
//  AzureSDKDemoSwiftUI
//
//  Created by Joshua Lai on 2021-01-25.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var isShowingMedia = false
    
    @State private var userLabel: String = "Please log in"
    
    var body: some View {
        NavigationView {
            VStack {
                Image("logo")
                    .scaledToFit()
                Text(userLabel)
            }.navigationBarItems(
                leading:
                    Button("Log Out") {
                        
                    }.font(.title3)
                    .disabled(!isLoggedIn),
                trailing:
                    NavigationLink(
                        destination: MediaViewController(),
                        isActive: $isShowingMedia,
                        label: {
                            Button("Media") {
                                isShowingMedia.toggle()
                            }.font(.title3)
                        })
            )
        }
    }
}

struct MediaViewController: View {
    @State var selectedTabItem: Int = 0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        TabView(selection: $selectedTabItem,
                content:  {
                    Text("Tab Content 1")
                        .tabItem {
                            Image(systemName: "square.and.arrow.down")
                            Text("Download")
                        }
                        .tag(0)
                    Text("Tab Content 2")
                        .tabItem {
                            Image(systemName: "square.and.arrow.up")
                            Text("Upload")
                        }
                        .tag(1)
                })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
