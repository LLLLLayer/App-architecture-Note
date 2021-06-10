//
//  Utilites.swift
//  Recordings-MVC
//
//  Created by 杨杰 on 2021/6/8.
//

import Foundation
import UIKit

extension UIViewController {
    func modalTextAlert(title: String,
                        accept: String = .ok,
                        cancel: String = .cancel,
                        placeholder: String,
                        callBack: @escaping (String?) -> ()) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { $0.placeholder = placeholder })
        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { _ in
            callBack(nil)
        }))
        alert.addAction((UIAlertAction(title: accept, style: .default, handler: { _ in
            callBack(alert.textFields?.first?.text)
        })))
        present(alert, animated: true, completion: nil)
    }
}

fileprivate extension String {
    static let ok = NSLocalizedString("OK", comment: "")
    static let cancel = NSLocalizedString("Cancel", comment: "")
}

private let formatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    formatter.allowedUnits = [.hour, .minute, .second]
    return formatter
}()

func timeString(_ time: TimeInterval) -> String {
    return formatter.string(from: time)!
}
