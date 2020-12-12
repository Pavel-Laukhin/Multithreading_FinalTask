//
//  DataProvider.swift
//  Analog of Instagram
//
//  Created by Павел on 09.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

protocol DataProvider {
    
    var usersDataProvider: UsersDataProvider { get }
    var postsDataProvider: PostsDataProvider { get }
    var photoProvider: PhotosDataProvider { get }
    
    //TODO: результат поправить, нужен юзер, а не стринг
    /// Авторизует пользователя и выдает токен.
    func signIn(login: String, password: String, queue: DispatchQueue, completion: @escaping (Result<String, NetworkError>) -> Void)
    
    /// Деавторизует пользователя и инвалидирует токен.
    func signOut(queue: DispatchQueue)
    
}

enum NetworkError: Error {
    case badURLComponents(String)
    case noData(String)
    case noToken(String)
    case incorrectJSONString(String)
    case dataTaskError(String)
}

final class DataProviders: DataProvider {
    
    static let shared = DataProviders()
    
    private let scheme = "http"
    private let host = "localhost"
    private let port = 8080
    
    var usersDataProvider = UsersDataProvider()
    var postsDataProvider = PostsDataProvider()
    var photoProvider = PhotosDataProvider()
    
    private init() {}
    
    func signIn(login: String, password: String, queue: DispatchQueue, completion: @escaping (Result<String, NetworkError>) -> Void) {
        guard let result = getSignInRequest(login: login, password: password) else {
            completion(.failure(.badURLComponents("\(#function): Bad URLComponents!")))
            return
        }
        switch result {
        case .failure(let error):
            print(error)
            return
        case .success(let request):
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    print(#function, "http status code: \(httpResponse.statusCode)")
                }
                guard error == nil else {
                    completion(.failure(.dataTaskError("\(#function): Data task error: \(error!.localizedDescription)")))
                    return
                }
                guard let data = data else {
                    completion(.failure(.noData("\(#function): Can't fetch data in data task!")))
                    return
                }
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                      let token = json["token"] else {
                    completion(.failure(.noToken("\(#function): Failed to fetch a token in data task!")))
                    return
                }
                completion(.success(token))
            }.resume()
        }
    }
    
    private func getSignInRequest(login: String, password: String) -> Result<URLRequest, NetworkError>? {
        let urlComponents: URLComponents = {
            var urlComponents = URLComponents()
            urlComponents.scheme = scheme
            urlComponents.host = host
            urlComponents.port = port
            urlComponents.path = "/signin"
            return urlComponents
        }()
        guard let url = urlComponents.url else { return nil }
        print(url)
        var request = URLRequest(url: url.absoluteURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dictionary = ["login": login, "password": password]
        guard let json = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else { return .failure(.incorrectJSONString("Incorrect JSON string!")) }
        request.httpBody = json
        return .success(request)
    }
    
    func signOut(queue: DispatchQueue) {}
    
}

/// Защита от случайного клонирования
extension DataProviders: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
    
}
