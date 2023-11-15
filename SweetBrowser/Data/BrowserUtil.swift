//
//  BrowserUtil.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/18.
//

import Foundation
import UIKit
import WebKit

class BrowserItem: NSObject, ObservableObject {
    init(webView: WKWebView, isSelect: Bool) {
        self.webView = webView
        self.isSelect = isSelect
    }
    @Published var webView: WKWebView
    @Published var isSelect: Bool
    var isNavigation: Bool {
        return webView.url == nil
    }
    var url: String {
        webView.url?.absoluteString ?? "Navigation"
    }

    static var navigation: BrowserItem {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return BrowserItem(webView: webView, isSelect: true)
    }
    
    func load(_ url: String) {
        webView.navigationDelegate = self
        if url.isUrl, let Url = URL(string: url) {
            let request = URLRequest(url: Url)
            webView.load(request)
        } else {
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let reqString = "https://www.google.com/search?q=" + urlString
            self.load(reqString)
        }
    }
    
    func stopLoad() {
        webView.stopLoading()
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goForword() {
        webView.goForward()
    }
}

extension BrowserItem:  WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }
}

extension String {
    var isUrl: Bool {
        let url = "[a-zA-z]+://.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", url)
        return predicate.evaluate(with: self)
    }
}

