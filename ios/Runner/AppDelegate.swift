import UIKit
import Flutter
import MSAL

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (url.absoluteString.hasPrefix("azdevopsshareext.io.purplesoft.azuredevops://share?")) {
            let cleanUrlString = url.absoluteString.replacingOccurrences(of: "azdevopsshareext.io.purplesoft.azuredevops://share?", with: "sharedUrl?")
            let cleanUrl = URL(string: cleanUrlString)!
            print("AppDelegate: Handling URL \(cleanUrl)")
            return super.application(app, open: cleanUrl, options:options)
        }

        if (url.absoluteString.hasPrefix("msauth.io.purplesoft.azuredevops")) {
            return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: nil)
        }
        
        return false
    }
}
