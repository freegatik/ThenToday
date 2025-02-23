//
//  DatePickerViewControllerLoaderLogic.swift
//  ThenToday
//
//  Created by Anton Solovev on 22.02.2025.
//

import UIKit

// MARK: - Loader logic
extension DatePickerViewController {
    func showLoader() {
        self.view.backgroundColor = .systemGray
        self.view.layer.opacity = 0.5
        
        loader = UIActivityIndicatorView(style: .large)
        loader?.center = view.center
        loader?.color = .white
        loader?.isAccessibilityElement = true
        loader?.accessibilityLabel = String(localized: "accessibility_loading")
        loader?.startAnimating()
        
        if let loader = loader {
            view.addSubview(loader)
        }
    }
    
    func hideLoader() {
        self.view.backgroundColor = .systemBackground
        self.view.layer.opacity = 1
        
        loader?.stopAnimating()
        loader?.removeFromSuperview()
        loader = nil
    }
}
