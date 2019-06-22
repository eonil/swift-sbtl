//
//  BinarySearchProtocol.swift
//  SBTL
//
//  Created by Henry on 2019/06/22.
//

import Foundation

protocol BinarySearchProtocol {
    associatedtype Element
    associatedtype Index
    func index<C>(of: C, with: (Element) -> C) -> Index? where C: Comparable
    func indexToPlace<C>(_: C, with: (Element) -> C) -> Index where C: Comparable
}
extension BinarySearchProtocol {
    func contains<C>(_ x: C, with m: (Element) -> C) -> Bool where C: Comparable {
        return index(of: x, with: m) != nil
    }
}
extension BinarySearchProtocol where Element: Comparable {
    func contains(_ e: Element) -> Bool {
        return index(of: e) != nil
    }
    func index(of e: Element) -> Index? {
        return index(of: e, with: {$0})
    }
    func indexToPlace(_ e: Element) -> Index {
        return indexToPlace(e, with: {$0})
    }
}

protocol TreeBinarySearchProtocol {
    associatedtype Element
    associatedtype Index
    typealias IndexAndElement = (index: Index, element: Element)
    @inlinable
    func indexAndElement<C>(of: C, with: (Element) -> C) -> IndexAndElement? where C: Comparable
}
extension TreeBinarySearchProtocol where Element: Comparable {
    func indexAndElement(of e: Element) -> IndexAndElement? {
        return indexAndElement(of: e, with: {$0})
    }
}
extension TreeBinarySearchProtocol where Self: BinarySearchProtocol {
    func index<C>(of e: C, with m: (Element) -> C) -> Index? where C: Comparable {
        return indexAndElement(of: e, with: m)?.index
    }
}

