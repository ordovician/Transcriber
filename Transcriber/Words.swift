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
    var words : [WrittenWord] = []
    var tags : [Tag] = []
}

//class AlignedDoc {
//    var spokenWords : [SpokenWord]
//    var writtenWords : [WrittenWord]
//    var tags : [Tag] = []
//}
