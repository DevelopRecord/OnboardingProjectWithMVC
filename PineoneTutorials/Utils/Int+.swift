//
//  Int+.swift
//  PineoneTutorials
//
//  Created by LeeJaeHyeok on 2022/08/09.
//

import Foundation

extension Int {
    
    /// Int 타입을 String으로 타입 변환
    var intToString: String {
        return String(self)
    }
    
    /// 통화 formatter
    //    func currencyKR() -> String {
    //        let formatter = NumberFormatter()
    //        formatter.numberStyle = .currency // 숫자형식
    //        formatter.locale = Locale(identifier: "ko_KR") // 통화방식(KR)
    //        return formatter.string(from: NSNumber(value: self)) ?? ""
    //    }
}

