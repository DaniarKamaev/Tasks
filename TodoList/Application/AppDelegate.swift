//
//  AppDelegate.swift
//  TodoList
//
//  Created by dany on 27.09.2025.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Принудительная инициализация CoreData при запуске
        print("🚀 Запуск приложения...")
        CoreDataService.shared.printCoreDataStatus()
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataService.shared.saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataService.shared.saveContext()
    }
}
