//
//  WebView.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/18.
//

import Foundation
import WebKit
import SwiftUI

struct WebView: UIViewRepresentable {
    let webView: WKWebView
    func makeUIView(context: Context) -> some UIView {
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
