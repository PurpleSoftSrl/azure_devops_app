//
//  ShareViewController.swift
//  AzDevopsShareExt
//
//  Created by Simone Stasi on 16/04/25.
//

import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    private var appURLString =
        "azdevopsshareext.io.purplesoft.azuredevops://share?url="

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")

        guard
            let extensionItem = extensionContext?.inputItems.first
                as? NSExtensionItem,
            let itemProvider = extensionItem.attachments?.first
        else {
            self.extensionContext!.completeRequest(
                returningItems: [], completionHandler: nil)
            return
        }

        let textDataType = UTType.url.identifier
        if itemProvider.hasItemConformingToTypeIdentifier(textDataType) {
            // Load the item from itemProvider
            itemProvider.loadItem(forTypeIdentifier: textDataType, options: nil)
            { (providedText, error) in
                if error != nil {
                    return
                }
                if let text = providedText as? NSURL {
                    // this is where we load our view
                    print("url: \(text)")
                    self.appURLString += (text.absoluteString ?? "")
                    self.openMainApp()
                } else {
                    return
                }
            }

        }
    }

    private func openMainApp() {
        self.extensionContext?.completeRequest(
            returningItems: nil,
            completionHandler: { _ in
                guard let url = URL(string: self.appURLString) else { return }
                self.openURL(url)
            })
    }

    @objc func openURL(_ url: URL) {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.open(url)
            }
            responder = responder?.next
        }
    }

}
