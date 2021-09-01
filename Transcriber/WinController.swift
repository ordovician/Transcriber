//
//  WinController.swift
//  Transcriber
//
//  Created by Erik Engheim on 24/06/2021.
//

import Cocoa
import Speech

class WinController: NSWindowController, SFSpeechRecognizerDelegate, AVAudioRecorderDelegate, NSTextViewDelegate, NSTableViewDelegate {
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    var recorder : AVAudioRecorder?
    var player : AVAudioPlayer?
    var transcriptions: [SpokenDoc] = []
    
    var transcriptionDataSource  = TranscriptionDataSource()
    
    @IBOutlet weak var transcribedTextView: NSTextView!
    @IBOutlet weak var sourceTextView: NSTextView!
    @IBOutlet weak var recordButton: NSButton!
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var transcribeButton: NSButton!
    
    @IBOutlet weak var audioInputField: NSTextField!
    @IBOutlet weak var textInputField: NSTextField!
    @IBOutlet weak var rectimeField: NSTextField!
    @IBOutlet weak var powerField: NSTextField!
    @IBOutlet weak var transcriptPopup: NSPopUpButton!
    @IBOutlet weak var timeLineSlider: NSSlider!
    @IBOutlet weak var clipTimeField: NSTextField!
    @IBOutlet weak var wordTableView: NSTableView!
    
