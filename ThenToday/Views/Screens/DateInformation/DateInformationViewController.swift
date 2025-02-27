//
//  DateInformationViewController.swift
//  ThenToday
//
//  Created by Anton Solovev on 24.02.2025.
//

import UIKit

class DateInformationViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let translateClient: YandexTranslateClient
    var languagesTask: Task<Void, Never>?
    var translateTask: Task<Void, Never>?

    // MARK: - Init
    var image: UIImage?
    var information: String?
    var languages: [Language] = []
    var loader: UIActivityIndicatorView?

    init(information: String, image: UIImage, translateClient: YandexTranslateClient) {
        self.information = information
        self.image = image
        self.translateClient = translateClient
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        languagesTask?.cancel()
        translateTask?.cancel()
    }

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    let contentView: UIView = {
        let view = UIView()
        return view
    }()

    var languagePicker: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()

    var informationImage: UIImageView = {
        let image = UIImageView()
        return image
    }()

    var informationLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        fetchLanguages()

        view.addSubview(scrollView)
        configureScrollView()

        scrollView.addSubview(contentView)
        configureContentView()

        contentView.addSubview(informationImage)
        configureInformationImage()

        contentView.addSubview(informationLabel)
        configureInformationLabel()

        contentView.addSubview(languagePicker)
        configureLanguagePicker()
    }
}
