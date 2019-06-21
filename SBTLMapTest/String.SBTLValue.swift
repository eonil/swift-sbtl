//
//  String.SBTLValue.swift
//  SBTLMapTest
//
//  Created by Henry on 2019/06/21.
//

import Foundation
@testable import SBTL

extension String: SBTLValueProtocol {
    public var sum: Int {
        return 1
    }
}
