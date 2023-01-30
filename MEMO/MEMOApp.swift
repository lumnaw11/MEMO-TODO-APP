//
//  MEMOApp.swift
//  MEMO APP
//
//  Created by Lum Naw on 2022/12/22.
//

import SwiftUI

@main
struct MEMOApp: App {
    

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
             
                
        }
       
    }
}
