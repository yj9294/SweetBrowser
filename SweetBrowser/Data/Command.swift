//
//  Command.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/15.
//

import Foundation
import AppTrackingTransparency
import Combine
import UIKit
import SheetKit

protocol Command {
    func execute(in store: Store)
}

class SubscriptionToken {
    var cancelable: AnyCancellable?
    func unseal() { cancelable = nil }
}

extension AnyCancellable {
    func seal(in token: SubscriptionToken) {
        token.cancelable = self
    }
}

struct LaunchCommand: Command {
    @MainActor
    func execute(in store: Store) {
        var progress = 0.0
        var duration = 12.3
        let token = SubscriptionToken()
        let token1 = SubscriptionToken()
        store.state.root.isLaunch = true
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            token.unseal()
        }
        store.state.launch.progress = 0
        Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { _ in
            progress += 0.01 / duration
            if AppEnterBackground {
                token.unseal()
                token1.unseal()
                return
            }
            store.state.launch.progress = progress
            if progress > 1.0 {
                token.unseal()
                store.dispatch(.gad(.show(.open)))
            }
            if store.state.ad.isLoaded(.open), progress > 0.3 {
                duration = 0.1
            }
        }.seal(in: token)
        
        Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { _ in
            if store.state.ad.isCloseInter, store.state.launch.progress > 1.0 {
                token1.unseal()
                store.state.root.isLaunch = false
            }
        }.seal(in: token1)
        
        Task {
            if !Task.isCancelled {
                try await Task.sleep(nanoseconds: 500_000_000)
                store.dispatch(.gad(.load(.open)))
                store.dispatch(.gad(.load(.interstitial)))
                store.dispatch(.gad(.load(.native)))
            }
        }
    }
}

struct BrowserCommand: Command {
    
    let action: AppState.Browser.Action
    let item: BrowserItem
    
    init(_ action: AppState.Browser.Action, _ item: BrowserItem = .navigation) {
        self.action = action
        self.item = item
    }
    
    func execute(in store: Store) {
        
        let text = store.state.home.text
        
        switch action {
        case .refresh:
            store.state.home.text = ""
            let webView = store.state.browser.webView
            let goback = webView.publisher(for: \.canGoBack).sink { canGoBack in
                store.state.home.canGoBack = canGoBack
            }
            
            let goForword = webView.publisher(for: \.canGoForward).sink { canGoForword in
                store.state.home.canGoFoward = canGoForword
            }
            
            let isLoading = webView.publisher(for: \.isLoading).sink { isLoading in
                store.state.home.isLoading = isLoading
            }
            
            let progress = webView.publisher(for: \.estimatedProgress).sink { progress in
                store.state.home.progress = progress
                store.state.home.isLoading = progress != 1.0 && progress != 0.0
            }
            
            let isNavigation = webView.publisher(for: \.url).map{$0 == nil}.sink { isNavigation in
                store.state.home.isBrowser = !isNavigation
                store.state.home.text = webView.url?.absoluteString ?? ""
            }
            
            let url = webView.publisher(for: \.url).compactMap{$0}.sink { url in
                store.state.home.text = webView.url?.absoluteString ?? ""
            }
            store.publishers = [goback, goForword, progress, isLoading, isNavigation, url]
        case .goBack:
            store.state.browser.back()
        case .goForward:
            store.state.browser.forward()
        case .stop:
            store.state.browser.stop()
        case  .load:
            store.state.browser.load(text)
        case .new:
            store.state.browser.items.forEach({$0.isSelect = false})
            store.state.browser.items.insert(.navigation, at: 0)
        case .delete:
            if item.isSelect {
                store.state.browser.items = store.state.browser.items.filter({
                    !$0.isSelect
                })
                store.state.browser.items.first?.isSelect = true
            } else {
                store.state.browser.items = store.state.browser.items.filter({
                    $0 != item
                })
            }
        case .select:
            store.state.browser.items.forEach {
                $0.isSelect = false
            }
            item.isSelect = true
        }
    }
}


