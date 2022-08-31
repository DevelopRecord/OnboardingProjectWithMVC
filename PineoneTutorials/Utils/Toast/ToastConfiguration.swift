//
//  ToastConfiguration.swift
//  PineoneTutorials
//
//  Created by 이재혁 on 2022/08/16.
//

import UIKit

public struct ToastConfiguration {
    public let autoHide: Bool
    public let enablePanToClose: Bool
    public let displayTime: TimeInterval
    public let animationTime: TimeInterval

    public let view: UIView?


    /// Toast 구성 객체 생성
    /// - 매개변수:
    ///     - autoHide: true로 설정할 시 설정 시간이 지나면 사라짐
    ///     - enablePanToClose: true로 설정할 시 위로 스와이프하여 토스트를 닫을 수 있음
    ///     - displayTime: autoHide가 true로 설정됐을 시 종료되기 전에 알람이 표시되는 시간
    ///     - animationTime: 애니메이션 지속시간
    ///     - attachTo: 토스트뷰가 첨부될 뷰

    public init (
        autoHide: Bool = true,
        enablePanToClose: Bool = true,
        displayTime: TimeInterval = 1.15,
        animationTime: TimeInterval = 0.2,
        attachTo view: UIView? = nil
    ) {
        self.autoHide = autoHide
        self.enablePanToClose = enablePanToClose
        self.displayTime = displayTime
        self.animationTime = animationTime
        self.view = view
    }
}
