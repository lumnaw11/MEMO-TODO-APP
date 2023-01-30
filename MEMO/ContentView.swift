//
//  ContentView.swift
//  MEMO APP
//
//  Created by Lum Naw on 2022/12/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
  
    @AppStorage ("isDarkMode") private var isDark = false
    
    var body: some View {
        TabView {
            MemoView()
                .tabItem {
                        Label("MEMO", systemImage: "pencil.circle")
                        }

            TodoView()
                .tabItem{
                    Label("TODO", systemImage: "note.text")
                            
                }
        }
        .accentColor(Color("AccentColor"))
        .environment(\.colorScheme, isDark ? .dark : .light)
    }
       
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
