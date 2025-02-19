//
//  BaseViewController.swift
//  ThenToday
//
//  Created by Anton Solovev on 17.02.2025.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {
    func setRootUserInteractionEnabled(_ enabled: Bool) {
        let scene = view.window?.windowScene ?? UIApplication.shared.connectedScenes.first as? UIWindowScene
        scene?.windows.first?.isUserInteractionEnabled = enabled
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if navigationController?.viewControllers.first != self {
            setupCustomBackButton()
        }
    }
}

// MARK: CustomBackButton setup method
extension BaseViewController {
    private func setupCustomBackButton() {
        let customBackButton = UIButton(type: .custom)
        customBackButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        customBackButton.tintColor = .accent
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        let customBackBarButtonItem = UIBarButtonItem(customView: customBackButton)
        navigationItem.leftBarButtonItem = customBackBarButtonItem
    }
}

// MARK: - OnTap method
extension BaseViewController {
    @objc private func customBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
