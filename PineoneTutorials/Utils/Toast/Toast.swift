//
//  Toast.swift
//  PineoneTutorials
//
//  Created by 이재혁 on 2022/08/16.
//

import UIKit

public class Toast {
    private var closeTimer: Timer?

    /// panGesture를 닫기 위함
    private var startY: CGFloat = 0
    private var startShiftY: CGFloat = 0

    public static var defaultImageTint: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }

    public let view: ToastView

    private let config: ToastConfiguration

    private var initialTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 0.9, y: 0.9).translatedBy(x: 0, y: -100)
    }

    /// 제목과 옵셔널의 subtitle이 있는 토스트 메시지
    /// - Parameters:
    ///   - title: 토스트에 표시되는 제목
    ///   - subtitle: 토스트에 표시되는 옵셔널 부제목
    ///   - config: 구성 옵션(autoHide, animation 등)
    /// - Returns: 위 구성으로 만들어진 토스트 메시지
    public static func text(
        _ title: String,
        subtitle: String? = nil,
        config: ToastConfiguration = ToastConfiguration()
    ) -> Toast {
        let view = AppleTextToastView(child: TextToastView(title, subtitle: subtitle))
        return self.init(view: view, config: config)
    }

    /// 커스텀 토스트 메시지
    /// - Parameters:
    ///   - view: 토스트가 표시될때 표시되는 뷰
    ///   - config: 구성 옵션(autoHide, animation 등)
    /// - Returns: 위 구성으로 만들어진 토스트 메시지
    public required init(view: ToastView, config: ToastConfiguration) {
        self.config = config
        self.view = view

        view.transform = initialTransform
        if config.enablePanToClose {
            enablePanToClose()
        }
    }

    /// Show the toast
    /// - Parameter delay: Time after which the toast is shown
    public func show(after delay: TimeInterval = 0) {
        config.view?.addSubview(view) ?? topController()?.view.addSubview(view)
        view.createView(for: self)

        UIView.animate(withDuration: config.animationTime, delay: delay, options: [.allowUserInteraction]) {
            self.view.transform = .identity
        } completion: { [self] _ in
            closeTimer = Timer.scheduledTimer(withTimeInterval: .init(config.displayTime), repeats: false) { [self] _ in
                if config.autoHide {
                    close()
                }
            }
        }
    }

    /// 토스트 메시지 닫기(위 show()함수에서 사용해야 하기때문에 필요함)
    /// - Parameters:
    ///   - completion: A completion handler which is invoked after the toast is hidden
    public func close(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: config.animationTime,
            delay: 0,
            options: [.curveEaseIn, .allowUserInteraction],
            animations: {
                self.view.transform = self.initialTransform
            }, completion: { _ in
                self.view.removeFromSuperview()
                completion?()
            })
    }

    private func topController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Toast {
    private func enablePanToClose() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(toastOnPan))
        self.view.addGestureRecognizer(pan)
    }

    @objc private func toastOnPan(_ gesture: UIPanGestureRecognizer) {
        guard let topVc = topController() else {
            return
        }

        switch gesture.state {
        case .began:
            startY = self.view.frame.origin.y
            startShiftY = gesture.location(in: topVc.view).y
            closeTimer?.invalidate() // prevent timer to fire close action while being touched
        case .changed:
            let delta = gesture.location(in: topVc.view).y - startShiftY
            if delta <= 0 {
                self.view.frame.origin.y = startY + delta
            }
        case .ended:
            let threshold = initialTransform.ty + (startY - initialTransform.ty) * 2 / 3

            if self.view.frame.origin.y < threshold {
                close()
            } else {
                // move back to origin position
                UIView.animate(withDuration: config.animationTime, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
                    self.view.frame.origin.y = self.startY
                } completion: { [self] _ in
                    closeTimer = Timer.scheduledTimer(withTimeInterval: .init(config.displayTime), repeats: false) { [self] _ in
                        if config.autoHide {
                            close()
                        }
                    }
                }
            }
        default:
            break
        }
    }
}
