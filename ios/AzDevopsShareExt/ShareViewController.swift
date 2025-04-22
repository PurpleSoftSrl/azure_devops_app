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
    private let allowedDomains = ["visualstudio.com", "dev.azure.com"]

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard
            let extensionItem = extensionContext?.inputItems.first
                as? NSExtensionItem,
            let itemProvider = extensionItem.attachments?.first
        else {
            self.extensionContext!.completeRequest(
                returningItems: [], completionHandler: nil)
            return
        }

        let textDataType: String = UTType.url.identifier

        if itemProvider.hasItemConformingToTypeIdentifier(textDataType) {
            itemProvider.loadItem(
                forTypeIdentifier: textDataType as String, options: [:]
            ) { providedText, error in
                guard error == nil, let text = providedText as? NSURL else {
                    return
                }

                let urlHost = text.host ?? ""
                print("url: \(text), host: \(urlHost)")

                if urlHost.isEmpty {
                    print("Empty URL host")
                    self.extensionContext?.cancelRequest(
                        withError: NSError(domain: "EmptyURL", code: 1))
                    return
                }

                if !self.allowedDomains.contains(where: { d in
                    urlHost.lowercased().contains(d.lowercased())
                }) {
                    print("Invalid domain: \(urlHost)")
                    self.extensionContext?.cancelRequest(
                        withError: NSError(domain: "InvalidDomain", code: 1))
                    return
                }

                print("Valid URL, opening it")
                self.appURLString += (text.absoluteString ?? "")
                self.openMainApp()
            }
        }
    }

    private func openMainApp() {
        guard let url = URL(string: self.appURLString) else { return }

        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url)
            }
            responder = responder?.next
        }

        self.extensionContext!.completeRequest(
            returningItems: [], completionHandler: nil)
    }
}
