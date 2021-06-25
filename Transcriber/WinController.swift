//
//  WinController.swift
//  Transcriber
//
//  Created by Erik Engheim on 24/06/2021.
//

import Cocoa
import Speech

class WinController: NSWindowController, SFSpeechRecognizerDelegate {
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    var recogReq: SFSpeechAudioBufferRecognitionRequest?
    var recogTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    @IBOutlet weak var transcribedTextView: NSTextView!
    @IBOutlet weak var sourceTextView: NSTextView!
    @IBOutlet weak var recordButton: NSButton!
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    
    
    override func windowDidLoad() {
        super.windowDidLoad()

        enableRecordButtons(false)
    }
    
    override public func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        recognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStat in
            OperationQueue.main.addOperation {
                switch authStat {
                case .authorized:
                    self.enableRecordButtons(true)
                default:
                    self.enableRecordButtons(false)
                }
            }
        }
    }
    
    func enableRecordButtons(_ on: Bool) {
        recordButton.isEnabled = on
        pauseButton.isEnabled = on
    }
    
//    func startRecording() throws {
//        // cancel any previously running task
//        recogTask?.cancel()
//        self.recogTask = nil
//
//        // Create and configure the speech recognition request.
//        self.recogReq = SFSpeechAudioBufferRecognitionRequest()
//        guard let recogReq = recogReq else {
//            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
//        }
//        recogReq.shouldReportPartialResults = true
//
//        let input = audioEngine.inputNode
//
//        // Create a recognition task for the speech recognition session.
//        recogTask = self.recognizer.recognitionTask(with: recogReq) { result, error in
//            NSLog("Start reckognition task")
//            var done = false
//            if let result = result {
//                self.transcribedTextView.string = result.bestTranscription.formattedString
//                done = result.isFinal
//            }
//
//            if error != nil || done {
//                self.audioEngine.stop()
//                input.removeTap(onBus: 0)
//                self.recogReq = nil
//                self.recogTask = nil
//                self.enableRecordButtons(true)
//            }
//        }
//
//        // Configure the microphone input.
//        let format = input.outputFormat(forBus: 0)
//
//        input.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
//            NSLog("Received audio")
//            self.recogReq?.append(buffer)
//        }
//
//        audioEngine.prepare()
//        try audioEngine.start()
//        transcribedTextView.string = "I am listening, start talking!"
//    }
    
    // Audio only recording
    func startRecording() throws {
        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)

        input.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recogReq?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        NSLog("Started recording audio")
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false            
        }
    }
    
    // MARK: Interface Builder actions
    
    @IBAction func record(sender: AnyObject) {
//        if audioEngine.isRunning {
//            audioEngine.stop()
//            recogReq?.endAudio()
//            recordButton.isEnabled = false
//        } else {
            do {
                try startRecording()
            } catch {
                NSLog("Recording not available")
            }
//        }
    }
    
    @IBAction func pause(sender: AnyObject) {
        NSLog("Hit pause")
    }

//    @IBAction func stop(sender: AnyObject) {
//        if audioEngine.isRunning {
//            audioEngine.stop()
//            recogReq?.endAudio()
//            recordButton.isEnabled = false
//        }
//    }
    
    // Audio only recording
    @IBAction func stop(sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            NSLog("Audio recording stopped")
        } else {
            NSLog("Audio not recording")
        }
    }

    @IBAction func save(sender: AnyObject) {
        
    }
    
    @IBAction func load(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        
        openPanel.beginSheetModal(for: window!) {
            [unowned openPanel] (response : NSApplication.ModalResponse) in
            if response == .OK {
                guard let url = openPanel.url else {
                    let alert = NSAlert()
                    alert.messageText = "Could not retrieve file location"
                    alert.runModal()
                    return
                }
                do {
                    let sourceText = try String(contentsOf: url, encoding: .utf8)
                    self.sourceTextView.string = sourceText
                } catch {
                    NSLog("Unable to load file")
                }
            }
        }
    }
    
    @IBAction func loadAudio(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        
        openPanel.beginSheetModal(for: window!) { response in
            guard response == .OK, let url = openPanel.url else {
                let alert = NSAlert()
                alert.messageText = "Could not retrieve file location"
                alert.runModal()
                return
            }

            transcribe(url: url) { (result, error) in
                if let err = error {
                    let alert = NSAlert(error: err)
                    alert.runModal()
                }
                
                guard let result = result else {
                    let alert = NSAlert()
                    alert.messageText = "transcribing voice audio failed"
                    alert.runModal()
                    return
                }

                // Print the speech that has been recognized so far
                if result.isFinal {
                    self.transcribedTextView.string = result.bestTranscription.formattedString
                }
            }
        }
    }
}
