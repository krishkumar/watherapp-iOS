//
//  ImageLoader.swift
//  weatherapp
//
//  Created by Krishna Kumar on 5/17/23.
//

import UIKit

protocol ImageLoader {
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
}

class DefaultImageLoader: ImageLoader {
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(URLError(.badServerResponse)))
            }
        }.resume()
    }
}
