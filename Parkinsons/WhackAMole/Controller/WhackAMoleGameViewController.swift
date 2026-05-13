import UIKit
import SwiftUI

class WhackAMoleGameViewController: UIViewController {

    var selectedDate: Date!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationItem.hidesBackButton = true
        let closeAction = UIAction { [weak self] _ in
            self?.handleQuit()
        }
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
        closeButton.primaryAction = closeAction
        navigationItem.leftBarButtonItem = closeButton

        let mgr = WhackAMoleGameManager.shared
        let duration = mgr.gameDuration(for: selectedDate)
        let bombChance = mgr.bombChance(for: selectedDate)
        let interval = mgr.moleInterval(for: selectedDate)
        let holes = mgr.holeCount(for: selectedDate)

        let vm = WhackAMoleViewModel(
            duration: duration,
            bombChance: bombChance,
            moleInterval: interval,
            holeCount: holes
        )

        let gameView = WhackAMoleGameView(
            viewModel: vm,
            onGameEnd: { [weak self] score, hitBomb in
                self?.handleGameEnd(score: score, hitBomb: hitBomb)
            }
        )

        let hostingVC = UIHostingController(rootView: gameView)
        hostingVC.view.backgroundColor = .clear
        addChild(hostingVC)
        hostingVC.view.frame = view.bounds
        hostingVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }

    private func handleGameEnd(score: Int, hitBomb: Bool) {
        WhackAMoleGameManager.shared.markCompleted(date: selectedDate)
        WhackAMoleGameManager.shared.saveScore(date: selectedDate, score: score)

        let successVC = WhackAMoleSuccessViewController()
        successVC.score = score
        successVC.hitBomb = hitBomb
        successVC.selectedDate = selectedDate
        navigationController?.pushViewController(successVC, animated: true)
    }

    private func handleQuit() {
        let alert = UIAlertController(
            title: "Quit Game?",
            message: "Your progress will not be saved.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Quit", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
