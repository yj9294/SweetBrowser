//
//  TermsPage.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/19.
//

import SwiftUI
import SheetKit

struct TermsPage: View {
    var body: some View {
        VStack {
            HStack{
                Button(action: {
                    SheetKit().dismiss()
                }, label: {
                    Image("back").padding(.leading, 16)
                })
                Spacer()
            }
            ScrollView(showsIndicators: false){
                Text("""
    Please be sure to read these terms carefully.
    Use of the application
    1. You agree that we will use your information for the purposes required by laws and regulations.
    2. You agree that you shall not use our Application for illegal purposes.
    3. You agree that we may stop providing our products and services at any time without prior notice.
    4. By agreeing to download or install our software, you accept our Privacy Policy.
    Update
    We may update our privacy policy from time to time. When we make material changes to our policy, we will post a notice on our website along with the updated privacy policy.
    Contact us
    If you have any questions or concerns about our Privacy Policy or data processing, please contact us:yanglin12389@outlook.com
    """).foregroundColor(.black).font(.system(size: 14.0))
            }.padding(.all, 16)
        }
    }
}

struct TermsPage_Previews: PreviewProvider {
    static var previews: some View {
        TermsPage()
    }
}
