//
//  DetailBookController.swift
//  PineoneTutorials
//
//  Created by 이재혁 on 2022/08/09.
//

import UIKit

class DetailBookController: UIViewController {

    // MARK: - Properties

    /// UserDefaults Key값 저장 프로퍼티
    private var isbn13: String = ""

    /// textView의 text 값 저장 여부 프로퍼티
    private var isTextViewEdited: Bool = true

    /// UserDefaults 싱글톤
    private let userDefaults = UserDefaults.standard

    /// 저장할 Text
    private var userDefaultsText: String?

    // MARK: - View
    private lazy var scrollView = UIScrollView().then {
        $0.backgroundColor = .clear
        $0.delegate = self
    }

    private let contentView = UIView().then {
        $0.backgroundColor = .clear
    }

    private lazy var infoImageView = UIView().then {
        $0.backgroundColor = .secondarySystemBackground
    }

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }

    private lazy var stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, isbn13Label, priceLabel, urlView]).then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .leading
    }

    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
    }

    private let subtitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
    }

    private let isbn13Label = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
    }

    private let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
    }

    private lazy var urlView = UIView().then {
        $0.backgroundColor = .clear
        $0.setHeight(50)
    }

    private let urlLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textColor = .systemBlue
    }

    private let divideView = UIView().then {
        $0.backgroundColor = .systemGray
    }

    private lazy var textView = UITextView().then {
        $0.text = R.DetailBookTextMessage.enterMemo
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.isScrollEnabled = false
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray2.cgColor
        $0.delegate = self
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureConstraints()
        configureNotificationCenter()
        dismissKeyboardWhenTappedAround()
        fetchUserDefaultText()
    }

    // MARK: - Helpers

    /// 데이터 셋업 메서드
    func setupRequest(with book: Book) {
        let url = URL(string: book.image)
        isbn13 = book.isbn13

        imageView.kf.setImage(with: url)
        titleLabel.text = book.title
        subtitleLabel.text = book.isEmptySubtitle
        isbn13Label.text = book.isbn13
        priceLabel.text = book.exchangeRateCurrencyKR
        urlLabel.text = book.url
    }

    private func configureConstraints() {
        view.backgroundColor = .systemBackground
        setupNavigationBar(title: R.DetailBookTextMessage.detailBooks, isLargeTitle: true)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(views: [infoImageView, stackView, divideView, textView])
        urlView.addSubview(urlLabel)

        infoImageView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(160)
            $0.top.leading.trailing.equalToSuperview()
        }

        infoImageView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(140)
            $0.top.bottom.equalToSuperview().inset(8)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(infoImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        urlLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }

        divideView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(urlView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        textView.snp.makeConstraints {
            $0.height.equalTo(200)
            $0.top.equalTo(divideView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        contentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.top.bottom.equalToSuperview()
            /// contentView의 높이값을 스크롤뷰보다 1더 크게해야 스크롤가능하기 때문에 우선순위를 high로 잡는다.
            /// contentView가 우선순위에 밀려 작아져버려 스크롤이 불가능한 상황이 발생할지는 모르겠으나 안전하게 하기 위함.
            $0.height.greaterThanOrEqualTo(scrollView.snp.height).offset(1).priority(.high)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func fetchUserDefaultText() {
        let defaultText = userDefaults.string(forKey: isbn13)

//        if defaultText != nil {
//            textView.text = userDefaults.string(forKey: isbn13)
//            textView.textColor = .label
//        } else if defaultText == nil {
//            textView.text = R.DetailBookTextMessage.enterMemo
//            textView.textColor = .lightGray
//        }
        
        textView.text = defaultText == nil ? R.DetailBookTextMessage.enterMemo : defaultText
        textView.textColor = defaultText == nil ? .lightGray : .label
    }

    private func configureNotificationCenter() {
        let notification = NotificationCenter.default // 싱글톤 패턴. 사용 시점에 초기화해서 메모리 관리

        notification.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Selectors

    @objc func keyboardWillShow(notification: NSNotification) {
        navigationController?.navigationBar.prefersLargeTitles = false

        /// Keyboard의 사이즈
        guard var keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        keyboardSize = view.convert(keyboardSize, from: nil)

        if UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.safeAreaInsets.bottom ?? 0 > 0 {
            keyboardSize.size.height = keyboardSize.size.height / 2
        }

        /// contentInset은 안전영역 안에서 표시된다. 즉, 뷰들이 safeArea 영역 내에서 표시됨
        var contentInset: UIEdgeInsets = scrollView.contentInset

        contentInset.bottom = keyboardSize.size.height
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset

        scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom), animated: true)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        navigationController?.navigationBar.prefersLargeTitles = true

        // TODO: scrollView의 setContentOffset을 아래처럼 잡지 말고, scrollIndicatorInsets를 .zero로 잡아야 키보드가 dismiss 됐을 때, 스크롤바가 정상적으로 표시됨.
        // TODO: setContentOffset을 아래와 같이 주면 오른쪽 스크롤바가 정상적으로 표시되지 않는 문제 있음.

//        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero

        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

extension DetailBookController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        userDefaultsText = text
    }

    func textViewDidBeginEditing(_ textView: UITextView) { // 사용자가 편집을 시작할때
        /*
         textView의 textColor가 lightGray면 아직 글이 작성되지 않은
         즉, 최초로 입력하려는 때니까 textView의 text값을 nil, textColor를 black
         */

        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black

            if textView.text != R.DetailBookTextMessage.enterMemo {
                isTextViewEdited = true
            }
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) { // 사용자가 입력을 종료했을때
        /*
         만약 편집을 하려 textView를 탭했는데 사용자가 아무것도 입력하지 않고 입력을 종료했을 경우도 존재한다고 생각함.
         그래서 textView의 text가 isEmpty이면 다시 "메모를 입력해보세요."와 textColor은 lightGray
         */
        userDefaults.set(userDefaultsText, forKey: isbn13)

        if textView.text.isEmpty {
            textView.text = R.DetailBookTextMessage.enterMemo
            textView.textColor = .lightGray
            isTextViewEdited = false
        }
    }
}
