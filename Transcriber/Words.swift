//
//  Spoken.swift
//  Transcriber
//
//  Created by Erik Engheim on 26/08/2021.
//

import Foundation
import Speech

protocol Word {
    var text : String { get set }
}

struct SpokenWord : Word {
    var text : String = ""
    var timestamp : Float64 = 0
    var duration : Float64 = 0
    
    init(_ seg : SFTranscriptionSegment) {
        self.text = seg.substring
        self.timestamp = seg.timestamp
        self.duration = seg.duration
    }
    
    init(text: String, timestamp: Float64, duration: Float64) {
        self.text = text
        self.timestamp = timestamp
        self.duration = duration
    }
}

class SpokenDoc {
    var words : [SpokenWord] = []
    
    init() {
        self.words = []
    }
    
    init(_ trans : SFTranscription) {
        self.words = trans.segments.map { seg in
            SpokenWord(seg)
        }
    }
    
    init(words: [SpokenWord]) {
        self.words = words
    }
    
}

struct Tag {
    var name : String
    var index : Int
    
    init(name : String, index : Int) {
        self.name = name
        self.index = index
    }
}

struct WrittenWord : Word {
    var text : String = ""
}


func ==(s : Word, t : Word) -> Bool {
    return s.text == t.text
}

class WrittenDoc {
    var words : [WrittenWord]
    var tags : [Tag]
    
    init(words: [WrittenWord], tags: [Tag]) {
        self.words = words
        self.tags = tags
    }
    
    init() {
        self.words = []
        self.tags = []
    }
}

class AlignedDoc {
    var spokenWords : [SpokenWord?]
    var writtenWords : [WrittenWord?]
    var tags : [Tag] = []
    
    var spokenDoc: SpokenDoc {
        let spokens = spokenWords.compactMap { word in
            word
        }
        return SpokenDoc(words: spokens)
    }
    
    var count : Int {
        assert(self.spokenWords.count == self.writtenWords.count)
        return self.spokenWords.count
    }
    
    init(spokenWords: [SpokenWord?], writtenWords: [WrittenWord?]) {
        self.spokenWords = spokenWords
        self.writtenWords = writtenWords
        
    }
    
    init() {
        self.spokenWords = []
        self.writtenWords = []
    }
}
