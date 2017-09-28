//
//  StepViewController.swift
//  Lab3
//
//  Created by Mandar Phadate on 9/27/17.
//  Copyright © 2017 Leyva_Phadate. All rights reserved.
//

import UIKit
import CoreMotion


class StepViewController: UIViewController {
    
    
    // MARK: Class Variables
    let GOALKEY = "STEPGOAL"
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    var previousActivityConfidence: CMMotionActivityConfidence = CMMotionActivityConfidence.low
    let userDefaults = UserDefaults()
    
    // MARK: UIElements
    @IBOutlet weak var actionImage: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var stepsTodayLabel: UILabel!
    @IBOutlet weak var stepsYesterdayLabel: UILabel!
    @IBOutlet weak var stepsGoalLabel: UILabel!
    @IBOutlet weak var gameButton: UIButton!
    @IBOutlet weak var stepProgressBar: UIProgressView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        prepareUI()
       // self.getStartTimeForYesterday()
        self.startActivityMonitoring()
        self.monitorStepCountForToday()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Activity Functions
    func startActivityMonitoring() -> Void {
        if CMMotionActivityManager.isActivityAvailable(){
            let oc = OperationQueue()
            // update from this queue (should we use the MAIN queue here??.... )
            self.activityManager.startActivityUpdates(to: oc)
            {(activity:CMMotionActivity?)->Void in
                // unwrap the activity and disp
                if let unwrappedActivity = activity {
                    
                    DispatchQueue.main.async{
                        //
                        self.updateAction(activty: unwrappedActivity)
                      //  self.label.text = "Walking: \(unwrappedActivity.walking) \n Still: \(unwrappedActivity.stationary)"

                    }
                }
            }
        }
    }

    func monitorStepCountForToday(){
        
        //separate out the handler for better readability
        if CMPedometer.isStepCountingAvailable(){
            pedometer.startUpdates(from: self.getStartTimeForToday(), withHandler: self.handlePedometer as CMPedometerHandler!)
        }
    }
    
    //ped handler
    func handlePedometer(_ pedData:CMPedometerData?, error:Error?) -> Void{
        if pedData != nil {
            let steps = pedData?.numberOfSteps
            let goal = self.userDefaults.integer(forKey: self.GOALKEY)
            let progress = (steps?.floatValue ?? 0.0)/Float(goal)
            DispatchQueue.main.async{
               // self.pedometerCount.setValue((steps?.floatValue)!, animated: true)
                self.stepsTodayLabel.text = "\(steps!)"
                if(progress<=1){
                    self.stepProgressBar.setProgress(progress, animated: true)
                    self.setUpGameButton(shouldEnable: false, stepsLeft: goal - (steps?.intValue)!)
                } else{
                    self.stepProgressBar.setProgress(1.0, animated: true)
                    self.setUpGameButton(shouldEnable: false, stepsLeft: nil)
                }
            }
        }
    }
    
    // function to determine action
    func updateAction(activty:CMMotionActivity) -> Void {
        // Check for stationary 1st
        if activty.stationary {
            self.actionImage.image = UIImage(named: "stationary")
            self.actionLabel.text = "Still"
        } else if activty.automotive {
            self.actionImage.image = UIImage(named: "driving")
            self.actionLabel.text = "Driving"
        } else if activty.walking {
            self.actionImage.image = UIImage(named: "walking")
            self.actionLabel.text = "Walking"
        } else if activty.running {
            self.actionImage.image = UIImage(named: "running")
            self.actionLabel.text = "Running"
        }else if activty.unknown {
            self.actionImage.image = UIImage(named: "unknown")
            self.actionLabel.text = "Unknown"
        }else if (!activty.stationary && !activty.walking && !activty.automotive && !activty.cycling && !activty.unknown && !activty.cycling) {
            self.actionImage.image = UIImage(named: "moving")
            self.actionLabel.text = "Moving"
        }
        switch (activty.confidence){
        case CMMotionActivityConfidence.high:
            self.confidenceLabel.text = "Confidence: High"
            break
        case CMMotionActivityConfidence.medium:
            self.confidenceLabel.text = "Confidence: Medium"
            break
        case CMMotionActivityConfidence.low:
            self.confidenceLabel.text = "Confidence: Low"
            break
        }
        
    }
    
