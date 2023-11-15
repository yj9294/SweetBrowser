//
//  Action.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/15.
//

import Foundation

enum Action {
    case launch
    case browser(AppState.Browser.Action, BrowserItem = .navigation)
    case clean
    case gad(AppState.GAD.Action)
    case att
    case dismiss
}
