//
//  INSERT_INTOTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Foundation
import Testing
import Squeal


struct INSERT_INTOTests {
    
    
    @Test
    func INSERT_INTO_singleValue() {
        let query = SQL
            .INSERT(INTO: users, columns: \.name,
                    VALUES: "John")
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? String == "John")
        #expect(query.query == "INSERT INTO users (name) VALUES ($1)")
        #expect("\(query)" == "INSERT INTO users (name) VALUES ('John')")
    }
    
    @Test
    func INSERT_INTO() {
        let query = SQL
            .INSERT(INTO: users,
                    columns: \.id, \.name,
                    VALUES: 12, "Jim")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? Int == 12)
        #expect(query.parameters[1] as? String == "Jim")
        #expect(query.query == "INSERT INTO users (id, name) VALUES ($1, $2)")
        #expect("\(query)" == "INSERT INTO users (id, name) VALUES (12, 'Jim')")
    }
    
    @available(macOS 14.0.0, *)
    @Test
    func testINSERT_INTO_multiple_values() {
        let peopleArray = [
            Person(firstname: "John", lastname: "Doe"),
            Person(firstname: "Ada", lastname: "Lovelace"),
            Person(firstname: "Alan", lastname: "Turing"),
        ]
        let query = SQL
            .INSERT(INTO: people, columns: \.firstname, \.lastname)
            .VALUES(peopleArray[0].firstname, peopleArray[0].lastname)
            .VALUES(peopleArray[1].firstname, peopleArray[1].lastname)
            .VALUES(peopleArray[2].firstname, peopleArray[2].lastname)
        
        #expect(query.parameters.count == 6)
        #expect(query.parameters[0] as? String == "John")
        #expect(query.parameters[1] as? String == "Doe")
        #expect(query.parameters[2] as? String == "Ada")
        #expect(query.parameters[3] as? String == "Lovelace")
        #expect(query.parameters[4] as? String == "Alan")
        #expect(query.parameters[5] as? String == "Turing")
        #expect(query.query == "INSERT INTO people (firstname, lastname) VALUES ($1, $2), ($3, $4), ($5, $6)")
        #expect("\(query)" == "INSERT INTO people (firstname, lastname) VALUES ('John', 'Doe'), ('Ada', 'Lovelace'), ('Alan', 'Turing')")
    }
    
    @available(macOS 14.0.0, *)
    @Test
    func INSERT_INTO_multiple_valuesLoop() {
        let peopleArray = [
            Person(firstname: "John", lastname: "Doe"),
            Person(firstname: "Ada", lastname: "Lovelace"),
            Person(firstname: "Alan", lastname: "Turing"),
        ]
        var query = SQL
            .INSERT(INTO: people, columns: \.firstname, \.lastname)
        
        for p in peopleArray {
            query.ADDVALUES(p.firstname, p.lastname)
        }
        #expect("\(query)" == "INSERT INTO people (firstname, lastname) VALUES ('John', 'Doe'), ('Ada', 'Lovelace'), ('Alan', 'Turing')")
    }
    
    @Test
    func failingInsertInto() {
        let study = Study(id: nil, name: "April", startingCash: 2500.12, partitioning: 100, prolificStudyId: nil, completionLink: nil, showsResults: false, allowsFractionalInvesting: true)
        let studies = StudiesTable()
        let query = SQL
            .INSERT(INTO: studies,
                    columns: \.name, \.starting_cash, \.partitioning, \.prolific_study_id, \.completion_link, \.shows_results, \.allows_fractional_investing,
                    VALUES: study.name, study.startingCash, study.partitioning, study.prolificStudyId, study.completionLink, study.showsResults, study.allowsFractionalInvesting)
            .RETURNING(\.id)
        
        #expect(query.parameters.count == 7)
        #expect(query.parameters[0] as? String == "April")

        if let d = query.parameters[1] as? Double {
            #expect(d == 2500.12)
        } else {
            Issue.record("Couldn't parse double")
        }
        if let d = query.parameters[2] as? Double {
            #expect(d == 100)
        } else {
            Issue.record("Couldn't parse double")
        }
        #expect(query.parameters[3] == nil)
        #expect(query.parameters[4] == nil)
        #expect(query.parameters[5] as? Bool == false)
        #expect(query.parameters[6] as? Bool == true)
        
        #expect(query.query == "INSERT INTO studies (name, starting_cash, partitioning, prolific_study_id, completion_link, shows_results, allows_fractional_investing) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id")
    }
    
    @Test
    func INSERT_INTO_Map() {
        let peopleArray  = [
            Person(firstname: "John", lastname: "Doe"),
            Person(firstname: "Ada", lastname: "Lovelace"),
            Person(firstname: "Alan", lastname: "Turing"),
        ]
        let query = SQL
            .INSERT(INTO: people, columns: \.firstname, \.lastname,
                    addValuesFrom: peopleArray) { p in
                (p.firstname, p.lastname)
            }
        #expect("\(query)" == "INSERT INTO people (first_name, last_name) VALUES ('John', 'Doe'), ('Ada', 'Lovelace'), ('Alan', 'Turing')")
    }
}


struct Person {
    let firstname: String
    let lastname: String
}


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
