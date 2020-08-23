//
//  AppDelegate.swift
//  The Coffee Garden
//
//  Created by Quốc Lê  on 8/23/20.
//  Copyright © 2020 Quốc Lê . All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        locationManager.delegate = self
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert,.sound]){(granted,error) in}
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if(region is CLBeaconRegion){
            
            let url = URL(string: "https://thawing-falls-33830.herokuapp.com/ads")!
            URLSession.shared.dataTask(with: url) {(data, response, error) in
                do{
                    if let apiData = data{
                        let decodedData = try JSONDecoder().decode([Response].self, from: apiData)
                        DispatchQueue.main.async {
                            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                                
                                guard settings.authorizationStatus == .authorized else { return }
                                let content = UNMutableNotificationContent()
                                
                                content.categoryIdentifier = "The Coffee Garden"
                                
                                content.title = decodedData[decodedData.count - 1].title
                                content.subtitle = decodedData[decodedData.count - 1].content
                                content.body = "One-time overdraft fee is $25. Should we cover transaction?"
                                content.sound = UNNotificationSound.default
                                
                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
                                let uuidString = UUID().uuidString
                                let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                                
                                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                                
                            }
                            
                        }
                    }
                    else{
                        print("No data")
                    }
                    
                }
                catch{
                    print("Error")
                }
                
            }.resume()
            
        }
    }
    
}

struct Response: Codable {
    public var title: String
    public var content: String
    //public var body: String
    //public var CreatedAt: String
}

