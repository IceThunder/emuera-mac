//
//  WordCollection.swift
//  Emuera
//
//  Created by IceThunder on 2025/12/19.
//

/// Collection of words with pointer for sequential access
public final class WordCollection {
    private static let nullToken = NullWord()

    public var collection: [Word] = []
    public var pointer: Int = 0

    public init() {}

    public init(_ words: [Word]) {
        self.collection = words
    }

    public func add(_ token: Word) {
        collection.append(token)
    }

    public func add(_ wc: WordCollection) {
        collection.append(contentsOf: wc.collection)
    }

    public func clear() {
        collection.removeAll()
        pointer = 0
    }

    public func shiftNext() {
        pointer += 1
    }

    public var current: Word {
        if pointer >= collection.count {
            return WordCollection.nullToken
        }
        return collection[pointer]
    }

    public var eol: Bool {
        return pointer >= collection.count
    }

    public func insert(_ word: Word) {
        collection.insert(word, at: pointer)
    }

    public func insertRange(_ wc: WordCollection) {
        collection.insert(contentsOf: wc.collection, at: pointer)
    }

    public func remove() {
        guard pointer < collection.count else { return }
        collection.remove(at: pointer)
    }

    public func setAsMacro() {
        for word in collection {
            word.setAsMacro()
        }
    }

    public func clone() -> WordCollection {
        let ret = WordCollection()
        ret.collection = collection.map { $0 }  // Shallow copy
        ret.pointer = pointer
        return ret
    }

    public func clone(start: Int, count: Int) -> WordCollection {
        let ret = WordCollection()
        guard start < collection.count else { return ret }

        let end = min(start + count, collection.count)
        ret.collection = Array(collection[start..<end])
        return ret
    }
}
