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
    
    func testWHEREqualSign() {
        let query = ""
            .SELECT(\.id, FROM: users)
            .WHERE(\.id == 1)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id = $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id = 1")
    }
    
    func testWHEREANDEqualSign() {
        let query = ""
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
        let query = ""
            .SELECT(\.name, FROM: users)
        XCTAssert(query.parameters.isEmpty)
        XCTAssertEqual(query.query, "SELECT name FROM users")
        XCTAssertEqual("\(query)", "SELECT name FROM users")
    }
    
    func testWhereTypeSafeInt() throws {
        let query = ""
            .SELECT(.all, FROM: users)
            .WHERE(\.id == 1)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE id = $1")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 1")
    }
    
    func testWhereTypeSafeString() throws {
        let query = ""
            .SELECT(.all, FROM: users)
            .WHERE(\.name == "Alice")
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? String == "Alice")
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE name = $1")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE name = 'Alice'")
    }
    
    func testAndTypeSafe() throws {
        let query = ""
            .SELECT(.all, FROM: users)
            .WHERE(\.id == 1)
            .AND(\.name == "jack")
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssert(query.parameters[1] as? String == "jack")
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE id = $1 AND name = $2")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 1 AND name = 'jack'")
    }
    
    func testAndTypeSafeLimit() throws {
        let query = ""
            .SELECT(.all, FROM: users)
            .WHERE(\.id == 1)
            .AND(\.name == "jack")
            .LIMIT(1)
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssert(query.parameters[1] as? String == "jack")
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE id = $1 AND name = $2 LIMIT 1")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 1 AND name = 'jack' LIMIT 1")
    }
    
    func testDelete() {
        let query = ""
            .DELETE(FROM: users)
            .WHERE(\.id == 243)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 243)
        XCTAssertEqual(query.query, "DELETE FROM users WHERE id = $1")
        XCTAssertEqual("\(query)", "DELETE FROM users WHERE id = 243")
    }
    
    func testUpdate() {
        let query = ""
            .UPDATE(users, SET: \.name, value: "john")
            .WHERE(\.id == 12)
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? String == "john")
        XCTAssert(query.parameters[1] as? Int == 12)
        XCTAssertEqual(query.query, "UPDATE users SET name = $1 WHERE id = $2")
        XCTAssertEqual("\(query)", "UPDATE users SET name = 'john' WHERE id = 12")
    }
    
    func testINSERT_INTO() {
        let query = ""
            .INSERT(INTO: users, columns: \.id, \.name,
                    VALUES: 12, "Jim")
//        XCTAssertEqual(query.parameters.count, 2)
//        XCTAssert(query.parameters[0] as? Int == 12)
//        XCTAssert(query.parameters[1] as? String == "Jim")
        XCTAssertEqual(query.query, "INSERT INTO users (id, name) VALUES ($1, $2)")
        XCTAssertEqual("\(query)", "INSERT INTO users (id, name) VALUES (12, 'Jim')")
    }
    
    func testLimitAfterSelectFrom() throws {
        let query = ""
            .SELECT(.all, FROM: users)
            .LIMIT(17)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT * FROM users LIMIT 17")
        XCTAssertEqual("\(query)", "SELECT * FROM users LIMIT 17")
    }
    
    @available(macOS 14.0.0, *)
    func testINSERT_INTO_multiple_values() {
        let people = [
            Person(firstname: "John", lastname: "Doe"),
            Person(firstname: "Ada", lastname: "Lovelace"),
            Person(firstname: "Alan", lastname: "Turing"),
        ]
        let query = ""
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
        var query = ""
            .INSERT(INTO: PersonTable(), columns: \.firstname, \.lastname)
        
        
        for p in people {
            query.ADDVALUES(p.firstname, p.lastname)
        }
        XCTAssertEqual("\(query)", "INSERT INTO people (first_name, last_name) VALUES ('John', 'Doe'), ('Ada', 'Lovelace'), ('Alan', 'Turing')")
    }
    
//    func testINSERT_INTO_multiple_valuesLoop() {
//        let people = [
//            Person(firstname: "John", lastname: "Doe"),
//            Person(firstname: "Ada", lastname: "Lovelace"),
//            Person(firstname: "Alan", lastname: "Turing"),
//        ]
////        let people = PersonTable()
//        
//        var query = ""
//            .INSERT(INTO: PersonTable(), columns: \.firstname, \.lastname)
//            .VALUESX(people[0].firstname, people[0].lastname)
//        
////        for p in people {
////            query = query
////                .VALUESX(p.firstname, p.lastname)
////        }
////        
////
////                    VALUESARRAY: people.map { [ $0.firstname, $0.lastname] })
////            .va
//                    
//        print(query)
//        XCTAssertEqual(query.raw, "INSERT INTO trades (first_name, last_name) VALUES ('John', 'Doe'), ('Ada', 'Lovelace'), ('Alan', 'Turing');")
//    }
//        
        
        //let insertBuilder = db.insert(into: "price_action")
        //    .columns("date", "price", "stock_id")
        //for price in prices {
        //    insertBuilder.values(SQLBind(price.date), SQLBind(price.price), SQLBind(stockID))
        //}
        //try await insertBuilder.run()

        //try await db.insert(into: DB.stocks.tableName)
        //    .columns("ticker")
        //    .values(SQLBind(ticker))
        //    .run()


        //// Attach new stocks
        //let insert = sqlDB()
        //    .insert(into: "study+stock")
        //    .columns("study_id", "stock_id")
        //for stock in stocks {
        //    insert.values(SQLBind(studyId), SQLBind(stock.id!))
        //}
        //try await insert.run()

        //


        //let query = SQLQueryBuilder().query()
        //    .INSERT(INTO: admin_tokens.tableName, columns: admin_tokens.value.name, admin_tokens.admin_id.name)
        //    .VALUES(token, adminId.uuidString) //Careful SQL INJECTION
        //try await sqlDB().execute(query)


        //try await sqlDB().insert(into: user_tokens.tableName)
        //    .columns( "value", "user_id")
        //    .values(SQLBind(userId), SQLBind(token))
        //    .run()

        //try await sqlDB().insert(into: DB.users_completed_studies.tableName)
        //    .columns(DB.users_completed_studies.user_id.name, DB.users_completed_studies.study_id.name)
        //    .values(SQLBind(user.id!), SQLBind(studyId))
        //    .run()
}


struct Person {
    let firstname: String
    let lastname: String
}

struct UsersTable: Table {
    let tableName = "users"
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


// Rename SQLQuery to just SQL
// Typed -> TSQL
// RM Bare API alltogether ?
