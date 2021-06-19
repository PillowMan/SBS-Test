//
//  AppDelegate.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 14.06.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13, *) {
        }else {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = ViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        }
        
        registerForPushNotifications()
                UNUserNotificationCenter.current().delegate = self

        return true
    }
    
    func registerForPushNotifications() {
          UNUserNotificationCenter.current()
            .requestAuthorization(
              options: [.alert, .sound, .badge]) { [weak self] granted, _ in
              print("Permission granted: \(granted)")
              guard granted else { return }
              self?.getNotificationSettings()
            }
          
      }
      
      func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          print("Notification settings: \(settings)")
          guard settings.authorizationStatus == .authorized else { return }
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
        }
      }
      //MARK: push when app in foreground
      func userNotificationCenter(
          _ center: UNUserNotificationCenter,
          willPresent notification: UNNotification,
          withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
          
          completionHandler([.alert, .sound])
      }


}

