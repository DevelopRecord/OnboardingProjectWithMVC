//
//  APIService.swift
//  PineoneTutorials
//
//  Created by 이재혁 on 2022/08/08.
//

import Foundation

/// 앱과 서버간의 통신을 하며 마주칠 수 있는 다양한 에러
enum NetworkError: Error {
    /// 잘못된 URL
    case badUrl
    /// 데이터 없음
    case noData(message: String)
    /// 알수없는 에러
    case unknownErr(message: String)
    /// 404 에러
    case error404
    /// 데이터와 에러 반환
    case errorData
    /// 디코딩 에러
    case decodeError
}

/// 각 기능에 대한 URL 주소
enum URLAddress: String {
    /// 기본이 되는 URL
    case baseUrl = "https://api.itbook.store/1.0/"
    /// 모든 책 URL
    case newUrl = "new"
    /// /// 검색 URL
    case searchUrl = "search/"
    /// 책 세부정보 URL
    case detailUrl = "books/"
}

/*
protocol FetchRequestProtocol {
    func fetchNewBooks() -> Observable<BookResponse>
    func fetchSearchBooks() -> Observable<BookResponse>
    func fetchDetailBook() -> Observable<Book>
}
*/

class APIService: UIAnimatable /*FetchRequestProtocol*/ {

    static let shared = APIService() // 싱글톤

    // TODO: 함수명 뒤에 붙는 <T>는 어떤 의미인가
    // TODO: 이 함수를 이 클래스 밖에서 호출할 때 매개인자로 들어오는 result를 타입을 왜 맞춰줘야 하는가 -> T라서 타입이 불명확함.
    // TODO: 성공적으로 값이 넘어왔을 때 book을 반환해 주는데 as! T 형태로 강제 다운캐스팅을 한다. 만약 데이터 못받아오면 저기서 터질듯. 강제로 하는 방법 말고 어떻게 해야 할까 -> 그냥 함수 인자에 제네릭 안쓰면 됨.
    // TODO: 클로저(비동기로 처리할 데이터)가 있을 때는 [weak self]를 사용해야할 경우가 존재하는데 만약 한다면 여기서 weak self를 해야할까, 아니면 밖의 클래스에서 호출할때 해야할까 -> 탈출클로저라고 무조건 쓰는건 옳지 않다고 함. 근데 비동기로 처리하고

    /// 모든 책의 정보
    func fetchNewBooks(completion: @escaping(Result<BookResponse, NetworkError>) -> Void) {
        let urlString = URLAddress.baseUrl.rawValue + URLAddress.newUrl.rawValue
        guard let url = URL(string: urlString) else {
            return completion(.failure(.badUrl))
        }

        fetchRequest(url: url) { (result: Result<BookResponse, NetworkError>) in
            switch result {
            case .success(let bookResponse):
                completion(.success(bookResponse))
            case .failure(_):
                break
            }
        }
    }

    /*
    func fetchNewBooks() -> Observable<BookResponse> {
        return Observable<BookResponse>.create { observer in
            
            /// 첫번째 방식
            self.fetchRequest(url: url).subscribe { event in
                switch event {
                case .next(let response):
                    observer.onNext(response)
                case .error(let error):
                    observer.onError(error)
                case .completed():
                    observer.onCompleted()
                    break
                }
            }
            
            return Disposables.create()
            
            
            /// 두번째 방식
            self.fetchRequest(url: url) { result in
                switch result {
                case .success(let response):
                    observer.onNext(response)
                case .failure(let error):
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
     */

    /// 검색된 책의 정보
    func fetchSearchBooks(query: String, page: Int, completion: @escaping (Result<BookResponse, NetworkError>) -> Void) {
        let urlString = URLAddress.baseUrl.rawValue + URLAddress.searchUrl.rawValue + "\(query)/" + page.intToString
        guard let url = URL(string: urlString) else { return completion(.failure(.badUrl)) }

        fetchRequest(url: url) { (result: Result<BookResponse, NetworkError>) in
            switch result {
            case .success(let bookResponse):
                completion(.success(bookResponse))
            case .failure(_):
                break
            }
        }
    }

    /// 선택한 책의 정보
    func fetchDetailBook(isbn13: String, completion: @escaping (Result<Book, NetworkError>) -> Void) {
        let urlString = URLAddress.baseUrl.rawValue + URLAddress.detailUrl.rawValue + isbn13
        guard let url = URL(string: urlString) else {
            return completion(.failure(.badUrl))
        }

        fetchRequest(url: url) { (result: Result<Book, NetworkError>) in
            switch result {
            case .success(let book):
                completion(.success(book))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// 위의 서비스 함수에서 URLSession.shared.dataTask(..) 같은 로직 리팩토링 함수
    private func fetchRequest<T: Decodable>(url: URL, completion: @escaping (Result<T, NetworkError>) -> Void) {
        showLoadingAnimation()
        URLSession.shared.dataTask(with: url) { data, _, error in
            /// 데이터와 에러 동시에 들어왔을 때
            guard let data = data, error == nil else {
                return completion(.failure(.errorData)) }

            /// 데이터 없고 에러만 들어왔을 때
            if let error = error {
                return completion(.failure(.noData(message: "\(error)")))
            }

            self.hideLoadingAnimation()

            /// 디코딩 실패했을 때
            guard let bookDatas = try? JSONDecoder().decode(T.self, from: data) else {
                return completion(.failure(.decodeError)) }

            completion(.success(bookDatas))
        }.resume()
    }

    /*
    private func fetchRequest<T: Decodable>(url: URL) -> Observable<T> {
        showLoadingAnimation()
        return Observable.create { observer in
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = error, error == nil else {
                    observer.onError(NetworkError.errorData)
                    return
                }
                
                if let error = error {
                    observer.onError(NetworkError.noData(message: "\(error)"))
                }
                
                self.hideLoadingAnimation()
                
                guard let bookDatas = try? JSONDecoder().decode(T.self, from: data) else {
                    observer.onError(NetworkError.decodeError)
                    return
                }
                
                observer.onNext(bookDatas)
                observer.onCompleted()
                
            }.resume()
            
            return Disposables.create() {
                task?.cancel()
            }
        }
    }
    */
}
