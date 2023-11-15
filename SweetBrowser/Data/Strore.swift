//
//  Strore.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/15.
//

import Foundation
import Combine

class Store: ObservableObject {
    @Published var state: AppState = AppState()
    var publishers = [AnyCancellable]()
    init() {
        dispatch(.launch)
        dispatch(.gad(.requestConfig))
    }
    func dispatch(_ action: Action) {
        debugPrint("[Action] \(action)")
        let result = Store.reduce(state, action: action)
        state = result.0
        let command = result.1
        command?.execute(in: self)
    }
    static func reduce(_ state: AppState, action: Action) -> (AppState, Command?) {
        var appState = state
        var command: Command? = nil
        switch action {
        case .launch:
            command = LaunchCommand()
        case .browser(let action, let item):
            command = BrowserCommand(action, item)
        case .clean:
            command = CleanCommand()
        case .gad(let action):
            command = GADCommand(action)
        case .att:
            command = ATTCommand()
        case .dismiss:
            command = DismissCommand()
        }
        return (appState, command)
    }
}
