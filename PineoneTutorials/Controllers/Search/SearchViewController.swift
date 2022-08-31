//
//  SearchViewController.swift
//  PineoneTutorials
//
//  Created by 이재혁 on 2022/08/08.
//

import UIKit
import SafariServices

private enum Mode {
    /// 검색하지 않은 최초 상태거나, 검색 도중 검색어를 삭제했을 떄
    case onboarding
    /// 검색모드
    case search
}

class SearchViewController: UIViewController {

    // MARK: - Properties

    /// 모든 책의 정보를 담는 프로퍼티
    private var newBooks: BookResponse?
    /// 검색한 책의 정보를 담는 프로퍼티
    private var searchBooks: BookResponse?
    /// 선택한 책의 정보를 담는 프로퍼티
    private var selectedBook: Book?

    /// 검색모드인지 아닌지 상태 정보를 담는 프로퍼티
    private var mode: Mode = .onboarding {
        didSet {
            observeForm()
        }
    }

    /// 검색어 저장 프로퍼티
    private var searchQuery: String = ""
    /// 검색하고 더보기하고 이후에 나오는 데이터 저장 프로퍼티
    private var searchForMore: [Book] = []
    /// 검색할때 검색결과의 페이지 번호 프로퍼티
    private var page: Int = 1
    /// 마지막 데이터의 페이지 번호 프로퍼티
    private var endPage: Int = 0
    /// 무한 스크롤 방지하기 위한 프로퍼티
    private var isAvailable: Bool = true

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.keyboardDismissMode = .onDrag
        $0.delegate = self
        $0.dataSource = self
        $0.register(SearchViewCell.self, forCellWithReuseIdentifier: SearchViewCell.identifier)
        $0.register(SearchResultsCell.self, forCellWithReuseIdentifier: SearchResultsCell.identifier)
        $0.register(LoadingCell.self, forCellWithReuseIdentifier: LoadingCell.identifier)
    }

    /// 검색할때 사용하는 서치 컨트롤러
    private lazy var searchController = UISearchController(searchResultsController: nil).then {
        $0.searchBar.placeholder = R.SearchViewTextMessage.enterSearchQuery
        $0.obscuresBackgroundDuringPresentation = false
        $0.searchResultsUpdater = self
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureConstraints()
        fetchNewBooks()
    }

    // MARK: - API

    /// New Books 데이터들을 가져오는 메서드
    private func fetchNewBooks() {
        APIService.shared.fetchNewBooks { [weak self] (result: Result<BookResponse, NetworkError>) in
            guard let `self` = self else { return }
            switch result {
            case .success(let response):
                self.newBooks = response
                DispatchQueue.main.async {
                    UIView.transition(with: self.collectionView, duration: 0.5, options: .transitionCrossDissolve) {
//                        self.collectionView.backgroundView = nil
                        self.collectionView.reloadData()
                    }
                }
            case .failure(let error):
                print("ERROR: \(error)")
                self.showToast(message: R.SearchViewTextMessage.failListMessage)
            }
        }
    }

    /// 검색 결과의 데이터들을 가져오는 메서드
    private func fetchSearchBooks() {
        APIService.shared.fetchSearchBooks(query: searchQuery, page: page) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let response):
                if self.page == 1 {
                    self.searchBooks = response
                    self.endPage = self.divideAndCeil(self.searchBooks!.total, 10)
                } else if self.page > 1 {
                    self.searchBooks?.books.append(contentsOf: response.books)
                }
                self.isAvailable = true

                DispatchQueue.main.async {
                    UIView.transition(with: self.collectionView, duration: 0.15, options: .transitionCrossDissolve) {
                        self.collectionView.reloadData()
                    }
                }
            case .failure(let error):
                print("ERROR: \(error.localizedDescription)")
                self.showToast(message: R.SearchViewTextMessage.noSearchRequestMessage)
            }
        }
    }

    /// 선택한 책의 상세 정보를 가져오는 메서드
    private func fetchDetailBook() {
        guard let selectedBook = selectedBook else { return }

        APIService.shared.fetchDetailBook(isbn13: selectedBook.isbn13) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let response):
                self.selectedBook = response
            case .failure(let error):
                print("ERROR: \(error.localizedDescription)")
                self.showToast(message: R.SearchViewTextMessage.failDetailMessage)
            }
        }
    }

    // MARK: - Helpers

    private func configureConstraints() {
        view.backgroundColor = .systemBackground
        setupNavigationBar(title: R.SearchViewTextMessage.searchBooks, isLargeTitle: true, searchController: searchController)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    /// 현재 검색모드인지 아닌지 상태를 관찰하기 위한 메서드
    private func observeForm() {
        switch mode {
        case .onboarding:
            /// onboarding이면 검색을 하지 않았다고 간주하여 backgroundView() 삽입
            if !searchController.isActive || searchBooks?.books.count == 0 {
//                self.collectionView.backgroundView = SearchPlaceholderView()
            }
        case .search:
            /// search이면 검색중이라 간주하여 backgroundView = nil
            if searchQuery.count < 2 {
                self.collectionView.backgroundView = nil
            }
        }
        
        if mode == .search && searchQuery.isEmpty && searchQuery.count < 2 {
            self.collectionView.backgroundView = SearchPlaceholderView()
        } else if mode == .search || searchQuery.count > 1 || !searchQuery.isEmpty {
            self.collectionView.backgroundView = nil
        }
    }

    /// endPage를 구하기 위한 메서드
    func divideAndCeil(_ a: String, _ b: Int) -> Int {
        let divideCeil = ceil(Double(a)! / Double(b)).doubleToInt
        return divideCeil
    }
}

