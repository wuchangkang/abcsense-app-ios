import UIKit
import CoreData
import UserNotifications
import CoreLocation
import MediaPlayer
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let locationManager = CLLocationManager()
    static var triggerTime = Date()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        // application.registerUserNotificationSettings(settings)
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            if granted {
                print("UNUserNotificationCenter granted")
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        locationManager.delegate = self
        let notificationType:UIUserNotificationType = [UIUserNotificationType.sound, UIUserNotificationType.alert]
        let notificationSettings = UIUserNotificationSettings(types: notificationType, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        
        // Override point for customization after application launch.
        return true
    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        BeaconManager.sharedInstance.running = false
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "BeaconApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("userInfo = \(userInfo)")
        DispatchQueue.main.async {
            let beaconManager = BeaconManager.sharedInstance
            for m in beaconManager.displayBeaconMessages {
                if m.getId() == userInfo["id"] as! String {
                    beaconManager.currBeaconMessage = m
                    Constants.ViewController?.toViewController()
                    break
                }
            }
        }
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if AppDelegate.triggerTime > Date() {
            return
        }
        AppDelegate.triggerTime = Date().addingTimeInterval(60 * 2)
        
        let notification = UILocalNotification()
        notification.alertBody = "前方有智慧號誌"
        notification.soundName = "Default"
        UIApplication.shared.presentLocalNotificationNow(notification)
        // playSound()
    }
    
    func playSound() {
        print("playSound()")
        let url = Bundle.main.url(forResource: "sound", withExtension: "aifc")!
        do {
            if let player = NotificationUtil.player {
                player.stop()
            }
            NotificationUtil.player = try AVAudioPlayer(contentsOf: url)
            guard let player = NotificationUtil.player else { return }
            player.prepareToPlay()
            player.play()
            print("playSound() play")
        } catch {
            print("error = \(error.localizedDescription)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //let notification = UILocalNotification()
        //notification.alertBody = "前方有智慧號誌2"
        //notification.soundName = "Default"
        //UIApplication.shared.presentLocalNotificationNow(notification)
    }
}

