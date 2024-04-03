//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Алина Фирсенкова on 03.04.2024.
//

import UIKit

class ViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        guard let buttonText = sender.currentTitle else { return }
        print (buttonText)
        
    }
    
    
}




