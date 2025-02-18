//
//  PeanutBillApp.swift
//  PeanutBill
//
//  Created by evan on 2025/2/18.
//

import SwiftUI
import CoreData

@main
struct PeanutBillApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
