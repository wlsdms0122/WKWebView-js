//
//  ViewController.swift
//  webview
//
//  Created by JSilver on 2020/03/17.
//  Copyright © 2020 JSilver. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    private var webView: WKWebView!
    
    override func loadView() {
        // Create user content controller
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "scriptHandler")
        
        // Creat web view configuration
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController

        // Init web view
        webView = WKWebView(frame: .zero, configuration: configuration)
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load web page (ex. localhost)
        webView.load(URLRequest(url: URL(string: "http://127.0.0.1:8080")!))
    }
}

extension ViewController: WKScriptMessageHandler {
    // Process message from javascript of web view
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // message.name: scriptHandler
        // message.body: {
        //     age = 26;
        //     name = "jeong jin eun";
        // }
        print("message.name: \(message.name)")
        print("message.body: \(message.body)")
        
        guard let params = message.body as? [String: Any] else { return }
        guard let name = params["name"] as? String, let age = params["age"] as? Int else { return }
        
        let alertController = UIAlertController(title: nil, message: "name: \(name)\nage: \(age)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
