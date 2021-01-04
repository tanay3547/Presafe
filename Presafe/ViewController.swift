//
//  ViewController.swift
//  Presafe
//
//  Created by Tanay Agrawal on 11/5/20.
//  Copyright © 2020 Tanay Agrawal. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
var isUserSafe = false
let foulWords : [String] = ["hi", "abuse", "apple"]
var count = 0
class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var startButton: UIButton!
    let audioEngine = AVAudioEngine()
    let speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task : SFSpeechRecognitionTask!
    var isStart : Bool = false
    var words : [String]!
    var timer : Timer?
    var message : String! = ""
    var index : String.Index?
    var tempString : String! = ""
    let center =  UNUserNotificationCenter.current()
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPermission()
        text.sizeToFit()
        let width = (self.view.layer.frame.width / 3) + 60
        let viewWidth = self.view.layer.frame.width / 2
        let y =  (self.view.layer.frame.height * 3)/4
        startButton.frame = CGRect(x: CGFloat(Int(width)) - 90, y: CGFloat(Int(y)) - 30, width: width, height: width)
        startButton.clipsToBounds = true
        text.frame = CGRect(x: 15, y: 150, width: (viewWidth * 2) - 30, height: (viewWidth * 2) + 30)
        text.layer.cornerRadius = 10
        startButton.layer.cornerRadius = startButton.bounds.size.width / 2
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isUserSafe) {
            displayAlert(title: "Thank God", message: "We are glad that you are safe! Take care")
            isUserSafe = false
        }
    }

    
    @IBAction func startListening(_ sender: Any) {
        isStart = !isStart
        if(isStart) {
            speechRecognition()
            startButton.setTitle("Stop", for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        } else {
            stopSpeech()
            startButton.setTitle("Start", for: .normal)
        }
    }
    
    func speechRecognition () {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.displayAlert(title: "Error", message: "Error starting the audio engine")
        }
        
        guard let myRecognition = SFSpeechRecognizer() else {
            self.displayAlert(title: "Erro", message: "Speech Recognition not available")
            return
        }
        
        if(!myRecognition.isAvailable) {
            self.displayAlert(title: "Speech Recognizer Busy", message: "Speech Recognizer is being used by some other app on your iphone")
        }
    
        task = speechRecognizer?.recognitionTask(with: request, resultHandler: { [self] (response, error) in
            guard let response = response else {
                if(error != nil) {
                    self.displayAlert(title: "Error", message: error.debugDescription)
                } else {
                    self.displayAlert(title: "Error", message: "Problem is giving the response")
                }
                return
            }
            self.tempString = response.bestTranscription.formattedString
            if(self.index == nil) {
                self.message = response.bestTranscription.formattedString.lowercased()
            } else {
                self.message = response.bestTranscription.formattedString.lowercased().substring(from: self.index ?? tempString.startIndex)
            }
            self.words = self.message.components(separatedBy: " ")
            var word : String! = words.last
            if(foulWords.contains(word)) {
                print(count)
                count += 1
            }
            if(count > 3) {
                sendNotification()
                self.isStart = !self.isStart
                stopSpeech()
                startButton.setTitle("Start", for: .normal)
                performSegue(withIdentifier: "Emergency", sender: self)
                count = 0
            }
            self.text.text = self.message
        })
    }
    
    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            OperationQueue.main.addOperation {
                if authStatus == .authorized {
                    print("Accepted")
                    self.startButton.isEnabled = true
                } else if authStatus == .denied{
                    self.displayAlert(title: "Denied Permission", message: "User denied permission")
                } else if authStatus == .notDetermined {
                    self.displayAlert(title: "Speech Recognition Feature not available", message: "Your phone doesn't have speech recognition feature")
                }
            }
        }
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (result, error) in
           //handle result of request failure
        }
    }
    
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func fireTimer() {
        index = self.tempString.endIndex
        index = self.tempString.index(before: index ?? self.tempString.startIndex)
        words?.removeAll()
        message = ""
        self.text.text = ""
    }
    
    func stopSpeech () {
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        task.finish()
        request.endAudio()
        audioEngine.stop()
        self.text.text = ""
        count = 0
        index = nil
        self.tempString = ""
        timer?.invalidate()
        timer = nil
    }
    
    func sendNotification() {
        //get the notification center
        let center =  UNUserNotificationCenter.current()

        //create the content for the notification
        let content = UNMutableNotificationContent()
        content.title = "Emergency"
        content.subtitle = "Open Urgently"
        content.body = "If the timer is not stopped within 60s, the app will call the police"
        content.sound = UNNotificationSound.default

        //notification trigger can be based on time, calendar or location
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:2.0, repeats: false)

        //create request to display
        let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: trigger)

        //add request to notification center
        center.add(request) { (error) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
    }

}