struct CleanCommand: Command {
    func execute(in store: Store) {
        var angle = 0.0
        var progress = 0.0
        var duration = 12.3
        let token = SubscriptionToken()
        let token1 = SubscriptionToken()
        let token2 = SubscriptionToken()
        store.state.clean.progress = 0
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            token.unseal()
        }
        
        // 动画定时器
        Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { _ in
            angle += 0.01 / 2.5
            store.state.clean.angle = angle * 360
        }.seal(in: token)
        
        // 广告定时器
        Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { _ in
            progress += 0.01 / duration
            store.state.clean.progress = progress
            if AppEnterBackground {
                token.unseal()
                token1.unseal()
                token2.unseal()
                return
            }
            if progress > 1.0 {
                token1.unseal()
                store.dispatch(.gad(.show(.interstitial)))
            }
            if progress > 0.2, store.state.ad.isLoaded(.interstitial) {
                duration = 0.01
            }
        }.seal(in: token1)
        
        Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { _ in
            if store.state.ad.isCloseInter, store.state.clean.progress > 1.0 {
                token.unseal()
                token1.unseal()
                token2.unseal()
                SheetKit().dismiss()
            }
        }.seal(in: token2)
        
        store.state.browser.items = [.navigation]
        store.dispatch(.browser(.refresh))
        
        store.dispatch(.gad(.load(.interstitial)))
    }
}

struct GADCommand: Command {
    let action: AppState.GAD.Action
    init(_ action:  AppState.GAD.Action) {
        self.action = action
    }
    
