//
//  SettingPage.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/19.
//

import SwiftUI
import SheetKit
import UniformTypeIdentifiers

let AppUrl = "https://itunes.apple.com/cn/app/id6471948404"

struct SettingPage: View {
    
    @EnvironmentObject var store: Store
    var body: some View {
        VStack{
            HStack{
                Button {
                    SheetKit().dismiss()
                } label: {
                    Image("back").padding(.leading, 16)
                }.padding(.vertical, 20)
                Spacer()
            }
            Spacer()
            ScrollView(showsIndicators: false) {
                ForEach(AppState.Setting.Item.allCases, id: \.self) { item in
                    HStack{
                        Button(action: {
                            select(item)
                        }, label: {
                            HStack{
                                Text(item.title).padding(.all, 18)
                                Spacer()
                                Image("arrow").padding(.trailing, 20)
                            }.background(RoundedRectangle(cornerRadius: 8).stroke(Color.black)).foregroundColor(Color.black)
                        })
                    }.padding(.horizontal, 32).padding(.vertical, 12)
                }
            }
        }.onAppear{
            store.dispatch(.gad(.disappear(.native)))
        }
    }
    
    func select(_ item: AppState.Setting.Item) {
        switch item {
        case .new:
            SheetKit().dismiss()
            store.dispatch(.browser(.new))
            store.dispatch(.browser(.refresh))
        case .copy:
            UIPasteboard.general.setValue(store.state.home.text, forPasteboardType: UTType.plainText.identifier)
            SheetKit().present(with: .bottomSheet) {
                Text("Cope successfully.")
            }
        case .share:
            SheetKit().present {
                ShareView(url: !store.state.home.isBrowser ? AppUrl : store.state.browser.item.url)
            }
        case .rate:
            OpenURLAction { URL in
                .systemAction(URL)
            }.callAsFunction(URL(string: AppUrl)!)
        case .terms:
            SheetKit().present(with:.fullScreenCover) {
                PrivacyPage()
            }
        case .privacy:
            SheetKit().present(with:.fullScreenCover) {
                PrivacyPage()
            }
        }
    }
}

struct SettingPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingPage().environmentObject(Store())
    }
}
