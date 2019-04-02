//
//  DetailViewController.swift
//  Day24-Project4
//
//  Created by 李沐軒 on 2019/3/9.
//  Copyright © 2019 李沐軒. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var progressView: UIProgressView!
    var websiteName: String?
    var websites = ["www.apple.com", "www.google.com", "www.nbcnews.com", "www.someporn.com", "www.someviolence.com", "www.someillegal.com"]
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let websiteName = websiteName {
            let url = URL(string: "https://" + websiteName)
            webView.load(URLRequest(url: url!))
            webView.allowsBackForwardNavigationGestures = true
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        let backButton = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(goBack))
        
        let forwardButton = UIBarButtonItem(title: "Forward", style: .done, target: self, action: #selector(goForward))
        
        
        toolbarItems = [progressButton, spacer, forwardButton, backButton, refresh]
        navigationController?.isToolbarHidden = false
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
      
    }
    
    @objc func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @objc func openTapped() {
        let ac = UIAlertController(title: "Open page", message: nil, preferredStyle: .actionSheet)
        
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
            
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true, completion: nil)
        
    }
    
    func openPage(action: UIAlertAction) {
        
        if (action.title?.contains("porn"))! || (action.title?.contains("violence"))! || (action.title?.contains("illegal"))! {
            blockAlert()
        } else {
            let url = URL(string: "https://" + action.title!)!
            webView.load(URLRequest(url: url))
        }
        
    }
    
    func blockAlert() {
        let ac = UIAlertController(title: "Sorry", message: "You are not allowed visit this website.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "continue", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        
        decisionHandler(.cancel)
    }
}
