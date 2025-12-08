//
//  OverlayPopUp.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class OverlayPopUp: UIViewController {

    @IBOutlet weak var popUpUiView: UIView!
    @IBOutlet weak var backView: UIView!
    
    init() {
        super.init(nibName: "OverlayPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpUiView.applyCardStyle()
        // Do any additional setup after loading the view.
        configView()
    }
    
    func configView() {
        self.view.backgroundColor = .clear
        self.backView.backgroundColor = .black.withAlphaComponent(0.6)
        // Start hidden for fade-in
        backView.alpha = 0
        popUpUiView.alpha = 0
    }
    
    func appear(sender: UIViewController) {
        sender.present(self, animated: false)
        self.show()
    }
    
    private func show() {
        UIView.animate(withDuration: 1.0, delay: 0.1, options: [.curveEaseInOut], animations: {
            self.popUpUiView.alpha = 1.0
            self.backView.alpha = 1.0
        }, completion: nil)
    }
    
    func hide() {
        UIView.animate(withDuration: 0.0, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.backView.alpha = 0.0
            self.popUpUiView.alpha = 0.0
        }) { _ in
            self.dismiss(animated: false, completion: nil)
            self.removeFromParent()
        }
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        hide()
    }

}
