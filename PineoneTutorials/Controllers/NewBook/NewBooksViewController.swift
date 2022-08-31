//
//  NewBooksViewController.swift
//  PineoneTutorials
//
//  Created by 이재혁 on 2022/08/08.
//

import UIKit
import SafariServices

class NewBooksViewController: UIViewController {

    // MARK: - Properties

    /// 모든 책 정보를 담는 프로퍼티
    private var books: BookResponse?
    /// 선택한 책의 정보를 담는 프로퍼티
    private var selectedBook: Book?

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.register(NewBooksCell.self, forCellWithReuseIdentifier: NewBooksCell.identifier)
    }

    private lazy var refreshControl = UIRefreshControl().then {
        $0.attributedTitle = NSAttributedString(string: R.NewBooksTextMessage.refreshMessage)
        $0.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchBooks()
        configureConstraints()
    }

    // MARK: - API
    /// 책의 리스트 가져오는 메서드
    private func fetchBooks() {
        APIService.shared.fetchNewBooks { [weak self] (result: Result<BookResponse, NetworkError>) in
            guard let `self` = self else { return }
            switch result {
            case .success(let response):
                self.books = response
                DispatchQueue.main.async {
                    UIView.transition(with: self.collectionView, duration: 0.5, options: .transitionCrossDissolve) {
                        self.collectionView.reloadData()
                    }
                }
            case .failure(let error):
                print("ERROR: \(error.localizedDescription)")
                self.showToast(message: R.NewBooksTextMessage.failListMessage)
            }
        }
    }

    /// 선택한 책의 상세정보를 가져오는 메서드
    private func fetchDetailBook() {
        guard let selectedBook = selectedBook else { return }
        APIService.shared.fetchDetailBook(isbn13: selectedBook.isbn13) { [weak self] (result: Result<Book, NetworkError>) in
            guard let `self` = self else { return }
            switch result {
            case .success(let response):
                self.selectedBook = response
            case .failure(let error):
                print("ERROR: \(error.localizedDescription)")
                self.showToast(message: R.DetailBookTextMessage.failDetailMessage)
            }
        }
    }

    // MARK: - Helpers

    private func configureConstraints() {
        view.backgroundColor = .systemBackground
        setupNavigationBar(title: R.NewBooksTextMessage.newBooks, isLargeTitle: true)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        collectionView.addSubview(refreshControl)
    }

    // MARK: - Selectors

    /// 새로고침 하고 책 리스트들을 가져오는 액션
    @objc private func handleRefresh() {
        fetchBooks()
        refreshControl.endRefreshing()
    }
}

extension NewBooksViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(self.books?.total ?? "") ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewBooksCell.identifier, for: indexPath) as? NewBooksCell ?? NewBooksCell()
        cell.delegate = self
        guard let book = books?.books[indexPath.row] else { return UICollectionViewCell() }
        cell.setupRequest(with: book)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let book = books?.books[indexPath.row] else { return }
        selectedBook = book
        fetchDetailBook()
        let controller = DetailBookController()
        controller.hidesBottomBarWhenPushed = true
        controller.setupRequest(with: book)
        navigationController?.pushViewController(controller, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 265)
    }
}

extension NewBooksViewController: NewBooksCellDelegate {
    func presentSafari(url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }
}
