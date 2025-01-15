//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Foundation
@testable import Squeal


// How I would like to write it
//struct People: Table {
//    static let name = "people"
//    var tableName: String = "people"
//    let firstname = Field<String>(name: "first_name")
//    let lastname = Field<String>(name: "last_name")
//}


struct Person {
    let firstname: String
    let lastname: String
}


struct InternalType<T> {
    
}


//enum Columns: InternalType<Any> {
//    typealias RawValue = <#type#>
//    
//    case uuid
//    case id
//    case name
//}



//struct UsersTable: Table {
//    
//    enum Columns: String, CaseIterable {
//        case uuid
//        case id
//        case name
//    }
//    
//
//    let tableName = "users"
//    
////    @Column<UUID>(key: UsersColumn.uuid)
////    var uuid
////    
////    @Column<Int>(key: UsersColumn.id)
////    var id
////    
////    @Column<String>(key: UsersColumn.name)
////    var name
//    
//    let uuid = Field<UUID>(name: Columns.uuid)
//    let id = Field<Int>(name: "id")
//    let name = Field<String>(name: "name")
//}

//struct UsersTable: Table {
//    
//    static let name = "users"
//    let tableName = "users"
//    
//    enum Columns: String, CaseIterable {
//        case uuid
//        case id
//        case name
//    }
//    
//    let uuid = Field<UUID>(Columns.uuid)
//    let id = Field<Int>(Columns.id)
//    let name = Field<String>(Columns.name)
//}


struct UsersTable: Table {
    
    static let schema = "users"
//    let tableName = "users"
    
    enum Columns: String, CaseIterable {
        case uuid
        case id
        case name
    }
    
    @Column<UUID>(name: "uuid") var uuid
    @Column<Int>(name: "id") var id
    @Column<String>(name: "name") var name
}

struct TradesTable: Table {
    static let schema = "trades"    
    @Column<UUID>(name: "user_id") var user_id
    @Column<UUID>(name: "study_id") var study_id
    @Column<String>(name: "type") var type
}


//@propertyWrapper struct Column<T> {
//    let key: any RawRepresentable<String>
//
//    var wrappedValue: Field<T> {
//        get { Field<T>(name: key.rawValue) }
////        set { storage.setValue(newValue, forKey: key) }
//    }
//}

//struct UserzTable: Table {
//    
//    
//    let tableName = "users"
//    
//    @Column<UUID>(key: "uuid")
//    var uuid
//    
//    @Column<Int>(key: "id")
//    var id
//    
//    // = Field<UUID>(name: "uuid")
////    let id = Field<Int>(name: "id")
////    let name = Field<String>(name: "name")
//}


struct PersonTable: Table {
    static let schema = "people"
//    var tableName: String = "people"
    
    @Column<String>(name: "first_name")
    var firstname
    
    @Column<String>(name: "last_name")
    var lastname
}
//
//struct TradesTable: Table {
//    static let name = "trades"
//    let tableName = "trades"
//    let user_id = Field<UUID>(name: "user_id")
//    let study_id = Field<UUID>(name: "study_id")
//    let type = Field<String>(name: "type")
//}
//
struct StudiesTable: Table {
    static let schema = "studies"
//    let tableName = "studies"
        
    @Column<UUID>(name: "id") var id
    @Column<String?>(name: "prolific_study_id") var prolific_study_id
    @Column<String>(name: "name") var name
    @Column<Double>(name: "starting_cash") var starting_cash
    @Column<Double>(name: "partitioning") var partitioning
    @Column<String?>(name: "completion_link") var completion_link
    @Column<Bool>(name: "shows_results") var shows_results
    @Column<Bool>(name: "allows_fractional_investing") var allows_fractional_investing
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


// JOIN, HAVING, DISTINcT, BETWEEN,  EXISTS NOT EXISTS

// SELECT AS.









struct OrdersTable: Table {
    
    static let schema = "orders"
    
    
    @Column<UUID>(name: "user_id")
    var user_id
}

