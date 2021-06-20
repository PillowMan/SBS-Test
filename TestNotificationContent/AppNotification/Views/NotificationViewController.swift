//
//  NotificationViewController.swift
//  TestNotificationContent
//
//  Created by Dmitry Grigoryev on 19.06.2021.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    
    func didReceive(_ notification: UNNotification) {
        
        let category = "apple_pay_push"
        
        switch category {
        case "apple_pay_push":
            let applePayContent = ApplePayContent(title: "ApplePay", subTitle: "Some description", amounts: ["100", "200", "300"])
            let coordinator = ApplePayCoordinator(applePayContent: applePayContent, viewController: self)
            coordinator.store(coordinator: coordinator)
            coordinator.start()
            break;
        case "promise_pay_push":
            print("*** Promise pay")
            break;
        default:
            print("*** Default")
            break;
        }
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        completion(.dismiss)
    }

}
