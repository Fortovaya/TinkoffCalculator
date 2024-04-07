//
//  CalculationsListViewController.swift
//  TinkoffCalculator
//
//  Created by Алина Фирсенкова on 04.04.2024.
//

import UIKit

class CalculationsListViewController: UIViewController {
    
    
    @IBOutlet weak var calculationLabel: UILabel!
    
    var result: String?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize(){
        modalPresentationStyle = .fullScreen
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculationLabel.text = result
    }
    
    
    
    @IBAction func dissmisVC(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // отражение Navigation Bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
}