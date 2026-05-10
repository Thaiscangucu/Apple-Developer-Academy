//
//  Array.swift
//  FisioterApp
//
//  Created by Thais Cangucu on 15/04/26.
//

import Foundation

extension Array where Element: Equatable {
    func firstIndex(of sequence: [Element]) -> Int? {
        guard sequence.count <= self.count else { return nil }
        for i in 0...(self.count - sequence.count) {
            if Array(self[i..<(i + sequence.count)]) == sequence {
                return i
            }
        }
        return nil
    }
}
