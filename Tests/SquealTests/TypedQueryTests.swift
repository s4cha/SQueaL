//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal


@available(macOS 14.0.0, *)
final class TypedQueryTests: XCTestCase {
    
    let users = UsersTable()
    let trades = TradesTable()
    
    func testSelect1Column() {
        let query = SQL
            .SELECT(\.id, FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id FROM users")
        XCTAssertEqual("\(query)", "SELECT id FROM users")
    }
    
    func testSelect2Columns() {
        let query = SQL
            .SELECT(\.id, \.name, FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id, name FROM users")
        XCTAssertEqual("\(query)", "SELECT id, name FROM users")
    }
    
    func testSelect3Columns() {
        let query = SQL
            .SELECT([users.uuid, users.id, users.name], FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT uuid, id, name FROM users")
        XCTAssertEqual("\(query)", "SELECT uuid, id, name FROM users")
    }
    
    func testSelectStringColumns() {
        let query = SQL
            .SELECT("uuid, id, name", FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT uuid, id, name FROM users")
        XCTAssertEqual("\(query)", "SELECT uuid, id, name FROM users")
    }
    
    func testSelectVariadicColumns() {
        let query = SQL
            .SELECT(\.uuid, \.id, \.name, FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT uuid, id, name FROM users")
        XCTAssertEqual("\(query)", "SELECT uuid, id, name FROM users")
    }
    
    func testWhereInt() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.id == 1)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id = $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id = 1")
    }
    
    func testWhereString() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.name == "Ada")
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? String == "Ada")
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE name = $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE name = 'Ada'")
    }
    
    
    func testWHEREqualSign() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.id == 1)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id = $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id = 1")
    }
    
    func testWHEREANDEqualSign() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.id == 1)
            .AND(\.name == "Jack")
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssert(query.parameters[1] as? String == "Jack")
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id = $1 AND name = $2")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id = 1 AND name = 'Jack'")
    }
    
    func testSelectTypesShortKeypath() {
        let query = SQL
            .SELECT(\.name, FROM: users)
        XCTAssert(query.parameters.isEmpty)
        XCTAssertEqual(query.query, "SELECT name FROM users")
        XCTAssertEqual("\(query)", "SELECT name FROM users")
    }
    
    func testWhereTypeSafeInt() throws {
        let query = SQL
            .SELECT(.all, FROM: users)
            .WHERE(\.id == 1)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE id = $1")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 1")
    }
    
    func testWhereTypeSafeString() throws {
        let query = SQL
            .SELECT(.all, FROM: users)
            .WHERE(\.name == "Alice")
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? String == "Alice")
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE name = $1")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE name = 'Alice'")
    }
    
    func testWhereTypeSafeUUID() throws {
        let uuid = UUID(uuidString: "5DC4AC7B-37C1-4472-B1F6-974B79624FE5")!
        let query = SQL
            .SELECT(.all, FROM: users)
            .WHERE(\.uuid == uuid)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? UUID == UUID(uuidString: "5DC4AC7B-37C1-4472-B1F6-974B79624FE5")!)
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE uuid = $1")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE uuid = '5DC4AC7B-37C1-4472-B1F6-974B79624FE5'")
    }
    
    func testAndTypeSafe() throws {
        let query = SQL
            .SELECT(.all, FROM: users)
            .WHERE(\.id == 1)
            .AND(\.name == "jack")
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssert(query.parameters[1] as? String == "jack")
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE id = $1 AND name = $2")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 1 AND name = 'jack'")
    }
    
    func testDelete() {
        let query = SQL
            .DELETE(FROM: users)
            .WHERE(\.id == 243)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 243)
        XCTAssertEqual(query.query, "DELETE FROM users WHERE id = $1")
        XCTAssertEqual("\(query)", "DELETE FROM users WHERE id = 243")
    }
    
    func testUpdate() {
        let query = SQL
            .UPDATE(users, SET: \.name, value: "john")
            .WHERE(\.id == 12)
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? String == "john")
        XCTAssert(query.parameters[1] as? Int == 12)
        XCTAssertEqual(query.query, "UPDATE users SET name = $1 WHERE id = $2")
        XCTAssertEqual("\(query)", "UPDATE users SET name = 'john' WHERE id = 12")
    }
    
    func testINSERT_INTO_singleValue() {
        let query = SQL
            .INSERT(INTO: users, columns: \.name,
                    VALUES: "John")
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? String == "John")
        XCTAssertEqual(query.query, "INSERT INTO users (name) VALUES ($1)")
        XCTAssertEqual("\(query)", "INSERT INTO users (name) VALUES ('John')")
    }
    
    func testINSERT_INTO() {
        let query = SQL
            .INSERT(INTO: users, columns: \.id, \.name,
                    VALUES: 12, "Jim")
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? Int == 12)
        XCTAssert(query.parameters[1] as? String == "Jim")
        XCTAssertEqual(query.query, "INSERT INTO users (id, name) VALUES ($1, $2)")
        XCTAssertEqual("\(query)", "INSERT INTO users (id, name) VALUES (12, 'Jim')")
    }
    
    @available(macOS 14.0.0, *)
    func testINSERT_INTO_multiple_values() {
        let people = [
            Person(firstname: "John", lastname: "Doe"),
            Person(firstname: "Ada", lastname: "Lovelace"),
            Person(firstname: "Alan", lastname: "Turing"),
        ]
        let query = SQL
            .INSERT(INTO: PersonTable(), columns: \.firstname, \.lastname)
            .VALUES(people[0].firstname, people[0].lastname)
            .VALUES(people[1].firstname, people[1].lastname)
            .VALUES(people[2].firstname, people[2].lastname)
        
        XCTAssertEqual(query.parameters.count, 6)
        XCTAssert(query.parameters[0] as? String == "John")
        XCTAssert(query.parameters[1] as? String == "Doe")
        XCTAssert(query.parameters[2] as? String == "Ada")
        XCTAssert(query.parameters[3] as? String == "Lovelace")
        XCTAssert(query.parameters[4] as? String == "Alan")
        XCTAssert(query.parameters[5] as? String == "Turing")
        XCTAssertEqual(query.query, "INSERT INTO people (first_name, last_name) VALUES ($1, $2), ($3, $4), ($5, $6)")
        XCTAssertEqual("\(query)", "INSERT INTO people (first_name, last_name) VALUES ('John', 'Doe'), ('Ada', 'Lovelace'), ('Alan', 'Turing')")
    }
    
    @available(macOS 14.0.0, *)
    func testINSERT_INTO_multiple_valuesLoop() {
        let people = [
            Person(firstname: "John", lastname: "Doe"),
            Person(firstname: "Ada", lastname: "Lovelace"),
            Person(firstname: "Alan", lastname: "Turing"),
        ]
        var query = SQL
            .INSERT(INTO: PersonTable(), columns: \.firstname, \.lastname)
        
        
        for p in people {
            query.ADDVALUES(p.firstname, p.lastname)
        }
        XCTAssertEqual("\(query)", "INSERT INTO people (first_name, last_name) VALUES ('John', 'Doe'), ('Ada', 'Lovelace'), ('Alan', 'Turing')")
    }
    
    func testFailingInsertInto() {
        let study = Study(id: nil, name: "April", startingCash: 2500.12, partitioning: 100, prolificStudyId: nil, completionLink: nil, showsResults: false, allowsFractionalInvesting: true)
        let studies = StudiesTable()
        let query = SQL.INSERT(INTO: studies,
                columns: \.name, \.starting_cash, \.partitioning, \.prolific_study_id, \.completion_link, \.shows_results, \.allows_fractional_investing,
                VALUES: study.name, study.startingCash, study.partitioning, study.prolificStudyId, study.completionLink, study.showsResults, study.allowsFractionalInvesting)
        .RETURNING(\.id)
        
        XCTAssertEqual(query.parameters.count, 7)
        XCTAssert(query.parameters[0] as? String == "April")

        if let d = query.parameters[1] as? Double {
            XCTAssertEqual(d, 2500.12)
        } else {
            XCTFail("Couldn't parse double")
        }
        if let d = query.parameters[2] as? Double {
            XCTAssertEqual(d, 100)
        } else {
            XCTFail("Couldn't parse double")
        }
        XCTAssert(query.parameters[3] == nil)
        XCTAssert(query.parameters[4] == nil)
        XCTAssert(query.parameters[5] as? Bool == false)
        XCTAssert(query.parameters[6] as? Bool == true)
        
        XCTAssertEqual(query.query,"INSERT INTO studies (name, starting_cash, partitioning, prolific_study_id, completion_link, shows_results, allows_fractional_investing) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id")
    }
    
    func testINSERT_INTO_Map() {
        let people = [
            Person(firstname: "John", lastname: "Doe"),
            Person(firstname: "Ada", lastname: "Lovelace"),
            Person(firstname: "Alan", lastname: "Turing"),
        ]
        
        let query = SQL
            .INSERT(INTO: PersonTable(), columns: \.firstname, \.lastname,
                    addValuesFrom: people) { p in
                (p.firstname, p.lastname)
            }
        XCTAssertEqual("\(query)", "INSERT INTO people (first_name, last_name) VALUES ('John', 'Doe'), ('Ada', 'Lovelace'), ('Alan', 'Turing')")
    }
        
}


