//
//  WeatherView.swift
//  archapp
//
//  Created by Krishna Kumar on 5/15/23.
//

import SwiftUI
import UIKit

protocol WeatherViewDelegate: AnyObject {
    func weatherView(_ weatherView: WeatherView, showAlertWithTitle title: String, message: String)
    func getWeatherFor(_ city: String)
}

class WeatherView: UIView {
    enum Layout {
        static let margin: CGFloat = 10.0
    }

    struct Content {
        let title: String
        let weatherCardContent: WeatherCardView.Content
    }

    weak var delegate: WeatherViewDelegate?
    let activityIndicator = UIActivityIndicatorView(style: .medium)

    private let textField = UITextField()
    private let searchButton = UIButton(type: .system)
    private let weatherCardView = WeatherCardView(imageLoader: DefaultImageLoader())

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required convenience init?(coder _: NSCoder) {
        self.init(frame: .zero)
    }

    private func setupUI() {
        textField.placeholder = "Enter city name"
        textField.borderStyle = .roundedRect
        textField.delegate = self
        backgroundColor = .systemBackground

        searchButton.setTitle("Go", for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [textField, searchButton])
        stackView.axis = .horizontal
        stackView.spacing = Layout.margin
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        weatherCardView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(activityIndicator)
        addSubview(weatherCardView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30.0),
            textField.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.6),
        ])

        NSLayoutConstraint.activate([
            weatherCardView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Layout.margin),
            weatherCardView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Layout.margin),
            weatherCardView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: Layout.margin),
            weatherCardView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Layout.margin),
        ])

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func populate(content: Content) {
        weatherCardView.populate(content: content.weatherCardContent)
    }

    func showAlert(title: String, message: String) {
        delegate?.weatherView(self, showAlertWithTitle: title, message: message)
    }

    @objc private func handleTap(_: UITapGestureRecognizer) {
        endEditing(true)
    }
}

extension WeatherView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let city = textField.text, !city.isEmpty {
            delegate?.getWeatherFor(city)
        }
        return true
    }

    @objc private func searchButtonTapped() {
        textField.resignFirstResponder()
        if let city = textField.text, !city.isEmpty {
            delegate?.getWeatherFor(city)
        }
    }
}