    @IBOutlet weak var changeWordField: NSTextField!
    @IBOutlet weak var activityIndicator: NSProgressIndicator!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        enableRecordButtons(false)
        self.wordTableView.dataSource = self.transcriptionDataSource
        self.wordTableView.delegate = self // TODO: This is kind of a crappy solution. This
                                           // this file becomes a dump. Need to find a better way.
    }
    
    override public func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        self.recognizer.delegate = self
        self.enableRecordButtons(true)
        self.transcriptPopup.isEnabled = false
        self.timeLineSlider.isEnabled  = false
        self.timeLineSlider.minValue = 0.0
            
        SFSpeechRecognizer.requestAuthorization { authStat in
            OperationQueue.main.addOperation {
                switch authStat {
                case .authorized:
                    self.transcribeButton.isEnabled = true
                default:
                    self.transcribeButton.isEnabled = false
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
        self.activityIndicator.startAnimation(nil)
        self.recorder = rec
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        transcribeButton.isEnabled = available
    }
    
    // MARK: AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            self.recorder?.stop()
            self.recorder = nil
            NSLog("Recording interrupted")
            self.activityIndicator.stopAnimation(nil)
        }
    }
    
    // MARK: NSTableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
        let trans = self.transcriptions[transcriptPopup.indexOfSelectedItem]
        let i = self.wordTableView.selectedRow
        self.changeWordField.stringValue = trans.words[i].text
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
        self.activityIndicator.stopAnimation(sender)
    }
    
    @IBAction func pause(sender: AnyObject) {
        self.recorder?.pause()
        NSLog("Pause recording")
    }


    @IBAction func save(sender: AnyObject) {
        
    }
    
    @IBAction func loadProject(sender: AnyObject) {
        let panel = NSOpenPanel()
        
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory())
        panel.beginSheetModal(for: window!) {
            [unowned panel] (response : NSApplication.ModalResponse) in
            if response == .OK {
                guard let url = panel.url else {
                    let alert = NSAlert()
                    alert.messageText = "Could not retrieve file location"
                    alert.runModal()
                    return
                }
                do {
                    let res = try url.resourceValues(forKeys: [.isDirectoryKey])

                    if let isdir = res.isDirectory, isdir {
                        let spoken = try SpokenDoc(from: url)
                        self.transcriptionDataSource.data = spoken
                        self.transcribedTextView.string = spoken.formattedString
                        self.wordTableView.reloadData()
                    } else {
                        let sourceText = try String(contentsOf: url, encoding: .utf8)
                        self.sourceTextView.string = sourceText
                        self.textInputField.stringValue = url.path
                    }
                } catch let err {
                    let alert = NSAlert(error: err)
                    alert.runModal()
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
        
        let req = SFSpeechURLRecognitionRequest(url: url)
        req.taskHint = .dictation
        req.shouldReportPartialResults = true
        
        self.activityIndicator.startAnimation(sender)
        
        self.recognizer.recognitionTask(with: req) { (result, error) in
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

            let best : SFTranscription = result.bestTranscription
            self.transcribedTextView.string = best.formattedString
            self.transcriptPopup.isEnabled = true
            self.transcriptions = result.transcriptions.map { trans in
                SpokenDoc(trans)
            }
            
            self.transcriptPopup.removeAllItems()
            for (i, _) in self.transcriptions.enumerated() {
                self.transcriptPopup.addItem(withTitle: "\(i)")
            }
            
            // Adjust timeline slider range
            self.timeLineSlider.isEnabled = true
            guard let lastSeg = best.segments.last else {
                return
            }
            
            self.timeLineSlider.maxValue = lastSeg.timestamp + lastSeg.duration
            self.timeLineSlider.doubleValue = 0.0
            if self.transcribedTextView.delegate == nil {
                self.transcribedTextView.delegate = self
            }
            
            if result.isFinal {
                self.transcriptionDataSource.data = SpokenDoc(best)
                self.wordTableView.reloadData()
                self.activityIndicator.stopAnimation(nil)
            }
        }
        
    }
    
    // Switch to showing a different transcript interpreted from the voice
    @IBAction func changeTranscript(_ sender: NSPopUpButton) {
        let trans = self.transcriptions[sender.indexOfSelectedItem]
        self.transcribedTextView.string = trans.formattedString
    }
    
    @IBAction func moveInsideClip(_ slider: NSSlider) {
        let t = slider.doubleValue
        self.clipTimeField.doubleValue = t
        
        let trans = self.transcriptions[transcriptPopup.indexOfSelectedItem]
        
        var charPos = 0
        for word in trans.words {
            if t < word.timestamp + word.timestamp {
                break
            }
            charPos += word.text.count
        }
        self.transcribedTextView.setSelectedRange(NSRange(0..<charPos))
    }
    
    @IBAction func changeSpokenWord(_ sender: Any) {
        let i = self.wordTableView.selectedRow
        if i < 0 { return }
        
        let trans = self.transcriptions[transcriptPopup.indexOfSelectedItem]
        trans.words[i].text = self.changeWordField.stringValue
        
        self.transcriptionDataSource.data = trans
        self.wordTableView.reloadData()
        
        self.transcribedTextView.string = trans.formattedString
    }
    
    @IBAction func removeSpokenWord(_ button: NSButton) {
    }
    
    func indexOfSelectedWord() -> Int? {
        guard let txtView = self.transcribedTextView else {
            return nil
        }
        
        let trans = self.transcriptions[transcriptPopup.indexOfSelectedItem]
        
        let selection : NSRange = txtView.selectedRange()
        var pos = 0
        for (i, word) in trans.words.enumerated() {
            let r = NSRange(location: pos, length: word.text.count)
            if r.contains(selection.location) {
                return i
            }
            pos += word.text.count + 1
        }
        return nil
    }
    
    // MARK: NSTextViewDelegate
    func textViewDidChangeSelection(_ notification: Notification) {
        guard let i = self.indexOfSelectedWord() else { return }
        let trans = self.transcriptions[transcriptPopup.indexOfSelectedItem]
        let word = trans.words[i]
            
        self.timeLineSlider.doubleValue = word.timestamp
        self.clipTimeField.doubleValue = word.timestamp
        self.wordTableView.selectRowIndexes(IndexSet(integer: i), byExtendingSelection: false)
        DispatchQueue.main.async {
            self.wordTableView.scrollRowToVisible(self.wordTableView.selectedRow)
        }
    }
    
    @IBAction func saveAs(_ sender: Any) {
        let panel = NSSavePanel()
        
        panel.canCreateDirectories = true
        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory())
        panel.beginSheetModal(for: window!) { response in
            if response == .OK {
                guard let url = panel.url else {
                    let alert = NSAlert()
                    alert.messageText = "Could not get save location"
                    alert.runModal()
                    return
                }
                
                do {
                    try self.transcriptionDataSource.data.write(to: url)
                } catch let err {
                    let alert = NSAlert(error: err)
                    alert.runModal()
                }
            }
        }
    }
    
}
