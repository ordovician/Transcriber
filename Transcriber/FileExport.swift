//
//  FileExport.swift
//  Transcriber
//
//  Created by Erik Engheim on 29/06/2021.
//

import Foundation
import Speech

extension SFTranscription {
    func write(to url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        
        let txtFile = url.appendingPathComponent("transcript.txt")
        let timestampFile = url.appendingPathComponent("timestamps.csv")
        
        try self.formattedString.write(to: txtFile, atomically: true, encoding: .utf8)

        var timeTxt = "location,length,timestamp,duration\n"
        for seg in self.segments {
            let r  = seg.substringRange
            let t = seg.timestamp
            let dt = seg.duration
            timeTxt.append(String(format: "%d,%d,%.2f,%.2f\n", r.location, r.length, t, dt))
//            timeTxt.append("\(r.location), \(r.length), \(t), \(dt)\n")
        }
        
        try timeTxt.write(to: timestampFile, atomically: true, encoding: .utf8)
    }
}

