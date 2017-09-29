//
//  GoalViewController.swift
//  Lab3
//
//  Created by Mandar Phadate on 9/28/17.
//  Copyright © 2017 Leyva_Phadate. All rights reserved.
//

import UIKit

class GoalViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Class Variables
    let userDefaults = UserDefaults()
    let GOALKEY = "STEPGOAL"
    
    //MARK: UI Elements
    @IBOutlet weak var goalSlider: UISlider!
    @IBOutlet weak var goalText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.goalText.delegate = self
        self.goalText.returnKeyType = UIReturnKeyType.done
        self.prepareUI()

        // Do any additional setup after loading the view.
    }
    
    func prepareUI() -> Void {
        let stepGoal = userDefaults.integer(forKey: GOALKEY)
        self.goalSlider.setValue(Float(stepGoal), animated: true)
        self.goalText.text = String(stepGoal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        let stepGoal = Int(self.goalSlider.value)
        self.goalText.text = String(stepGoal)
    }
    @IBAction func saveAction(_ sender: UIButton) {
        self.userDefaults.set(Int(self.goalSlider.value), forKey: GOALKEY)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func backPressed(_ sender: UIButton) {
            self.dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Only numbers allowed
        let allowd_characters = CharacterSet.decimalDigits
        let charset = CharacterSet(charactersIn: string)
        return allowd_characters.isSuperset(of: charset)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss keyboard when touch outside
        self.goalText.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let stepGoal: Int? = Int(self.goalText.text!)
        if(stepGoal != nil){
            self.goalSlider.value = Float(stepGoal!)
        }
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    

}
