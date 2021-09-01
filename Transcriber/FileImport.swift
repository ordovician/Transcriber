//
//  FileImport.swift
//  Transcriber
//
//  Created by Erik Engheim on 01/09/2021.
//

import Foundation

extension SpokenDoc {
    
    convenience init(from url: URL) throws {
        let timestampFile = url.appendingPathComponent("timestamps.csv")
        let txt = try String(contentsOf: url.appendingPathComponent("transcript.txt"),
                             encoding: .utf8)
        let table = try String(contentsOf: timestampFile,
                              encoding: .utf8)
        
        var words : [SpokenWord] = []
        
        let lines = table.split(separator: "\n")
        for line in lines {
            let parts = line.split(separator: ",", omittingEmptySubsequences: false)
            if let loc = Int(parts[0]),
               let len = Int(parts[1]),
               let t = Float64(parts[2]),
               let dt = Float64(parts[3])
            {
                let i = txt.index(txt.startIndex, offsetBy: loc)
                let j = txt.index(i, offsetBy: len)
                let w = txt[i..<j]
                let word = SpokenWord(text: String(w), timestamp: t, duration: dt)
                words.append(word)
            }
        }
        self.init(words: words)
    }
}

extension WrittenDoc {
    convenience init(from url: URL) throws {
        let txt = try String(contentsOf: url.appendingPathComponent("original.txt"),
                             encoding: .utf8)
        
        var words : [WrittenWord] = []
        var tags : [Tag] = []
        
        var i = 0
        let ws = txt.split() { ch in ch.isWhitespace}
        for var w in ws {
            if w.hasSuffix(":") {
                w.removeLast()
            }
            
            if w.hasPrefix(":") {
                w.removeFirst()
                tags.append(Tag(name: String(w), index: i))
            } else {
                words.append(WrittenWord(text: String(w)))
                i += 1
            }
        }
        
        self.init(words: words, tags: tags)
    }
}
