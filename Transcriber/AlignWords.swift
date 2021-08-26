//
//  AlignWords.swift
//  Transcriber
//
//  Created by Erik Engheim on 26/08/2021.
//

import Foundation

let gapcost = -1

func score(_ v : WrittenWord, _ w : SpokenWord) -> Int {
    if v == w {
        return 2
    } else {
        return -2
    }
}

func align(writtenDoc : WrittenDoc, spokenDoc : SpokenDoc) {
    let vs = writtenDoc.words
    let ws = spokenDoc.words
    
    let m = vs.count
    let n = ws.count
    
    var D : Matrix<Int> = Matrix(rows: m+1, columns: n+1, defaultValue:0)
    
    // Initial fill
    for i in 1...n {
        D[0, i] = D[0, i-1] + gapcost
    }

    for j in 1...m {
        D[j, 0] = D[0, j-1] + gapcost
    }

    for i in 1...m {
        for j in 1...n {
            D[i, j] = max(
                D[i-1, j-1] + score(vs[i-1], ws[j-1]),
                D[i-1, j] + gapcost,
                D[i, j-1] + gapcost
             )
        }
    }
    
    // retrace
//    var i = m
//    var j = n
    
}
