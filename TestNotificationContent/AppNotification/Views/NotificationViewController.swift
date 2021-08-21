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

    var coordinator: BaseCoordinator?
    func didReceive(_ notification: UNNotification) {
        
        let category = "apple_pay_push"
        let data = notification.request.content.userInfo
        NSLog("*** [NotificationViewController] data:\n\(String(data: try! JSONSerialization.data(withJSONObject: data, options: .prettyPrinted), encoding: .utf8 )!)");
        switch category {
        case "apple_pay_push":
            let applePayContent = ApplePayContent(title: "ApplePay", subTitle: "Some description", amounts: ["100", "200", "300"])
            coordinator = ApplePayCoordinator(applePayContent: applePayContent, viewController: self)
            coordinator?.start()
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
