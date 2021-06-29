//
//  TranscriptionDataSource.swift
//  Transcriber
//
//  Created by Erik Engheim on 28/06/2021.
//

import Cocoa
import Speech

class TranscriptionDataSource: NSObject, NSTableViewDataSource {
    var data : SFTranscription = SFTranscription()
//    var dummy = ["alpha", "beta", "gamma", "zeta"]
    func numberOfRows(in tableView: NSTableView) -> Int {
//        return data.segments.count
        return data.segments.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor column: NSTableColumn?, row: Int) -> Any? {
        guard let col = column else {
            return nil
        }
        
        let seg = data.segments[row]
        
        switch String(col.identifier.rawValue) {
        case "word":
            return seg.substring
        case "position":
            return seg.substringRange.location
        case "length":
            return seg.substringRange.length
        case "timestamp":
            return Float(seg.timestamp)
        default:
            return nil
        }
    }
}
