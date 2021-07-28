import UIKit
import Flutter
import GoogleMaps
import google_maps_flutter
import flutter_local_notifications
import firebase_messaging
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // Use Firebase library to configure APIs
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
            
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        GMSServices.provideAPIKey("AIzaSyBTzAlKAyUTP1VuO6HdBWfAJA038b0vP8U")
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
                 // For iOS 10 display notification (sent via APNS)
                 UNUserNotificationCenter.current().delegate = self

                 let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                 UNUserNotificationCenter.current().requestAuthorization(
                   options: authOptions,
                   completionHandler: {_, _ in })
                   
               } else {
                 let settings: UIUserNotificationSettings =
                 UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                 application.registerUserNotificationSettings(settings)
               }
    }

   override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
   }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
                        // For iOS 10 display notification (sent via APNS)
                        UNUserNotificationCenter.current().delegate = self

                        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                        UNUserNotificationCenter.current().requestAuthorization(
                          options: authOptions,
                          completionHandler: {_, _ in })
                          
                      } else {
                        let settings: UIUserNotificationSettings =
                        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                        application.registerUserNotificationSettings(settings)
                      }
    }
}
