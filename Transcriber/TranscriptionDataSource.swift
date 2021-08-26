//
//  TranscriptionDataSource.swift
//  Transcriber
//
//  Created by Erik Engheim on 28/06/2021.
//

import Cocoa
//import Speech

class TranscriptionDataSource: NSObject, NSTableViewDataSource {
    var data : SpokenDoc = SpokenDoc()
//    var dummy = ["alpha", "beta", "gamma", "zeta"]
    func numberOfRows(in tableView: NSTableView) -> Int {
//        return data.segments.count
        return data.words.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor column: NSTableColumn?, row: Int) -> Any? {
        guard let col = column else {
            return nil
        }
        
        let word = data.words[row]
        
        switch String(col.identifier.rawValue) {
        case "word":
            return word.text
        case "timestamp":
            return word.timestamp
        case "duration":
            return word.duration
        default:
            return nil
        }
    }
}
