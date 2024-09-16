//
//  OTPView.swift
//  OTPProject
//
//  Created by Supalert Kamolsin on 16/9/2567 BE.
//

import SwiftUI
import UIKit

struct OTPTextView: UIViewRepresentable {
	@Binding var valueOtp: String
	
	func makeCoordinator() -> OTPTextViewCordinator {
		OTPTextViewCordinator(otp: $valueOtp)
	}
	
	func makeUIView(context: Context) -> OTPView {
		if let nib = Bundle.main.loadNibNamed("OTPView", owner: self),
		   let nibView = nib.first as? OTPView {
			nibView.setupAwake()
			nibView.delegate = context.coordinator
			return nibView
		} else {
			return OTPView()
		}
	}

	func updateUIView(_ uiView: OTPView, context: Context) {
	}
}

class OTPTextViewCordinator: NSObject, OTPViewDelegate {
	@Binding var otp: String
	
	init(otp: Binding<String>) {
		_otp = otp
	}
	
	func onChangeOTP(otp: String) {
		self.otp = otp
	}
}

protocol OTPViewDelegate {
	func onChangeOTP(otp: String)
}

struct ConfigOTPView {
	var countMemberView: Int = 6
	var spaceOTPView: CGFloat = 8
	
	var cardBackgroundColor: UIColor = UIColor.clear
	var cardCornerRadius: CGFloat = 12
	var boarderWidthInActive: CGFloat = 1
	var boarderColorInActive: UIColor = UIColor.gray
	var boarderWidthActive: CGFloat = 1
	var boarderColorActive: UIColor = UIColor.systemPink
	
	var textColor: UIColor = UIColor.black
	var textFont: UIFont = UIFont.systemFont(ofSize: 20, weight: .bold)
	
	var isHideIndicator: Bool = false
	var indicatorColor: UIColor = UIColor.black
	var indicatorFrequency: TimeInterval = 0.5
}

class OTPView: UIView {
	@IBOutlet weak var otpTextField: UITextField!
	
	@IBOutlet weak var otpStackView: UIStackView!
	@IBOutlet var cardView: [UIView]!
	@IBOutlet var textLabel: [UILabel]!
	@IBOutlet var indicatorView: [UIView]!
	
	var delegate: OTPViewDelegate?
	var timer: Timer? = nil
	var config: ConfigOTPView = ConfigOTPView()
	
	override class func awakeFromNib() {
		super.awakeFromNib()
	}
}

// MARK: - Setup
extension OTPView {
	public func setupAwake() {
		setup()
	}
	
	func setup() {
		setupTimer()
		setupView()
		setupNotificationCenter()
	}
	
	func setupView() {
		otpTextField.delegate = self
		otpTextField.keyboardType = .numberPad
		
		otpStackView.spacing = config.spaceOTPView
		
		for (index, card) in cardView.enumerated() {
			card.backgroundColor = config.cardBackgroundColor
			card.layer.cornerRadius = config.cardCornerRadius
			card.layer.borderWidth = config.boarderWidthInActive
			card.layer.borderColor = config.boarderColorInActive.cgColor
			
			if index > config.countMemberView - 1 {
				cardView[index].isHidden = true
			}
		}
		
		for indicator in indicatorView {
			indicator.layer.cornerRadius = 1
			indicator.backgroundColor = config.indicatorColor
			indicator.isHidden = true
		}
		
		for text in textLabel {
			text.text = ""
			text.textColor = config.textColor
			text.font = config.textFont
		}
	}
	
	func setupTimer() {
		if timer == nil {
			timer = Timer.scheduledTimer(
				timeInterval: config.indicatorFrequency,
				target: self,
				selector: #selector(updateIndicatorView),
				userInfo: nil,
				repeats: true
			)
		}
	}
	
	@objc func updateIndicatorView() {
		for indicator in indicatorView {
			indicator.alpha = indicator.alpha == 0 ? 1 : 0
		}
	}
	
	func setupNotificationCenter() {
		NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "ClearOTP"), object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.clearOTP(notification:)),
			name: Notification.Name(rawValue: "ClearOTP"),
			object: nil
		)
	}
	
	@objc func clearOTP(notification: Notification) {
		otpTextField.text = ""
		delegate?.onChangeOTP(otp: "")
		self.endEditing(true)
		updatePin()
	}
}

// MARK: - Update UI
extension OTPView {
	func updatePin() {
		if otpTextField.text?.count ?? 0 >= config.countMemberView {
			self.endEditing(true)
		}
		
		let listChar = Array(otpTextField.text ?? "")
		
		for (index, _) in cardView.enumerated() {
			cardView[index].layer.borderColor = ((otpTextField.text?.count ?? 0) - 1) >= index ? config.boarderColorActive.cgColor : config.boarderColorInActive.cgColor
			textLabel[index].text = ((otpTextField.text?.count ?? 0) - 1) >= index ? String(listChar[index]) : ""
		}
	}
	
	func setupShowIndicator() {
		for indicator in indicatorView {
			indicator.isHidden = true
		}
		
		if !config.isHideIndicator {
			if (otpTextField.text?.count ?? 0) < config.countMemberView {
				indicatorView[(otpTextField.text?.count ?? 0)].isHidden = false
			}
		}
	}
}

// MARK: - Action
extension OTPView {
	@IBAction func onTouchFocusButton(_ sender: Any) {
		otpTextField.becomeFirstResponder()
	}
}

// MARK: - UITextField
extension OTPView: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		setupShowIndicator()
	}
	
	func textFieldDidChangeSelection(_ textField: UITextField) {
		delegate?.onChangeOTP(otp: textField.text ?? "")
		updatePin()
		setupShowIndicator()
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let stringAfter = string.cString(using: String.Encoding.utf8)
		
		if textField.text?.count ?? 0 >= config.countMemberView && strcmp(stringAfter, "\\b") != -92 {
			return false
		}
		
		if string.count > 1  {
			let word = otpTextField.text ?? ""
			otpTextField.text = String(word.suffix(config.countMemberView))
		}
		
		return true
	}
}
