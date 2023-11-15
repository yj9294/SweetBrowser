//
//  PrivacyPage.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/19.
//

import SwiftUI
import SheetKit

struct PrivacyPage: View {
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
    We provide you with this Privacy Policy to let you understand how we lawfully collect, organize and use your personal information, including private information you may provide to us or information we lawfully obtain from our products and services. Please rest assured that we take your privacy very seriously. Your privacy is important to us and we will fully protect your privacy

    Information Collection and Use

    - - Personal information refers to important data that can uniquely identify or contact an individual.

    - When you access, download, install or upgrade our applications or products, we will not privately collect, store or use any of your personal information, except for the necessary information you submit to us when sending a bug report.

    - We may only use the personal information you submit for the following purposes: to help us develop and upgrade our product content and services; to manage online surveys or other activities in which you participate.

    - We may disclose your personal information based on your wishes or legal requirements under the following circumstances:

    (1) With your prior permission

    (2) According to the laws and litigation requirements inside and outside your country of residence

    (3) At the request of public and governmental authorities

    (4) Safeguard our legitimate rights and interests.

    How we share information

    We may engage third party companies and individuals for the following reasons:

    Help us promote our applications;

    To provide service assistance policies on our behalf;

    Execute service content related to the service;

    Help us analyze how to make our services more responsive to our customers' needs.

    Update

    We may update and adjust the privacy policy from time to time. When we change the content of our policy, we will post a notice on the website to inform you and also mark the updated privacy policy content.

    Contact us

    If you have any questions or concerns about the content of our privacy policy or data processing, please contact us in time:yanglin12389@outlook.com


    Terms of use

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

struct PrivacyPage_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPage()
    }
}
