//
//  ContentView.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/15.
//

import SwiftUI

var AppEnterBackground = false
struct ContentView: View {
    @EnvironmentObject var store: Store
    
    var progress: Double {
        store.state.launch.progress
    }
    
    var body: some View {
        VStack{
            if store.state.root.isLaunch {
                LaunchPage(progress: progress)
            } else {
                HomePage()
            }
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            AppEnterBackground = false
            store.dispatch(.dismiss)
            store.dispatch(.launch)
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _  in
            AppEnterBackground = true
            store.dispatch(.dismiss)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Store())
    }
}
