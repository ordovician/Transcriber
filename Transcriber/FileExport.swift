//
//  FileExport.swift
//  Transcriber
//
//  Created by Erik Engheim on 29/06/2021.
//

import Foundation
import Speech

func exportTranscript(transcript : SFTranscription, url : URL) throws {
    let txtFile = url.appendingPathComponent("transcript.txt")
    let timestampFile = url.appendingPathComponent("timestamps.csv")
    
    try transcript.formattedString.write(to: txtFile, atomically: true, encoding: .utf8)
    
    
}
