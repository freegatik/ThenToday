//
//  DatePickerViewControllerFetchMethod.swift
//  ThenToday
//
//  Created by Anton Solovev on 23.02.2025.
//

import UIKit

// MARK: - Exploration flow
extension DatePickerViewController {
    @MainActor
    func runExplorationFlow() async {
        setRootUserInteractionEnabled(false)
        showLoader()
        defer {
            hideLoader()
            setRootUserInteractionEnabled(true)
        }

        do {
            let result = try await dayExploration.exploration(for: datePicker.date)
            guard !Task.isCancelled else { return }

            information = result.information
            image = result.image ?? Constants.emptyImage

            let imageForDetails = image ?? Constants.emptyImage!
            let nextViewController = DateInformationViewController(
                information: result.information,
                image: imageForDetails,
                translateClient: translateClient
            )
            navigationController?.pushViewController(nextViewController, animated: true)
        } catch let error as CustomError where error == .cancelled {
            return
        } catch let error as CustomError {
            AlertManager.presentAlert(
                on: self,
                title: NSLocalizedString("datePickerAlertTitle", comment: ""),
                message: error.errorDescription ?? NSLocalizedString("datePickerAlertMessage", comment: ""),
                okButtonTitle: String(localized: "common_ok")
            )
            information = Constants.emptyString
            image = Constants.emptyImage
        } catch {
            AlertManager.presentAlert(
                on: self,
                title: NSLocalizedString("datePickerAlertTitle", comment: ""),
                message: NSLocalizedString("datePickerAlertMessage", comment: ""),
                okButtonTitle: String(localized: "common_ok")
            )
            information = Constants.emptyString
            image = Constants.emptyImage
        }
    }
}
