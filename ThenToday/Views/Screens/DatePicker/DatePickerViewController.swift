//
//  DatePickerViewController.swift
//  ThenToday
//
//  Created by Anton Solovev on 20.02.2025.
//

import UIKit

class DatePickerViewController: BaseViewController, CustomButtonDelegate {
    let dayExploration: DayExplorationService
    let translateClient: YandexTranslateClient

    var explorationTask: Task<Void, Never>?

    // MARK: - Init
    var image: UIImage?
    var information: String?
    var loader: UIActivityIndicatorView?

    init(dayExploration: DayExplorationService, translateClient: YandexTranslateClient) {
        self.dayExploration = dayExploration
        self.translateClient = translateClient
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        explorationTask?.cancel()
    }

    var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    var titleImage: UIImageView = {
        let image = UIImageView()
        return image
    }()

    var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        return datePicker
    }()

    var button: CustomButton = {
        let button = CustomButton()
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(titleImage)
        configureTitleImage()

        view.addSubview(titleLabel)
        configureTitleLabel()

        view.addSubview(datePicker)
        configureDatePicker()

        view.addSubview(button)
        configureButton()
    }
}
