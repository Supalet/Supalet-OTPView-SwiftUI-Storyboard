//
//  ContentView.swift
//  OTPProject
//
//  Created by Supalert Kamolsin on 16/9/2567 BE.
//

import SwiftUI

struct ContentView: View {
	@State var otp: String = ""
	
    var body: some View {
        ZStack {
			Color.white.ignoresSafeArea(.all)
			
			VStack(spacing: 20) {
				Text("OTP")
				
				OTPTextView(valueOtp: $otp)
					.frame(height: 60)
					.padding(.horizontal, 50)
				
				Button {
					print(otp)
				} label: {
					Text("Print OTP")
						.bold()
				}
				
				Button {
					NotificationCenter.default.post(name: Notification.Name(rawValue: "ClearOTP"), object: nil)
				} label: {
					Text("Clear")
						.bold()
				}

			}
        }
    }
}

//#Preview {
//    ContentView()
//}
