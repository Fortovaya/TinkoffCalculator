//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Алина Фирсенкова on 03.04.2024.
//

import UIKit

enum CalculationError: Error {
    case dividedByZero
}

enum Operation: String {
    case add = "+"
    case substract = "-"
    case multiply = "x"
    case divide = "/"
    
    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
            case .add: return number1 + number2
            case .substract: return number1 - number2
            case .multiply: return number1 * number2
            case .divide:
                if number2 == 0 {
                    throw CalculationError.dividedByZero
                }
                return number1 / number2
            }
    }
}

enum CalculationHistoryItem {
    case number (Double)
    case operation (Operation)
}

class ViewController: UIViewController {

    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var historyButton: UIButton!
    
    var calculationHistory: [CalculationHistoryItem] = []
    var pressedCount = 0
    
    var calculations: [Calculation] = []
    let calculationHistoryStorage = CalculationHistoryStorage()
    
    private var piValue: Double = 0.0
    
    
    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_Ru")
        numberFormatter.numberStyle = .decimal
        
        let screenWidth = UIScreen.main.bounds.width
        if screenWidth < 400 {
            numberFormatter.maximumFractionDigits = 8
        } else {
            numberFormatter.maximumFractionDigits = 15
        }
        
        return numberFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        historyButton.accessibilityIdentifier = "historyButton"
        resetLabelText()
        calculations = calculationHistoryStorage.loadHistory()
    }

// MARK: - метод нажатия кнопок и отражение в label
    
    @IBAction func buttonPressed(_ sender: UIButton) {

        guard let buttonText = sender.currentTitle else { return }
        if label.text == "Ошибка"{ resetLabelText()}
        
        if buttonText == "," && label.text?.contains(",") == true { return }
        
        if label.text == "0" && buttonText != ","  {
            label.text = buttonText
        } else {
            // добавляем символы к уже имеющемуся тексту
        label.text?.append(buttonText) }
        
        pressedCount += 1
        
        print(buttonText)
    }
    
    
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        if label.text == "Ошибка" {resetLabelText()}
        
        guard let buttonText = sender.currentTitle,
              let buttonOperation = Operation(rawValue: buttonText)
        else { return }
        guard let labelText = label.text,
              let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))
        
        resetLabelText()
        
    }
    
// MARK: - метод установки текста label равному 0
    
    func resetLabelText(){
        label.text = "0"
    }
    
    private func calculatePiWithPrecision(_ precision: Int, completion: @escaping (Double) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let pi = self.calculatePi(precision)
            self.piValue = pi
            DispatchQueue.main.async {
                completion(pi)
            }
        }
    }
    
    private func calculatePi(_ precision: Int) -> Double {
        var piValue = 0.0
        var denominator = 1.0
        var sign = 1.0
        for _ in 0..<precision {
            piValue += sign * (1.0 / denominator)
            denominator += 2.0
            sign *= -1.0
        }
        return piValue * 4.0
    }
    
    @IBAction func clearButtonPressed(){
        calculationHistory.removeAll()
        resetLabelText()
        pressedCount = 0
    }
    
    @IBAction func calculateButtonPressed(){
        
        guard let labelText = label.text,
              let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        do {
            let result = try calculate()
            label.text = numberFormatter.string(from: NSNumber(value: result))
            let newCalculation = Calculation(expression: calculationHistory, result: result, date: Date())
            calculations.append(newCalculation)
            calculationHistoryStorage.setHistory(calculation: calculations)
        } catch {
            label.text = "Ошибка"
        }
        calculationHistory.removeAll()
    }
    
    func calculate () throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0}
        
        var currentResult = firstNumber
        
        for index in stride(from: 1, to: calculationHistory.count - 1, by:2) {
            guard case .operation(let operation) = calculationHistory[index],
                  case .number(let number) = calculationHistory[index + 1]
            else { break }
            
            currentResult = try operation.calculate(currentResult, number)
        }
        
        return currentResult
        
    }
    
    @IBAction func piButtonPressed(_ sender: UIButton) {
        calculatePiWithPrecision(10000000) { pi in
            DispatchQueue.main.async {
                self.label.text = self.numberFormatter.string(from: NSNumber(value: pi))
            }
        }
    }

    // Передача данных по коду на другой Storyboard
    @IBAction func showCalculationsList(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationsListVC = sb.instantiateViewController(identifier: "CalculationsListViewController")
        if let vc = calculationsListVC as? CalculationsListViewController {
            vc.calculations = calculations
        }
        navigationController?.pushViewController(calculationsListVC, animated: true)
    }
    
    // скрытие Navigation Bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

}




