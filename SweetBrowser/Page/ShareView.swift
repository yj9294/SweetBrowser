//
//  ShareView.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/19.
//

import Foundation
import SwiftUI

struct ShareView: UIViewControllerRepresentable {
    let url: String
    func makeUIViewController(context: Context) -> some UIViewController {
        return UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
