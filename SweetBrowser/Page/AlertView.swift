//
//  AlertView.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/19.
//

import SwiftUI

struct AlertView: View {
    @Binding var isPresent: Bool
    let confirm: (()->Void)
    var body: some View {
        VStack{
            Spacer()
            VStack{
                VStack {
                    HStack{
                        Spacer()
                    }
                    Image("junk")
                    Text("Close Tabs and Clear Data")
                    Button {
                        isPresent = false
                        confirm()
                    } label: {
                        Text("Confirm").padding(.vertical, 14).padding(.horizontal, 65).foregroundColor(.black).background(LinearGradient(colors: [Color("#7EFF71"), Color("#D6FF71")], startPoint: .leading, endPoint: .trailing)).cornerRadius(22)
                    }.padding(.bottom, 20)
                }.background(Color.white.cornerRadius(12))
            }.padding(.horizontal, 34)
            Spacer()
        }.background(Button(action: {
            isPresent = false
        }, label: {
            Color.black.opacity(0.4).ignoresSafeArea()
        }))
    }
}
