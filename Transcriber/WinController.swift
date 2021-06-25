//
//  WinController.swift
//  Transcriber
//
//  Created by Erik Engheim on 24/06/2021.
//

import Cocoa
import Speech

class WinController: NSWindowController, SFSpeechRecognizerDelegate, AVAudioRecorderDelegate {
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    var recorder : AVAudioRecorder?
    var player : AVAudioPlayer?
    
    @IBOutlet weak var transcribedTextView: NSTextView!
    @IBOutlet weak var sourceTextView: NSTextView!
    @IBOutlet weak var recordButton: NSButton!
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var transcribeButton: NSButton!
    
    @IBOutlet weak var audioInputField: NSTextField!
    @IBOutlet weak var textInputField: NSTextField!
    @IBOutlet weak var rectimeField: NSTextField!
    @IBOutlet weak var powerField: NSTextField!
    
    
    
    override func windowDidLoad() {
        super.windowDidLoad()

        enableRecordButtons(false)
    }
    
    override public func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        self.recognizer.delegate = self
        
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
        
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { timer in
            if let rec = self.recorder {
                self.rectimeField.floatValue = Float(rec.currentTime)
                rec.updateMeters() // or you cannot get peak power values
                self.powerField.floatValue = rec.peakPower(forChannel: 1)
            }
        }
    }
    
    func enableRecordButtons(_ on: Bool) {
        recordButton.isEnabled = on
        pauseButton.isEnabled = on
        transcribeButton.isEnabled = on
    }
    
    @IBAction func playAudio(_ sender: Any) {
        let url = URL(fileURLWithPath: self.audioInputField.stringValue)
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            self.player = player
        } catch {
            NSLog("faild to create audio player")
        }
    }
    
    @IBAction func stopPlaying(_ sender: Any) {
        self.player?.stop()
        self.player = nil
    }
    
    
    // Audio only recording
    func startRecording() throws {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDir = paths[0]
        let filename = docsDir.appendingPathComponent("recording.m4a")
        
        self.audioInputField.stringValue = filename.path
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        let rec = try AVAudioRecorder(url: filename, settings: settings)
        rec.delegate = self
        var ok = rec.prepareToRecord()
        if !ok {
            NSLog("Not okay to prepare recording")
        }
        rec.isMeteringEnabled = true // TODO: Use a checkbox for this
        ok = rec.record()
        if !ok {
            NSLog("Failed to start recording")
        }
        self.recorder = rec
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false            
        }
    }
    
    // MARK: AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            self.recorder?.stop()
            self.recorder = nil
            NSLog("Recording interrupted")
        }
    }
    
    // MARK: Interface Builder actions
    
    @IBAction func record(sender: AnyObject) {
        if let rec = self.recorder, !rec.isRecording {
            rec.record()
            NSLog("Resume recording")
            return
        }
        
        do {
            try startRecording()
        } catch {
            NSLog("Failed to record")
        }
    }
    
    @IBAction func stop(sender: AnyObject) {
        self.recorder?.stop()
        self.recorder = nil
    }
    
    @IBAction func pause(sender: AnyObject) {
        self.recorder?.pause()
        NSLog("Pause recording")
    }


    @IBAction func save(sender: AnyObject) {
        
    }
    
    @IBAction func loadSourceText(sender: AnyObject) {
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
                    self.textInputField.stringValue = url.path
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

            self.audioInputField.stringValue = url.path
            self.transcribeButton.isEnabled = true
        }
    }
    
    @IBAction func startTranscribe(_ sender: Any) {
        let url: URL = URL(fileURLWithPath: self.audioInputField.stringValue)
        
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
