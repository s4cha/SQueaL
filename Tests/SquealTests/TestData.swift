//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Foundation
import Squeal


@Table(schema: "users")
struct Users {
    let uuid: UUID
    let id: Int
    let name: String
    let age: Int
}

@Table(schema: "trades")
struct Trades {
    let user_id: UUID
    let study_id: UUID
    let type: String
}

@Table(schema: "employees")
struct Employees {
    var name: String
    var department_id: UUID
}

@Table(schema: "people")
struct People {
    let firstname: String
    let lastname: String
}

@Table(schema: "studies")
struct Studies {
    let id: UUID
    let prolific_study_id: String?
    let name: String
    let starting_cash: Double
    let partitioning: Double
    let completion_link: String?
    let shows_results: Bool
    let allows_fractional_investing: Bool
}

@Table(schema: "departments")
struct Departments {
    let id: UUID
    let name: String
}

@Table(schema: "orders")
struct Orders {
    let user_id: UUID
}

@Table(schema: "users_departments")
struct UsersDepartments {
    let department_id: UUID
    let user_id: UUID
    
}


let users = UsersTable()
let orders = OrdersTable()
let employees = EmployeesTable()
let departments = DepartmentsTable()
let users_departments = UsersDepartmentsTable()
let peopleTable = PeopleTable()
let people = PeopleTable()



// TODO
// Where =  like NULL NOT NULL
// OR
// Group by
// Order By / ASC DESC NULL NOT NULL
// Having
// UPDATE SET


// JOIN, HAVING, DISTINcT, BETWEEN,  EXISTS NOT EXISTS

// SELECT AS.

