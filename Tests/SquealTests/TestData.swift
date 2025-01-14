//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Foundation
@testable import Squeal

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
