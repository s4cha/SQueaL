//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal


@available(macOS 14.0.0, *)
final class HAVINGTests: XCTestCase {
    
    let users = UsersTable()
    
    func testHavingafterSELECT() throws {
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
            .GROUP_BY(\.name)
            .HAVING("COUNT(*) > 500")
            
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT name FROM users GROUP BY name HAVING COUNT(*) > 500")
        XCTAssertEqual("\(query)", "SELECT name FROM users GROUP BY name HAVING COUNT(*) > 500")
    }
}

