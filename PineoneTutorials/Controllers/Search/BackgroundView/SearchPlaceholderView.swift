//
//  SearchPlaceholderView.swift
//  PineoneTutorials
//
//  Created by LeeJaeHyeok on 2022/08/09.
//

import UIKit

// TODO: 검색화면의 backgroundView를 코드베이스로 작성함. 검색을 좀 더 해봐야 할듯
/// SearchViewController의 BackgroundView
class SearchPlaceholderView: UIView {

    // MARK: - Properties

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")?.withTintColor(.systemBlue)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "관심있는 책 제목을 검색해 보세요."
        label.textColor = .systemBlue
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    private func configureUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.equalTo(88)
            $0.center.equalToSuperview()
        }
    }
}
