//
//  CleanPage.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/19.
//

import SwiftUI

struct CleanPage: View {
    
    @EnvironmentObject var store: Store
    
    var body: some View {
        VStack{
            Spacer()
            VStack(spacing: 80){
                ZStack{
                    HStack {
                        Spacer()
                        Image("animation").rotationEffect(.degrees(store.state.clean.angle))
                        Spacer()
                    }
                    Image("junk 1")
                }
                Text("Cleaning...")
            }
            Spacer()
        }.background(Image("background").resizable().scaledToFill().ignoresSafeArea())
    }
}
