//
//  BTLMap.swift
//  SBTL
//
//  Created by Henry on 2019/06/19.
//

public struct BTLMap<Key,Value>:
RandomAccessCollection,
ExpressibleByDictionaryLiteral where
Key: Comparable
{
    typealias W = BTLEmptySumValueWrapper<Value>
    private var impl = SBTLMap<Key,W>()

    public init() {}
    public init(dictionaryLiteral elements: (Key, Value)...) {
        for (k,v) in elements {
            impl[k] = W(v)
        }
    }
}
public extension BTLMap {
    typealias Index = Int
    var startIndex: Int {
        return impl.startIndex
    }
    var endIndex: Int {
        return impl.endIndex
    }
    subscript(_ i: Int) -> (key: Key, value: Value) {
        let (k,v) = impl.element(at: i)
        return (k,v.value)
    }
    subscript(_ k: Key) -> Value? {
        get { return impl[k]?.value }
        set(v) { impl[k] = v == nil ? nil : W(v!) }
    }
}

public extension BTLMap {
    var keys: Keys {
        return Keys(impl: impl.keys)
    }
    struct Keys: RandomAccessCollection {
        private(set) var impl: SBTLMap<Key,W>.Keys
    }
    var values: Values {
        return Values(impl: impl.values)
    }
    struct Values: RandomAccessCollection {
        private(set) var impl: SBTLMap<Key,W>.Values
    }
}
public extension BTLMap.Keys {
    var startIndex: Int {
        return impl.startIndex
    }
    var endIndex: Int {
        return impl.endIndex
    }
    func firstIndex(of k: Key) -> Int? {
        return impl.firstIndex(of: k)
    }
    subscript(_ i: Int) -> Key {
        return impl[i]
    }
}
public extension BTLMap.Values {
    var startIndex: Int {
        return impl.startIndex
    }
    var endIndex: Int {
        return impl.endIndex
    }
    subscript(_ i: Int) -> Value {
        return impl[i].value
    }
}