struct Person {
    let firstname: String
    let lastname: String
}

struct UsersTable: Table {
    let tableName = "users"
    let uuid = Field<UUID>(name: "uuid")
    let id = Field<Int>(name: "id")
    let name = Field<String>(name: "name")
}

struct PersonTable: Table {
    var tableName: String = "people"
    let firstname = Field<String>(name: "first_name")
    let lastname = Field<String>(name: "last_name")
}

struct TradesTable: Table {
    let tableName = "trades"
    let user_id = Field<UUID>(name: "user_id")
    let study_id = Field<UUID>(name: "study_id")
    let type = Field<String>(name: "type")
}

struct StudiesTable: Table {
    let tableName = "studies"
        
    let id = Field<UUID>(name: "id")
    let prolific_study_id = Field<String?>(name: "prolific_study_id")
    let name = Field<String>(name: "name")
    let starting_cash = Field<Double>(name: "starting_cash")
    let partitioning = Field<Double>(name: "partitioning")
    let completion_link = Field<String?>(name: "completion_link")
    let shows_results = Field<Bool>(name: "shows_results")
    let allows_fractional_investing = Field<Bool>(name: "allows_fractional_investing")
}

// Rename SQLQuery to just SQL
// Typed -> TSQL
// RM Bare API alltogether ?


struct Study {
    let id: UUID?
    let name: String
    let startingCash: Double
    let partitioning: Double
    let prolificStudyId: String?
    let completionLink: String?
    let showsResults: Bool
    let allowsFractionalInvesting: Bool
//    var stocks: [Stock]?
}


// TODO
// Where =  like NULL NOT NULL
// OR
// Group by
// Order By / ASC DESC NULL NOT NULL
// Having
// UPDATE SET
