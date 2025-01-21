//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Foundation
import Squeal


struct UsersTable: Table {
    
    static let schema = "users"
    
    @Column<UUID>(name: "uuid") var uuid
    @Column<Int>(name: "id") var id
    @Column<String>(name: "name") var name
    @Column<Int>(name: "age") var age
}


struct TradesTable: Table {
    
    static let schema = "trades"
    
    @Column<UUID>(name: "user_id") var user_id
    @Column<UUID>(name: "study_id") var study_id
    @Column<String>(name: "type") var type
}


struct PersonTable: Table {
    
    static let schema = "people"
    
    @Column<String>(name: "first_name") var firstname
    @Column<String>(name: "last_name") var lastname
}


struct StudiesTable: Table {
    
    static let schema = "studies"
        
    @Column<UUID>(name: "id") var id
    @Column<String?>(name: "prolific_study_id") var prolific_study_id
    @Column<String>(name: "name") var name
    @Column<Double>(name: "starting_cash") var starting_cash
    @Column<Double>(name: "partitioning") var partitioning
    @Column<String?>(name: "completion_link") var completion_link
    @Column<Bool>(name: "shows_results") var shows_results
    @Column<Bool>(name: "allows_fractional_investing") var allows_fractional_investing
}


struct Employees: Table {
    static let schema = "employees"
    @Column<String>(name: "name") var name
    @Column<UUID>(name: "department_id") var department_id
}


struct Departments: Table {
    static let schema = "departments"
    
    @Column<UUID>(name: "id") var id
    @Column<String>(name: "name") var name
}

struct OrdersTable: Table {
    
    static let schema = "orders"

    @Column<UUID>(name: "user_id") var user_id
}


let users = UsersTable()
let orders = OrdersTable()
let employees = Employees()
let departments = Departments()


// TODO
// Where =  like NULL NOT NULL
// OR
// Group by
// Order By / ASC DESC NULL NOT NULL
// Having
// UPDATE SET


// JOIN, HAVING, DISTINcT, BETWEEN,  EXISTS NOT EXISTS

// SELECT AS.
