//
//  State.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/15.
//

import Foundation
import WebKit

struct AppState {
    
    var root = Root()
    var launch = Launch()
    var home = Home()
    var browser = Browser()
    var clean = Clean()
    var ad = GAD()
    
    struct Root {
        var isLaunch = true
        var isBackground = false
    }
    
    struct Launch {
        var progress = 0.0
    }
    
    struct Home {
        var text: String = ""
        var canGoBack: Bool = false
        var canGoFoward: Bool = false
        var isLoading: Bool = false
        var progress: Double = 0.0
        var isBrowser: Bool = false
        enum Item: String, CaseIterable {
            case facebook, google, youtube, twitter, instagram, amazon, tiktok, yahoo
            var title: String {
                return self.rawValue.capitalized
            }
            var url: String {
                return "https://www.\(self.rawValue).com"
            }
        }
    }
    
    struct Browser {
        var items: [BrowserItem] = [.navigation]
        var item: BrowserItem {
            items.filter {
                $0.isSelect
            }.first ?? .navigation
        }
        
        var webView: WKWebView {
            item.webView
        }
        
        func load(_ url: String) {
            item.load(url)
        }
        
        func back() {
            webView.goBack()
        }
        
        func forward() {
            webView.goForward()
        }
        
        func stop() {
            webView.stopLoading()
        }
        
        enum Action: CaseIterable {
            case refresh, load, stop, goBack, goForward, new, select, delete
        }
    }
    
    struct Setting{
        enum Item: String, CaseIterable {
            case new, copy, share, rate, terms, privacy
            var title: String {
                switch self {
                case .new, .copy, .share:
                    return self.rawValue.capitalized
                case .rate:
                    return "Rate Us"
                case .terms:
                    return "Terms of User"
                case .privacy:
                    return "Privacy Policy"
                }
            }
        }
    }
    
    struct Clean {
        var angle: Double = 0.0
        var progress: Double = 0.0
    }
    
    struct GAD {
        
        var adModel: GADNativeViewModel = .None
        var isCloseInter: Bool = false

        @UserDefault(key: "state.ad.config")
        var config: GADConfig?
       
        @UserDefault(key: "state.ad.limit")
        var limit: GADLimit?
        
        var impressionDate:[GADPosition.Position: Date] = [:]
        
        let ads:[GADLoadModel] = GADPosition.allCases.map { p in
            GADLoadModel(position: p)
        }
        
        func isLoaded(_ position: GADPosition) -> Bool {
            return self.ads.filter {
                $0.position == position
            }.first?.isLoaded == true
        }

        func isLimited(in store: Store) -> Bool {
            if limit?.date.isToday == true {
                if (store.state.ad.limit?.showTimes ?? 0) >= (store.state.ad.config?.showTimes ?? 0) || (store.state.ad.limit?.clickTimes ?? 0) >= (store.state.ad.config?.clickTimes ?? 0) {
                    return true
                }
            }
            return false
        }
        
        enum Action {
            case requestConfig, updateLimit(GADLimit.Status), appear(GADPosition), disappear(GADPosition), clean(GADPosition), load(GADPosition, GADPosition.Position = .home), show(GADPosition, GADPosition.Position = .home)
        }
    }
}


@propertyWrapper
struct UserDefault<T: Codable> {
    var value: T?
    let key: String
    init(key: String) {
        self.key = key
        self.value = UserDefaults.standard.getObject(T.self, forKey: key)
    }
    
    var wrappedValue: T? {
        set  {
            value = newValue
            UserDefaults.standard.setObject(value, forKey: key)
            UserDefaults.standard.synchronize()
        }
        
        get { value }
    }
}

extension UserDefaults {
    func setObject<T: Codable>(_ object: T?, forKey key: String) {
        let encoder = JSONEncoder()
        guard let object = object else {
            debugPrint("[US] object is nil.")
            self.removeObject(forKey: key)
            return
        }
        guard let encoded = try? encoder.encode(object) else {
            debugPrint("[US] encoding error.")
            return
        }
        self.setValue(encoded, forKey: key)
    }
    
    func getObject<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = self.data(forKey: key) else {
            debugPrint("[US] data is nil for \(key).")
            return nil
        }
        guard let object = try? JSONDecoder().decode(type, from: data) else {
            debugPrint("[US] decoding error.")
            return nil
        }
        return object
    }
}
