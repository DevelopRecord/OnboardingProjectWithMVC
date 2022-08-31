//
//  SearchViewCell.swift
//  PineoneTutorials
//
//  Created by LeeJaeHyeok on 2022/08/08.
//

import UIKit
import Kingfisher

class SearchViewCell: UICollectionViewCell {

    // MARK: - Properties

    /// SearchViewCell Identifier
    static let identifier = "SearchViewCell"
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

    private lazy var linkButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "safari"), for: .normal)
        $0.setTitleColor(.systemBlue, for: .normal)
        $0.addTarget(self, action: #selector(handleLink), for: .touchUpInside)
    }

    private lazy var imageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
    }

    let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.textAlignment = .center
    }

    let subtitleLabel = UILabel().then {
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
        priceLabel.text = newBooks.exchangeRateCurrencyKR
        isbn13Label.text = newBooks.isbn13
        subtitleLabel.text = newBooks.isEmptySubtitle
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
        contentView.backgroundColor = .systemBackground

        contentView.addSubviews(views: [infoImageView, infoTitleView])
        infoImageView.addSubviews(views: [imageView, linkButton])
        infoTitleView.addSubviews(views: [titleLabel, subtitleLabel, isbn13Label, priceLabel])

        infoImageView.snp.makeConstraints {
            $0.height.equalTo(150)
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        linkButton.snp.makeConstraints {
            $0.width.height.equalTo(32)
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }

        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.35)
            $0.top.bottom.equalToSuperview().inset(22)
        }

        infoTitleView.snp.makeConstraints {
            $0.top.equalTo(infoImageView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }

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

    @objc private func handleLink() {
        guard let url = URL(string: address) else { return }
        delegate?.presentSafari(url: url)
    }
}

class LoadingCell: UICollectionViewCell {

    // MARK: - Properties

    /// LoadingCell Identifier
    static let identifier = "LoadingCell"

    private lazy var activityIndicator = UIActivityIndicatorView()

    // MARK: - Helpers

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        contentView.backgroundColor = .secondarySystemBackground

        contentView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.width.height.equalTo(32)
            $0.center.equalToSuperview()
        }
    }

    /// Activity Indicator 시작 메서드
    func startAnimating() {
        activityIndicator.startAnimating()
    }
}
