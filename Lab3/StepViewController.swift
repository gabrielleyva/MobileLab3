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
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    var previousActivityConfidence: CMMotionActivityConfidence = CMMotionActivityConfidence.low
    
    // MARK: UIElements
    @IBOutlet weak var actionImage: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    @IBOutlet weak var pedometerCount: UILabel!
    @IBOutlet weak var label: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
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
                        self.label.text = "Walking: \(unwrappedActivity.walking) \n Still: \(unwrappedActivity.stationary)"

                    }
                }
            }
        }
    }

    func startPedometerMonitoring(){
        
        //separate out the handler for better readability
        if CMPedometer.isStepCountingAvailable(){
            pedometer.startUpdates(from: Date(), withHandler: self.handlePedometer as CMPedometerHandler!)
        }
    }
    
    //ped handler
    func handlePedometer(_ pedData:CMPedometerData?, error:Error?) -> Void{
        if pedData != nil {
            let steps = pedData?.numberOfSteps
            DispatchQueue.main.async{
               // self.pedometerCount.setValue((steps?.floatValue)!, animated: true)
                self.pedometerCount.text = "Steps: \(steps!)"
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
