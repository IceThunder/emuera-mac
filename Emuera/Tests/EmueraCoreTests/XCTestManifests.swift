//
//  XCTestManifests.swift
//  EmueraCoreTests
//
//  Test manifest for Swift Package Manager
//  Created on 2025-12-18
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(VariableTests.allTests),
        testCase(ErrorTests.allTests),
    ]
}
#endif