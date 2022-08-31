//
//  SearchResultsCell.swift
//  PineoneTutorials
//
//  Created by LeeJaeHyeok on 2022/08/09.
//

import UIKit

class SearchResultsCell: UICollectionViewCell {

    // MARK: - Properties

    /// SearchResultsCell Identifier
    static let identifier = "SearchResultsCell"

    private lazy var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }

    private lazy var stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, isbn13Label, priceLabel, urlLabel]).then {
        $0.backgroundColor = .clear
        $0.axis = .vertical
    }

    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.text = "TITLE LABEL"
    }

    private let subtitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.text = "SUBTITLE LABEL"
    }

    private let isbn13Label = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.text = "ISBN13 LABEL"
    }

    private let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.text = "PRICE LABEL"
    }

    private let urlLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.lineBreakMode = .byTruncatingMiddle
        $0.textColor = .systemBlue
        $0.text = "http://www.naver.com"
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    /// 데이터 셋업 메서드
    func setupRequest(with newBooks: Book) {
        imageView.kf.setImage(with: URL(string: newBooks.image))
        titleLabel.text = newBooks.title
        subtitleLabel.text = newBooks.isEmptySubtitle
        priceLabel.text = newBooks.exchangeRateCurrencyKR
        isbn13Label.text = newBooks.isbn13
        urlLabel.text = newBooks.url
    }

    private func configureConstraints() {
        contentView.backgroundColor = .secondarySystemBackground

        contentView.addSubviews(views: [imageView, stackView])
        imageView.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.top.leading.bottom.equalToSuperview().inset(20)
        }

        stackView.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview().inset(20)
            $0.leading.equalTo(imageView.snp.trailing).offset(20)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }

        isbn13Label.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }

        priceLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }

        urlLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
    }
}
