//
//  Int.SBTLValue.swift
//  SBTLMapTest
//
//  Created by Henry on 2019/06/21.
//

import Foundation
@testable import SBTL

extension Int: SBTLValueProtocol {
    public var sum: Int {
        return self
    }
}