extension SearchViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > (contentHeight - height) {
            if !searchQuery.isEmpty && searchBooks?.books.count != 0 {
                if isAvailable {
                    isAvailable = false
                    page += 1
                    fetchSearchBooks()
                    searchBooks?.books.append(contentsOf: searchForMore)
                }
            }
        }
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            if mode == .onboarding {
                return newBooks?.books.count ?? 0
            } else {
                return searchBooks?.books.count ?? 0
            }
        } else if section == 1 {
            if page < endPage {
                return 1
            } else if page >= endPage {
                return 0
            }
        }

        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if mode == .onboarding {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchViewCell.identifier, for: indexPath) as? SearchViewCell ?? SearchViewCell()
                cell.delegate = self
                guard let book = newBooks?.books[indexPath.row] else { return UICollectionViewCell() }
                cell.setupRequest(with: book)
                return cell
            } else if mode == .search {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultsCell.identifier, for: indexPath) as? SearchResultsCell ?? SearchResultsCell()
                guard let book = searchBooks?.books[indexPath.row] else { return UICollectionViewCell() }
                cell.setupRequest(with: book)
                return cell
            }
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCell.identifier, for: indexPath) as? LoadingCell ?? LoadingCell()
            cell.startAnimating()
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if mode == .onboarding {
                guard let book = newBooks?.books[indexPath.row] else { return }
                selectedBook = book
                fetchDetailBook()
                let controller = DetailBookController()
                controller.setupRequest(with: book)
                navigationController?.pushViewController(controller, animated: true)
            } else if mode == .search {
                guard let selectedBook = searchBooks?.books[indexPath.row] else { return }
                self.selectedBook = selectedBook
                fetchDetailBook()
                let controller = DetailBookController()
                controller.hidesBottomBarWhenPushed = true
                controller.setupRequest(with: selectedBook)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let result = mode == .onboarding ? CGSize(width: view.frame.width, height: 255) : CGSize(width: view.frame.width, height: 160)
            return result
        } else {
            return CGSize(width: view.frame.width, height: 75)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
}

extension SearchViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            mode = .search
            guard let searchQuery = searchController.searchBar.text else { return }
            self.searchQuery = searchQuery
            fetchSearchBooks()
            self.collectionView.reloadData()
        } else if !searchController.isActive {
            mode = .onboarding
            self.collectionView.backgroundView = nil
            self.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            resetProperties()

            self.collectionView.reloadData()
        }
    }
    
    private func resetProperties() {
        /// searchBooks - 검색하고 더보기 중 취소했을 때 searchBooks에 있는 데이터 비움
        self.searchBooks = BookResponse(error: "0", total: "0", page: nil, books: [])
        /// endPage - 검색하고 더보기 중 취소했을 때 endPage 초기값 0
        self.endPage = 0
        /// page - 검색하고 더보기 중 취소했을 때 page 초기값 1
        self.page = 1
    }

    func willPresentSearchController(_ searchController: UISearchController) {
        mode = .search
    }
}

extension SearchViewController: NewBooksCellDelegate {
    func presentSafari(url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }
}
