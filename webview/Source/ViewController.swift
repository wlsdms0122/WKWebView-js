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
    // MARK: - Constant
    enum Constant {
        static let host = URL(string: "http://127.0.0.1:8080")
    }
    
    // MARK: - View
    private var backButton: UIButton!
    private var titleLabel: UILabel!
    private var refreshButton: UIButton!
    private var webView: WKWebView!
    private var messageTextField: UITextField!
    private var sendButton: UIButton!
    
    // MARK: - Lifecycle
    override func loadView() {
        setUpLayout()
        setUpAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func setUpLayout() {
        let backButton: UIButton = {
            let view = UIButton(type: .system)
            view.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
            
            // Set up autolayout
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalTo: view.heightAnchor)
            ])
            
            return view
        }()
        
        let titleLabel: UILabel = {
            let view = UILabel()
            view.font = .systemFont(ofSize: 24)
            
            return view
        }()
        
        let refreshButton: UIButton = {
            let view = UIButton(type: .system)
            view.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
            
            // Set up autolayout
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalTo: view.heightAnchor)
            ])
            
            return view
        }()
        
        let headerStackView: UIStackView = {
            let view = UIStackView(arrangedSubviews: [backButton, titleLabel, refreshButton])
            view.axis = .horizontal
            
            return view
        }()
        
        let headerView: UIView = {
            let view = UIView()
            
            // Set up autolayout
            [headerStackView].forEach {
                view.addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
            
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: 44)
            ])
            
            NSLayoutConstraint.activate([
                headerStackView.topAnchor.constraint(equalTo: view.topAnchor),
                headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
                headerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8)
            ])
            
            return view
        }()
        
        let webView: WKWebView = {
            // Create user content controller.
            let userContentController = WKUserContentController()
            // *1: (Web -> App) A the script message handler.
            // Should be the same name you pass when posting a message to your app on the web.
            userContentController.add(self, name: "scriptHandler")
            // *2: (App -> Web) Call javascript function named by "config()" when injection time.
            // You can pass the HTML document into source parameter.
            userContentController.addUserScript(WKUserScript(source: "config()", injectionTime: .atDocumentEnd, forMainFrameOnly: true))
            
            // Creat web view configuration.
            let configuration = WKWebViewConfiguration()
            configuration.userContentController = userContentController
            
            // Instantiate WKWebView.
            let view = WKWebView(frame: .zero, configuration: configuration)
            
            // Set delegates
            view.uiDelegate = self
            view.navigationDelegate = self
            
            return view
        }()
        
        let messageTextField: UITextField = {
            let view = UITextField()
            view.borderStyle = .roundedRect
            
            return view
        }()
        
        let sendButton: UIButton = {
            let view = UIButton(type: .system)
            view.layer.cornerRadius = 8
            view.layer.borderColor = view.tintColor.cgColor
            view.layer.borderWidth = 1
            view.setTitle("Send", for: .normal)
            
            // Set up autolayout
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: 44)
            ])
            
            return view
        }()
        
        let messageStackView: UIStackView = {
            let view = UIStackView(arrangedSubviews: [messageTextField, sendButton])
            view.axis = .vertical
            view.spacing = 8
            
            return view
        }()
        
        let messageView: UIView = {
            let view = UIView()
            
            // Set up autolayout
            [messageStackView].forEach {
                view.addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
            
            NSLayoutConstraint.activate([
                messageStackView.topAnchor.constraint(equalTo: view.topAnchor),
                messageStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
                messageStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                messageStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8)
            ])
            
            return view
        }()
        
        let contentStackView: UIStackView = {
            let view = UIStackView(arrangedSubviews: [headerView, webView, messageView])
            view.axis = .vertical
            
            return view
        }()
        
        let view: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            
            // Set up autolayout
            [contentStackView].forEach {
                view.addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
            
            NSLayoutConstraint.activate([
                contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                contentStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                contentStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                contentStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
            ])
            
            return view
        }()
        
        self.backButton = backButton
        self.refreshButton = refreshButton
        self.titleLabel = titleLabel
        self.webView = webView
        self.messageTextField = messageTextField
        self.sendButton = sendButton
        self.view = view
    }
    
    private func setUpAction() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.webView.goBack()
        }, for: .touchUpInside)
        
        refreshButton.addAction(UIAction { [weak self] _ in
            self?.webView.reload()
        }, for: .touchUpInside)
        
        sendButton.addAction(UIAction { [weak self] _ in
            guard let text = self?.messageTextField.text else { return }
            self?.messageTextField.text = nil
            
            // *3: (App -> Web) Evaluate javascript on web.
            // You can call javascript function on web.
            self?.webView.evaluateJavaScript("set(\"\(text)\")") {
                print("🚥 trace: \(#function):\(#line)")
                print("result: \($0)")
                print("error: \($1)")
            }
        }, for: .touchUpInside)
    }
    
    private func load() {
        guard let host = Constant.host else {
            print("Invalid URL \(Constant.host?.absoluteString ?? "🐛")")
            return
        }
        
        // Load web page (ex. localhost)
        webView.load(URLRequest(url: host))
    }
}

extension ViewController: WKNavigationDelegate {
    
}

extension ViewController: WKUIDelegate {
    
}

extension ViewController: WKScriptMessageHandler {
    // *1: (Web -> App) Process received message from javascript on the web.
    //
    // message.name: script message handler
    // message.body: (object)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("🚥 trace: \(#function):\(#line)")
        print("message.name: \(message.name)")
        print("message.body: \(message.body)")
    }
}