    @IBAction func gameButtonPressed(_ sender: UIButton) {
        // Launch game here
        print("button pressed")
    }
    
    @IBAction func editStepGoal(_ sender: UIBarButtonItem) {
        // View step goal settings
        self.setUpGameButton(shouldEnable: true, stepsLeft: nil)
    }
    
    func getStartTimeForToday() -> Date {
        return Calendar.current.startOfDay(for: Date())
    }
    func getStartTimeForYesterday() -> Date{
        let today = self.getStartTimeForToday()
        return today.addingTimeInterval(-24*60*60)
    }
    func getEndTimeForYesterday() -> Date{
        let today = self.getStartTimeForToday()
        return today.addingTimeInterval(-1)
    }
    
    func prepareUI() -> Void {
        // Set steps taken today
        var stepsToday:NSNumber = 0
        if CMPedometer.isStepCountingAvailable(){
            pedometer.queryPedometerData(from: self.getStartTimeForToday(), to: Date())
            {(data:CMPedometerData?, error:Error?) -> Void in
                if (error == nil){
                    stepsToday = data?.numberOfSteps ?? 0
                    DispatchQueue.main.async {
                        self.stepsTodayLabel.text = "\(data?.numberOfSteps ?? 0)"
                    }
                }
            }
            pedometer.queryPedometerData(from: self.getStartTimeForYesterday(), to: self.getEndTimeForYesterday())
            {(data:CMPedometerData?, error:Error?) -> Void in
                if (error == nil){
                    DispatchQueue.main.async {
                        self.stepsYesterdayLabel.text = "\(data?.numberOfSteps ?? 0)"
                    }
                }
            }
        }
        let goal = userDefaults.integer(forKey: GOALKEY)
        var progress = stepsToday.floatValue/(Float(goal))
        if (goal != 0 ){
            DispatchQueue.main.async {
                self.stepsGoalLabel.text = "\(goal)"
                if(progress<=1){
                    self.stepProgressBar.setProgress(progress, animated: true)
                    self.setUpGameButton(shouldEnable: false, stepsLeft: goal - stepsToday.intValue)

                } else{
                    self.stepProgressBar.setProgress(1.0, animated: true)
                    self.setUpGameButton(shouldEnable: true, stepsLeft: nil)

                }
            }
        } else {
            userDefaults.set(1000, forKey: GOALKEY)
            progress = stepsToday.floatValue/1000.0
            DispatchQueue.main.async {
                self.stepsGoalLabel.text = "1000"
                if(progress<=1){
                    self.stepProgressBar.setProgress(progress, animated: true)
                    self.setUpGameButton(shouldEnable: false, stepsLeft: 1000 - stepsToday.intValue)
                } else{
                    self.stepProgressBar.setProgress(1.0, animated: true)
                    self.setUpGameButton(shouldEnable: true, stepsLeft: nil)
                }
            }
        }
    }
    
    func setUpGameButton(shouldEnable:Bool, stepsLeft:Int?) -> Void {
        if shouldEnable{
            self.gameButton.isEnabled = true
            self.gameButton.backgroundColor = UIColor(red: 0, green: 143, blue: 0, alpha: 1)
            self.gameButton.setTitle("🚀 Play game", for: UIControlState.normal)
        } else{
            self.gameButton.isEnabled = false
            self.gameButton.backgroundColor = UIColor.darkGray
            self.gameButton.setTitle("\(stepsLeft ?? 100) steps left !", for: UIControlState.disabled)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
