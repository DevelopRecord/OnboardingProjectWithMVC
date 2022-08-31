//
//  NewBooksCell.swift
//  PineoneTutorials
//
//  Created by LeeJaeHyeok on 2022/08/08.
//

import UIKit

import Kingfisher
import SnapKit
import Then

protocol NewBooksCellDelegate: AnyObject {
    /// Safari Controller로 이동하기 위한 델리게이트 메서드
    func presentSafari(url: URL)
}

class NewBooksCell: UICollectionViewCell {

    // MARK: - Properties

    /// NewBooksCell Identifier
    static let identifier = "NewBooksCell"
    /// NewBooksCellDelegate 프로퍼티
    weak var delegate: NewBooksCellDelegate?
    /// Safari로 이동하기 위해 URL String 타입 주소를 담는 프로퍼티
    private var address: String = ""

    private lazy var infoImageView = UIView().then {
        $0.backgroundColor = .systemGray5
    }

    private lazy var infoTitleView = UIView().then {
        $0.backgroundColor = .systemGray4
    }

    // TODO: let 으로 선언하면 addTarget이 작동하지 않음. lazy var로 하니 동작함 왜그런가? -> 프로퍼티가 생성되고 나서 addTarget값이 설정됨
    private lazy var linkButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "safari"), for: .normal)
        $0.setTitleColor(.systemBlue, for: .normal)
        $0.addTarget(self, action: #selector(handleLink), for: .touchUpInside)
    }

    private lazy var imageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
    }

    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.textAlignment = .center
    }

    private let subtitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textAlignment = .center
    }

    private let isbn13Label = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textAlignment = .center
    }

    private let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textAlignment = .center
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    /// 데이터 셋업 메서드
    func setupRequest(with newBooks: Book) {
        address = newBooks.url
        imageView.kf.setImage(with: URL(string: newBooks.image))
        titleLabel.text = newBooks.title
        subtitleLabel.text = newBooks.isEmptySubtitle
        priceLabel.text = newBooks.exchangeRateCurrencyKR
        isbn13Label.text = newBooks.isbn13
    }

    private func configureUI() {
        infoImageView.layer.cornerRadius = 10
        infoImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        infoImageView.layer.masksToBounds = true

        infoTitleView.layer.cornerRadius = 10
        infoTitleView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        infoTitleView.layer.masksToBounds = true
    }

    private func configureConstraints() {
        contentView.addSubviews(views: [infoImageView, infoTitleView])
        infoImageView.addSubviews(views: [imageView, linkButton])

        infoImageView.snp.makeConstraints {
            $0.height.equalTo(150)
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.35)
            $0.top.bottom.equalToSuperview().inset(22)
        }

        linkButton.snp.makeConstraints {
            $0.width.height.equalTo(32)
            $0.top.trailing.equalToSuperview().inset(10)
        }

        infoTitleView.snp.makeConstraints {
            $0.top.equalTo(infoImageView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-10)
        }

        infoTitleView.addSubviews(views: [titleLabel, subtitleLabel, isbn13Label, priceLabel])
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(4)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        isbn13Label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        priceLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(isbn13Label.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

    // MARK: - Selectors
    /// 사파리 이동 버튼 액션 함수
    @objc private func handleLink() {
        guard let url = URL(string: address) else { return }
        delegate?.presentSafari(url: url)
    }
}
