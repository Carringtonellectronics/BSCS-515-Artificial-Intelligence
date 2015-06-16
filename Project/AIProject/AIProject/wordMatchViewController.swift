//
//  wordMatchViewController.swift
//  AIProject
//
//  Created by Muhammad Raza on 16/06/2015.
//  Copyright (c) 2015 Muhammad Raza. All rights reserved.
//

import UIKit

class wordMatchViewController: UIViewController {

    //References
    @IBOutlet weak var bestCandidateLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var iterationLabel: UILabel!
    @IBOutlet weak var wordTextView: UITextView!
    
    var lab = WordMatching()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startButtonClick(sender: AnyObject) {
        
        self.lab.output = { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.targetLabel.text = self.lab.targetWord
                self.bestCandidateLabel.text = data.bestCandidate
                self.distanceLabel.text = "\(data.bestCandidateFitness)"
                self.iterationLabel.text = "\(data.iterationNum)"
            }
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { () -> Void in
            self.lab.doScience(self.wordTextView.text)
        }
        
    }

}
