//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal


@available(macOS 14.0.0, *)
final class DELETETests: XCTestCase {
    
    let users = UsersTable()
    
    func testDelete() {
        let query = SQL
            .DELETE_FROM(users)
            .WHERE(\.id == 243)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 243)
        XCTAssertEqual(query.query, "DELETE FROM users WHERE id = $1")
        XCTAssertEqual("\(query)", "DELETE FROM users WHERE id = 243")
    }
}
