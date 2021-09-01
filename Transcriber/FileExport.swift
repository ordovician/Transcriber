//
//  FileExport.swift
//  Transcriber
//
//  Created by Erik Engheim on 29/06/2021.
//

import Foundation
import Speech

extension SpokenDoc {
    
    var formattedString : String {
        self.words.reduce("") { (result, word) in
            result + word.text + " "
        }
    }
    
    func write(to url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        
        let txtFile = url.appendingPathComponent("transcript.txt")
        let timestampFile = url.appendingPathComponent("timestamps.csv")
        
        try self.formattedString.write(to: txtFile, atomically: true, encoding: .utf8)

        var timeTxt = "location,length,timestamp,duration\n"
        var i = 0
        for seg in self.words {
            let t = seg.timestamp
            let dt = seg.duration
            timeTxt.append(String(format: "%d,%d,%.2f,%.2f\n", i, seg.text.count, t, dt))
            i += seg.text.count + 1
        }
        
        try timeTxt.write(to: timestampFile, atomically: true, encoding: .utf8)
    }
}

extension AlignedDoc {
    func write(to url: URL) throws {
        
    }
    
    var spokenText : String {
        let words = self.spokenWords.compactMap { word in
            word?.text
        }
        return words.joined(separator: " ")
    }
    
    var writtenText : String {
        let words = self.writtenWords.compactMap { word in
            word?.text
        }
        return words.joined(separator: " ")
    }
}

