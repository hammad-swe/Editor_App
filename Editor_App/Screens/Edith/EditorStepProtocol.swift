//
//  EditorStepProtocol.swift
//  Editor_App
//
//  Created by Antigravity on 18/08/2026.
//

import UIKit

protocol EditorStepDelegate: AnyObject {
    func stepDidTapNext(_ step: UIViewController)
    func stepDidTapSkip(_ step: UIViewController)
    func stepDidTapBack(_ step: UIViewController)
}

protocol EditorStepViewController: UIViewController {
    var stepDelegate: EditorStepDelegate? { get set }
    var viewModel: VideoEditingViewModel! { get set }
    func applyToViewModel()
}
