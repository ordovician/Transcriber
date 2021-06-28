//
//  Speech.swift
//  Transcriber
//
//  Created by Erik Engheim on 24/06/2021.
//

import Foundation
import Speech

//func transcribe(url:URL, resultHandler: @escaping (SFSpeechRecognitionResult?, Error?) -> Void) {
//    guard let reckognizer = SFSpeechRecognizer() else {
//      NSLog("A recognizer is not supported for the current locale") // TODO: Return proper error message
//      return
//    }
//
//    if !reckognizer.isAvailable {
//      NSLog("The recognizer is not available right now")
//      return
//    }
//
//    let request = SFSpeechURLRecognitionRequest(url: url)
//    reckognizer.recognitionTask(with: request, resultHandler: resultHandler)
//}
