//
//  LaunchPage.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/15.
//

import SwiftUI

struct LaunchPage: View {
    var progress: Double {
        didSet {
            if progress > 1.0 {
                progress = 1.0
            }
        }
    }
    var body: some View {
        VStack(spacing: 0){
            Image("icon").padding(.top, 136)
            Image("Sweet Browser").padding(.top, 43)
            Spacer()
            HStack{
                GeometryReader { proxy in
                    HStack(spacing: 0){
                        LinearGradient(colors: [Color("#758AF7"), Color("#DDA8F0")], startPoint: .leading, endPoint: .trailing).frame(width: proxy.size.width * progress)
                        Color("#BD1E54").opacity(0.10)
                    }
                }.frame(height: 6).cornerRadius(3)
            }.padding(.horizontal, 80).padding(.bottom, 60)
        }.background(Image("bg").resizable().ignoresSafeArea())
    }
}

struct LaunchPage_Previews: PreviewProvider {
    static var previews: some View {
        LaunchPage(progress: 0.2)
    }
}
