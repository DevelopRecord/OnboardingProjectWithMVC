//
//  Substring+.swift
//  PineoneTutorials
//
//  Created by 이재혁 on 2022/08/10.
//

import Foundation

extension Substring {
    
    /// Substring 타입을 Int로 타입 변환
    var substringToInt: Int {
        return Int(self) ?? 0
    }
}
