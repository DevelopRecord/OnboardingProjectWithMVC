//
//  ToastView.swift
//  PineoneTutorials
//
//  Created by 이재혁 on 2022/08/16.
//

import UIKit

public protocol ToastView: UIView {
    func createView(for toast: Toast)
}
