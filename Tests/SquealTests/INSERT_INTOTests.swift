//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal


@available(macOS 14.0.0, *)
final class INSERT_INTOTests: XCTestCase {
    
    let users = UsersTable()
    let trades = TradesTable()
    
    
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



// TODO
// Where =  like NULL NOT NULL
// OR
// Group by
// Order By / ASC DESC NULL NOT NULL
// Having
// UPDATE SET
