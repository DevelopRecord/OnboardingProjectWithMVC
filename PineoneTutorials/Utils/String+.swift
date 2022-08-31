//
//  String+.swift
//  PineoneTutorials
//
//  Created by 이재혁 on 2022/08/10.
//

import Foundation

extension String {
    
    /// String -> Int, Default value is 0
    var stringToInt: Int {
        return Int(self) ?? 0
    }
}