    func execute(in store: Store) {
        switch action {
        case .requestConfig:
            if store.state.ad.config == nil {
                let path = Bundle.main.path(forResource: "admob", ofType: "json")
                let url = URL(fileURLWithPath: path!)
                do {
                    let data = try Data(contentsOf: url)
                    let config = try JSONDecoder().decode(GADConfig.self, from: data)
                    store.state.ad.config = config
                    NSLog("[Config] Read local ad config success.")
                } catch let error {
                    NSLog("[Config] Read local ad config fail.\(error.localizedDescription)")
                }
            }
            
            /// 广告配置是否是当天的
            if store.state.ad.limit == nil || store.state.ad.limit?.date.isToday != true {
                store.state.ad.limit = GADLimit(showTimes: 0, clickTimes: 0, date: Date())
            }
        case .updateLimit(let status):
            if store.state.ad.isLimited(in: store) {
                NSLog("[AD] 用戶超限制。")
                store.dispatch(.gad(.clean(.interstitial)))
                store.dispatch(.gad(.clean(.native)))
                store.dispatch(.gad(.disappear(.native)))
                return
            }

            if status == .show {
                let showTime = store.state.ad.limit?.showTimes ?? 0
                store.state.ad.limit?.showTimes = showTime + 1
                NSLog("[AD] [LIMIT] showTime: \(showTime+1) total: \(store.state.ad.config?.showTimes ?? 0)")
            } else  if status == .click {
                let clickTime = store.state.ad.limit?.clickTimes ?? 0
                store.state.ad.limit?.clickTimes = clickTime + 1
                NSLog("[AD] [LIMIT] clickTime: \(clickTime+1) total: \(store.state.ad.config?.clickTimes ?? 0)")
            }
        case .appear(let position):
            store.state.ad.ads.filter {
                $0.position == position
            }.first?.display()
        case .disappear(let position):
            store.state.ad.ads.filter{
                $0.position == position
            }.first?.closeDisplay()
            
            if position == .native {
                store.state.ad.adModel = .None
            }
        case .clean(let position):
            let loadAD = store.state.ad.ads.filter{
                $0.position == position
            }.first
            loadAD?.clean()
        case .load(let position, let p):
            let ads = store.state.ad.ads.filter{
                $0.position == position
            }
            if let ad = ads.first {
                // 插屏直接一步加载
                if position == .interstitial || position == .open {
                    ad.beginAddWaterFall(in: store)
                } else if position == .native{
                    // 原生广告需要同步显示
                    ad.beginAddWaterFall(callback: { isSuccess in
                        if isSuccess {
                            store.dispatch(.gad(.show(position, p)))
                        }
                    }, in: store)
                }
            }
        case .show(let position, let p):
            // 超限需要清空广告
            if store.state.ad.isLimited(in: store) {
                store.dispatch(.gad(.clean(.interstitial)))
                store.dispatch(.gad(.clean(.native)))
                store.dispatch(.gad(.disappear(.native)))
            }
            let loadAD = store.state.ad.ads.filter {
                $0.position == position
            }.first
            switch position {
            case .interstitial, .open:
                /// 有廣告
                if let ad = loadAD?.loadedArray.first as? GADBaseModel.GADFullScreenModel, !store.state.ad.isLimited(in: store) {
                    ad.impressionHandler = {
                        store.dispatch(.gad(.updateLimit(.show)))
                        store.dispatch(.gad(.appear(position)))
                        store.dispatch(.gad(.load(position, p)))
                    }
                    ad.clickHandler = {
                        if !store.state.ad.isLimited(in: store) {
                            store.dispatch(.gad(.updateLimit(.click)))
                            if store.state.ad.isLimited(in: store) {
                                NSLog("[ad] 广告超限 点击无效")
                            }
                        } else {
                            NSLog("[ad] 广告超限 点击无效")
                        }
                    }
                    ad.closeHandler = {
                        store.dispatch(.gad(.disappear(position)))
                        store.state.ad.isCloseInter = true
                    }
                    store.state.ad.isCloseInter = false
                    if !AppEnterBackground {
                        ad.present()
                    }
                } else {
                    store.state.ad.isCloseInter = true
                }
                
            case .native:
                if let ad = loadAD?.loadedArray.first as? GADBaseModel.GADNativeModel, !store.state.ad.isLimited(in: store) {
                    /// 预加载回来数据 当时已经有显示数据了
                    if loadAD?.isDisplay == true {
                        return
                    }
                    ad.nativeAd?.unregisterAdView()
                    ad.nativeAd?.delegate = ad
                    ad.impressionHandler = {
                        store.state.ad.impressionDate[p] = Date()
                        store.dispatch(.gad(.updateLimit(.show)))
                        store.dispatch(.gad(.appear(position)))
                        store.dispatch(.gad(.load(position, p)))
                    }
                    ad.clickHandler = {
                        if !store.state.ad.isLimited(in: store) {
                            store.dispatch(.gad(.updateLimit(.click)))
                            if store.state.ad.isLimited(in: store) {
                                NSLog("[ad] 广告超限 点击无效")
                            }
                        } else {
                            NSLog("[ad] 广告超限 点击无效")
                        }
                    }
                    // 10秒间隔
                    if let date = store.state.ad.impressionDate[p], Date().timeIntervalSince1970 - date.timeIntervalSince1970  < 10 {
                        NSLog("[ad] 刷新或数据加载间隔 10s postion: \(p)")
                        store.state.ad.adModel = .None
                        return
                    }
                    
                    let adViewModel = GADNativeViewModel(ad:ad, view: UINativeAdView())
                    store.state.ad.adModel = adViewModel
                } else {
                    /// 预加载回来数据 当时已经有显示数据了 并且没超过限制
                    if loadAD?.isDisplay == true, !store.state.ad.isLimited(in: store) {
                        return
                    }
                    store.state.ad.adModel = .None
                }
            }
        }
    }
}

struct ATTCommand: Command {
    func execute(in store: Store) {
        ATTrackingManager.requestTrackingAuthorization { _ in
        }
    }
}

struct DismissCommand: Command {
    func execute(in store: Store) {
        if let windowScene = UIApplication.shared.connectedScenes.filter({$0 is UIWindowScene}).first as? UIWindowScene, let rootVC = windowScene.keyWindow?.rootViewController {
            if let presentVC = rootVC.presentedViewController {
                if let presentPresentVC = presentVC.presentedViewController {
                    presentPresentVC.dismiss(animated: true) {
                        presentVC.dismiss(animated: true)
                    }
                    return
                }
                presentVC.dismiss(animated: true)
            }
        }
    }
}
