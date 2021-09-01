//
//  TranscriptionDataSource.swift
//  Transcriber
//
//  Created by Erik Engheim on 28/06/2021.
//

import Cocoa
//import Speech

class AlignedDocDataSource: NSObject, NSTableViewDataSource {
    var doc : AlignedDoc = AlignedDoc()
//    var dummy = ["alpha", "beta", "gamma", "zeta"]
    func numberOfRows(in tableView: NSTableView) -> Int {
//        return data.segments.count
        return doc.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor column: NSTableColumn?, row: Int) -> Any? {
        guard let col = column else {
            return nil
        }
    
        let spoken = doc.spokenWords[row] ?? SpokenWord(text: "", timestamp: 0, duration: 0)
        let written = doc.writtenWords[row] ?? WrittenWord(text: "")
        switch String(col.identifier.rawValue) {
        case "spoken":
            return spoken.text
        case "written":
            return written.text
        case "timestamp":
            return spoken.timestamp
        case "duration":
            return spoken.duration
        default:
            return nil
        }
    }
}
