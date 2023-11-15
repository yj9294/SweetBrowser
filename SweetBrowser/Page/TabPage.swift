//
//  TabPage.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/19.
//

import SwiftUI
import SheetKit

struct TabPage: View {
    @EnvironmentObject var store: Store
    var body: some View {
        VStack{
            ScrollView{
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]) {
                    ForEach(store.state.browser.items, id: \.self) { item in
                        ZStack(alignment: .top){
                            LinearGradient(colors: [Color("#6E88F7"), Color("#DCA7F0")], startPoint: .leading, endPoint: .trailing)
                            Button {
                                store.dispatch(.gad(.disappear(.native)))
                                SheetKit().dismiss()
                                store.dispatch(.browser(.select, item))
                                store.dispatch(.browser(.refresh))
                            } label: {
                                if !item.isSelect {
                                    Color.gray
                                }
                            }
                            Button(action: {
                                store.dispatch(.browser(.delete, item))
                                store.dispatch(.browser(.refresh))
                            }, label: {
                                HStack{
                                    Spacer()
                                    Image("close").padding(.trailing, 8)
                                }.padding(.top, 8).opacity(store.state.browser.items.count == 1 ? 0 : 1.0)
                            })
                            Text(item.url).foregroundColor(.white).padding(20).font(.system(size: 14.0))
                        }.cornerRadius(8).frame(height: 210)
                        
                    }
                }
            }.padding(.all, 16)
            HStack{
                GADNativeView(model: store.state.ad.adModel).background(Color.white.cornerRadius(4))
            }.padding(.horizontal, 16).padding(.top, 28)
            Spacer()
            ZStack {
                HStack{
                    Spacer()
                    Button(action: {
                        store.dispatch(.gad(.disappear(.native)))
                        SheetKit().dismiss()
                    }, label: {
                        Text("back").font(.system(size: 14, weight: .bold)).foregroundColor(.white).padding(.trailing, 20)
                    })
                }
                Button(action: {
                    store.dispatch(.gad(.disappear(.native)))
                    SheetKit().dismiss()
                    store.dispatch(.browser(.new))
                    store.dispatch(.browser(.refresh))
                }, label: {
                    Image("add").padding(.vertical, 16)
                })
            }.background(LinearGradient(colors: [Color("#6E88F7"), Color("#DCA7F0")], startPoint: .leading, endPoint: .trailing))
        }
    }
}

struct TabPage_Previews: PreviewProvider {
    static var previews: some View {
        TabPage().environmentObject(Store())
    }
}
