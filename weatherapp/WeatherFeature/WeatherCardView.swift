//
//  WeatherCardView.swift
//  weatherapp
//
//  Created by Krishna Kumar on 5/17/23.
//

import UIKit

class WeatherCardView: UIView {
    struct Content {
        let cityName: String
        let temperatureText: String
        let descriptionText: String
        let icon: String
    }

    let cityNameLabel = UILabel()
    let temperatureLabel = UILabel()
    let descriptionLabel = UILabel()
    let weatherIconImageView = UIImageView()
    let imageLoader: ImageLoader

    init(frame: CGRect = .zero, imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        cityNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        cityNameLabel.textColor = .label
        temperatureLabel.font = UIFont.systemFont(ofSize: 20)
        temperatureLabel.textColor = .label
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .label
        backgroundColor = .systemBackground

        let stackView = UIStackView(arrangedSubviews: [cityNameLabel, weatherIconImageView, temperatureLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
        ])
    }

    func populate(content: Content) {
        cityNameLabel.text = content.cityName
        temperatureLabel.text = content.temperatureText
        descriptionLabel.text = content.descriptionText
        loadWeatherIcon(icon: content.icon)
    }

    func clearContent() {
        cityNameLabel.text = ""
        temperatureLabel.text = ""
        descriptionLabel.text = ""
        weatherIconImageView.image = nil
    }

    private func loadWeatherIcon(icon: String) {
        let iconURL = "https://openweathermap.org/img/wn/\(icon)@2x.png"
        guard let url = URL(string: iconURL) else { return }

        imageLoader.loadImage(from: url) { result in
            switch result {
            case let .success(image):
                DispatchQueue.main.async {
                    self.weatherIconImageView.image = image
                }
            case let .failure(error):
                print("Error loading image: \(error)")
            }
        }
    }
}
