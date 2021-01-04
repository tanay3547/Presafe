//
//  ViewController.swift
//  Presafe
//
//  Created by Tanay Agrawal on 11/5/20.
//  Copyright © 2020 Tanay Agrawal. All rights reserved.
//

import UIKit

    //MARK: - UIViewController Properties
class TimerViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!

    var seconds = 60
    var timer = Timer()
 
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimerViewController.updateTimer)), userInfo: nil, repeats: true)
        pauseButton.isEnabled = true
    }
        
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        timer.invalidate()
        seconds = 60
        timerLabel.text = "60 Seconds Left"
        dismiss(animated: true, completion: nil)
        isUserSafe = true
    }
    

    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            guard let number = URL(string: "tel://8839617964") else { return }
            UIApplication.shared.open(number)
            //Send alert to indicate time's up.
        } else {
            seconds -= 1
            timerLabel.text = "\(seconds) Seconds Left"
//            labelButton.setTitle(timeString(time: TimeInterval(seconds)), for: UIControlState.normal)
        }
    }
    
    //MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = self.view.layer.frame.width - 20
        let y =  (self.view.layer.frame.height - width) / 2
        pauseButton.frame = CGRect(x: 10, y: y, width: width, height: width)
        pauseButton.clipsToBounds = true
        pauseButton.layer.cornerRadius = pauseButton.bounds.size.width / 2
        runTimer()
    }
}

