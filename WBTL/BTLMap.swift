//
//  BTLMap.swift
//  WBTL
//
//  Created by Henry on 2019/06/19.
//

public struct BTLMap<Key,Value>:
RandomAccessCollection,
ExpressibleByDictionaryLiteral where
Key: Comparable {
    private typealias W = BTLEmptyWeightValueWrapper<Value>
    private var impl = WBTLMap<Key,W>()

    public init() {}
    public init(dictionaryLiteral elements: (Key, Value)...) {
        for (k,v) in elements {
            impl[k] = W(v)
        }
    }

    public var startIndex: Int {
        return impl.startIndex
    }
    public var endIndex: Int {
        return impl.endIndex
    }
    public subscript(_ i: Int) -> (key: Key, value: Value) {
        let (k,v) = impl[i]
        return (k,v.value)
    }
    public subscript(_ k: Key) -> Value? {
        get { return impl[k]?.value }
        set(v) { impl[k] = v == nil ? nil : W(v!) }
    }

    public struct Keys: RandomAccessCollection {
        private var impl: WBTLMap<Key,W>.Keys
        public var startIndex: Int {
            return impl.startIndex
        }
        public var endIndex: Int {
            return impl.endIndex
        }
        public func firstIndex(of k: Key) -> Int? {
            return impl.firstIndex(of: k)
        }
        public subscript(_ i: Int) -> Key {
            return impl[i]
        }
    }
    public struct Values: RandomAccessCollection {
        private var impl: WBTLMap<Key,W>.Values
        public var startIndex: Int {
            return impl.startIndex
        }
        public var endIndex: Int {
            return impl.endIndex
        }
        public subscript(_ i: Int) -> Value {
            return impl[i].value
        }
    }
}
