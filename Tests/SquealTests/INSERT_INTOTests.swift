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
        #expect("\(query)" == "INSERT INTO people (firstname, lastname) VALUES ('John', 'Doe'), ('Ada', 'Lovelace'), ('Alan', 'Turing')")
    }
    
    @Test
    func INSERTwithRETURNINGmultipleColumns() {
        let query = SQL
            .INSERT(INTO: users, columns: \.name,
                    VALUES: "Alice")
            .RETURNING(\.id, \.uuid)
        #expect(query.query == "INSERT INTO users (name) VALUES ($1) RETURNING id, uuid")
    }
    
    // MARK: - ON CONFLICT
    
    @Test
    func INSERT_ON_CONFLICT_DO_NOTHING_with_columns() {
        let query = SQL
            .INSERT(INTO: users, columns: \.id, \.name,
                    VALUES: 1, "Alice")
            .ON_CONFLICT(\.id, DO: .NOTHING)
        #expect(query.query == "INSERT INTO users (id, name) VALUES ($1, $2) ON CONFLICT (id) DO NOTHING")
        #expect(query.parameters.count == 2)
    }
    
    @Test
    func INSERT_ON_CONFLICT_DO_NOTHING_multiple_columns() {
        let query = SQL
            .INSERT(INTO: users_departments, columns: \.user_id, \.department_id,
                    VALUES: UUID(), UUID())
            .ON_CONFLICT(\.user_id, \.department_id, DO: .NOTHING)
        #expect(query.query == "INSERT INTO users_departments (user_id, department_id) VALUES ($1, $2) ON CONFLICT (user_id, department_id) DO NOTHING")
    }
    
    @Test
    func INSERT_ON_CONFLICT_DO_NOTHING_bare() {
        let query = SQL
            .INSERT(INTO: users, columns: \.id, \.name,
                    VALUES: 1, "Alice")
            .ON_CONFLICT(DO: .NOTHING)
        #expect(query.query == "INSERT INTO users (id, name) VALUES ($1, $2) ON CONFLICT DO NOTHING")
    }
    
    @Test
    func INSERT_ON_CONFLICT_ON_CONSTRAINT_DO_NOTHING() {
        let query = SQL
            .INSERT(INTO: users, columns: \.id, \.name,
                    VALUES: 1, "Alice")
            .ON_CONFLICT(ON_CONSTRAINT: "users_pkey",  DO: .NOTHING)
        #expect(query.query == "INSERT INTO users (id, name) VALUES ($1, $2) ON CONFLICT ON CONSTRAINT users_pkey DO NOTHING")
    }
    
    @Test
    func INSERT_ON_CONFLICT_DO_NOTHING_then_RETURNING() {
        let query = SQL
            .INSERT(INTO: users, columns: \.id, \.name,
                    VALUES: 1, "Alice")
            
            .ON_CONFLICT(\.id, DO: .NOTHING)
            .RETURNING(\.id)
        #expect(query.query == "INSERT INTO users (id, name) VALUES ($1, $2) ON CONFLICT (id) DO NOTHING RETURNING id")
    }
    
    @Test
    @available(macOS 14.0.0, *)
    func INSERT_lone_ON_CONFLICT_DO_NOTHING() {
        let peopleArray = [
            Person(firstname: "John", lastname: "Doe"),
        ]
        let query = SQL
            .INSERT(INTO: people, columns: \.firstname, \.lastname)
            .VALUES(peopleArray[0].firstname, peopleArray[0].lastname)
            .ON_CONFLICT(\.firstname, \.lastname,  DO: .NOTHING)
        #expect(query.query == "INSERT INTO people (firstname, lastname) VALUES ($1, $2) ON CONFLICT (firstname, lastname) DO NOTHING")
    }
    
    @Test
    func INSERT_ON_CONFLICT_partialIndex_DO_NOTHING() {
        let query = SQL
            .INSERT(INTO: users, columns: \.id, \.name, VALUES: 1, "Alice")
            .ON_CONFLICT(\.name, WHERE: RawSQL("name IS NOT NULL"), DO: .NOTHING)
        #expect(query.query == "INSERT INTO users (id, name) VALUES ($1, $2) ON CONFLICT (name) WHERE name IS NOT NULL DO NOTHING")
        #expect(query.parameters.count == 2)
    }
    
    @Test
    func INSERT_SQLExpr_ON_CONFLICT_partialIndex_RETURNING() {
        let query = SQL
            .INSERT(INTO: users,
                    columns: \.id, \.name,
                    VALUES: 7, SQLExpr("lower(?)", "ALICE"))
            .ON_CONFLICT(\.name, WHERE: RawSQL("name IS NOT NULL"), DO: .NOTHING)
            .RETURNING(\.id)
        #expect(query.query == "INSERT INTO users (id, name) VALUES ($1, lower($2)) ON CONFLICT (name) WHERE name IS NOT NULL DO NOTHING RETURNING id")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[1] as? String == "ALICE")
    }
    
    @available(macOS 14.0.0, *)
    @Test
    func INSERT_lone_ON_CONFLICT_partialIndex_DO_NOTHING() {
        let query = SQL
            .INSERT(INTO: users, columns: \.id, \.name)
            .VALUES(1, "Alice")
            .ON_CONFLICT(\.id, \.name, WHERE: RawSQL("name IS NOT NULL"), DO: .NOTHING)
        #expect(query.query == "INSERT INTO users (id, name) VALUES ($1, $2) ON CONFLICT (id, name) WHERE name IS NOT NULL DO NOTHING")
    }
    
    // MARK: - INSERT with raw SQL expressions (e.g. PostGIS)
    
    @Test
    func INSERT_withSQLExpr_and_RETURNING() {
        let lng = 2.2945
        let lat = 48.8584
        let now = Date()
        
        let query = SQL
            .INSERT(INTO: users,
                    columns: \.id, \.name, \.age, \.uuid,
                    VALUES: 42,
                            SQLExpr("ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography", lng, lat),
                            99,
                            now)
            .RETURNING(\.id)
        
        #expect(query.query == "INSERT INTO users (id, name, age, uuid) VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326)::geography, $4, $5) RETURNING id")
        #expect(query.parameters.count == 5)
        #expect(query.parameters[0] as? Int == 42)
        #expect(query.parameters[1] as? Double == lng)
        #expect(query.parameters[2] as? Double == lat)
        #expect(query.parameters[3] as? Int == 99)
        #expect(query.parameters[4] as? Date == now)
    }
    
    @Test
    func INSERT_withRawSQL_and_SQLExpr() {
        let query = SQL
            .INSERT(INTO: users,
                    columns: \.id, \.name,
                    VALUES: 1,
                            RawSQL("NOW()"))
        
        #expect(query.query == "INSERT INTO users (id, name) VALUES ($1, NOW())")
        #expect(query.parameters.count == 1)
    }
    
    @available(macOS 14.0.0, *)
    @Test
    func INSERT_lone_withSQLExpr() {
        let lng = -0.1278
        let lat = 51.5074
        
        let query = SQL
            .INSERT(INTO: users, columns: \.id, \.name)
            .VALUES(123, SQLExpr("ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography", lng, lat))
        
        #expect(query.query == "INSERT INTO users (id, name) VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326)::geography)")
        #expect(query.parameters.count == 3)
        #expect(query.parameters[1] as? Double == lng)
        #expect(query.parameters[2] as? Double == lat)
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
