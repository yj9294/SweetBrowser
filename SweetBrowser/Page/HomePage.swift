//
//  HomePage.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/15.
//

import SwiftUI
import SheetKit

struct HomePage: View {
    
    @EnvironmentObject var store: Store
    
    @State var isShowTab = false
    
    @State var isShowAlert = false
    
    var body: some View {
        ZStack {
            VStack{
                HStack{
                    HStack{
                        TextField("", text: $store.state.home.text, prompt: Text("Search or enter URL").font(.system(size: 14)))
                        Button(action: {
                            if !store.state.home.isLoading {
                                search()
                            } else {
                                store.dispatch(.browser(.stop))
                            }
                        }, label: {
                            Image(!store.state.home.isLoading ? "search" : "stop")
                        })
                    }.padding(.horizontal, 20).padding(.vertical, 18).background(RoundedRectangle(cornerRadius: 28).stroke(Color("#C4A0F2"), lineWidth: 1))
                }.padding(.all, 20)
                GeometryReader { proxy in
                    HStack(spacing: 0){
                        LinearGradient(colors: [Color("#758AF7"), Color("#DDA8F0")], startPoint: .leading, endPoint: .trailing).frame(width: proxy.size.width * store.state.home.progress)
                        Color("#BD1E54").opacity(0.10)
                    }
                }.frame(height: 2).cornerRadius(3).opacity(store.state.home.isLoading ? 1.0 : 0.0)
                VStack{
                    if store.state.home.isBrowser, !isShowTab {
                        WebView(webView: store.state.browser.webView)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]) {
                            ForEach(AppState.Home.Item.allCases, id: \.self) { item in
                                Button(action: {
                                    store.state.home.text = item.url
                                    store.dispatch(.browser(.load))
                                    store.dispatch(.browser(.refresh))
                                }, label: {
                                    VStack{
                                        Image(item.rawValue)
                                        Text(item.title)
                                    }
                                }).foregroundColor(.black)
                            }
                        }
                        if !isShowTab {
                            HStack{
                                GADNativeView(model: store.state.ad.adModel).background(Color.white.cornerRadius(4))
                            }.padding(.horizontal, 16).padding(.top, 28)
                        }
                        Spacer()
                    }
                }.background(Color("#FFF7FE")).padding(.top, 10)
                HStack {
                    Button(action: {
                        store.dispatch(.browser(.goBack))
                    }, label: {
                        Image("left").opacity(store.state.home.canGoBack ? 1.0 : 0.5)
                    })
                    Spacer()
                    Button(action: {
                        store.dispatch(.browser(.goForward))
                    }, label: {
                        Image("right").opacity(store.state.home.canGoFoward ? 1.0 : 0.5)
                    })
                    Spacer()
                    Button(action: {
                        isShowAlert = true
                    }, label: {
                        Image("clean")
                    })
                    Spacer()
                    Button(action: {
                        isShowTab = true
                        store.dispatch(.gad(.disappear(.native)))
                        store.dispatch(.gad(.load(.native, .tab)))
                        SheetKit().present(with: .fullScreenCover) {
                            TabPage().environmentObject(store).onDisappear{
                                isShowTab = false
                            }
                        }
                    }) {
                        ZStack {
                            Image("window")
                            Text("\(store.state.browser.items.count)").font(.system(size: 13)).foregroundColor(.black)
                        }
                    }
                    Spacer()
                    Button {
                        SheetKit().present(with: .fullScreenCover) {
                            SettingPage().environmentObject(store)
                        }
                    } label: {
                        Image("setting")
                    }
                }.padding(.horizontal, 12).background(Image("bg").resizable().frame(height: 64))
            }
            if isShowAlert {
                AlertView(isPresent: $isShowAlert) {
                    store.dispatch(.clean)
                    SheetKit().present(with: .fullScreenCover) {
                        CleanPage().environmentObject(store)
                    }
                }
            }
        }.onAppear {
            store.dispatch(.att)
            store.dispatch(.gad(.load(.native)))
            store.dispatch(.gad(.load(.interstitial)))
        }
    }
}
extension HomePage {
    func search() {
        UIApplication.shared.keyWindow?.resignFirstResponder()
        if store.state.home.text.count == 0 {
            SheetKit().present(with: .bottomSheet) {
                Text("Please enter your search content.")
            }
            return
        }
        store.dispatch(.browser(.load))
        store.dispatch(.browser(.refresh))
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage().environmentObject(Store())
    }
}
