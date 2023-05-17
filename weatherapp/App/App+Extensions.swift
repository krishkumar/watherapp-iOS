//
//  WeatherApp+Extensions.swift
//  weatherapp
//
//  Created by Krishna Kumar on 5/17/23.
//

import UIKit
// Extensions

public extension UIApplication {
    @available(iOS 15.0, *)
    var firstConnectedWindow: UIWindow? {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let keyWindow = scene?.keyWindow
        return keyWindow
    }
}
