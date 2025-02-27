//
//  DateInformationViewControllerFetchMethod.swift
//  ThenToday
//
//  Created by Anton Solovev on 26.02.2025.
//

import UIKit

// MARK: - Fetch Languages
extension DateInformationViewController {
    func fetchLanguages() {
        languagesTask?.cancel()
        languagesTask = Task { [weak self] in
            guard let self else { return }
            do {
                let list = try await translateClient.getLanguagesList()
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.languages = list
                    self.languagePicker.reloadAllComponents()
                    if let defaultIndex = self.languages.firstIndex(where: { $0.code == Constants.defaultLanguageCode }) {
                        self.languagePicker.selectRow(defaultIndex, inComponent: 0, animated: false)
                    }
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    AlertManager.presentAlert(
                        on: self,
                        title: NSLocalizedString("fetchLanguagesAlertTitle", comment: ""),
                        message: NSLocalizedString("fetchLanguagesAlertMessage", comment: ""),
                        okButtonTitle: String(localized: "common_ok")
                    )
                    self.languages = []
                }
            }
        }
    }
}

// MARK: - ReTranslate Information
extension DateInformationViewController {
    func translateInformation(to targetLanguage: String, completion: @escaping () -> Void) {
        translateTask?.cancel()
        translateTask = Task { [weak self] in
            guard let self else { return }
            await MainActor.run {
                self.setRootUserInteractionEnabled(false)
                self.showLoader()
            }

            let textToTranslate = await MainActor.run { self.information ?? Constants.emptyString }

            do {
                let translated = try await translateClient.translateText(text: textToTranslate, targetLanguage: targetLanguage)
                guard !Task.isCancelled else {
                    await MainActor.run {
                        self.hideLoader()
                        self.setRootUserInteractionEnabled(true)
                        completion()
                    }
                    return
                }
                await MainActor.run {
                    self.information = translated
                }
            } catch {
                guard !Task.isCancelled else {
                    await MainActor.run {
                        self.hideLoader()
                        self.setRootUserInteractionEnabled(true)
                        completion()
                    }
                    return
                }
                await MainActor.run {
                    if let err = error as? CustomError {
                        AlertManager.presentAlert(
                            on: self,
                            title: NSLocalizedString("dateInformationAlertTitle", comment: ""),
                            message: err.errorDescription ?? NSLocalizedString("dateInformationAlertMessage", comment: ""),
                            okButtonTitle: String(localized: "common_ok")
                        )
                    } else {
                        AlertManager.presentAlert(
                            on: self,
                            title: NSLocalizedString("dateInformationAlertTitle", comment: ""),
                            message: NSLocalizedString("dateInformationAlertMessage", comment: ""),
                            okButtonTitle: String(localized: "common_ok")
                        )
                    }
                    self.information = nil
                    self.image = Constants.emptyImage
                }
            }

            await MainActor.run {
                self.hideLoader()
                self.setRootUserInteractionEnabled(true)
                completion()
            }
        }
    }
}
