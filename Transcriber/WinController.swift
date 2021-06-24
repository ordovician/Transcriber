//
//  WinController.swift
//  Transcriber
//
//  Created by Erik Engheim on 24/06/2021.
//

import Cocoa

class WinController: NSWindowController {

    @IBOutlet weak var transcribedTextView: NSTextView!
    @IBOutlet weak var sourceTextView: NSTextView!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func record(sender: AnyObject) {
        
    }
    
    @IBAction func pause(sender: AnyObject) {
        
    }

    @IBAction func stop(sender: AnyObject) {
        
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
