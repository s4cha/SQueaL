//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal


struct UsersTable: Table {
    let tableName = "users"
    let id = Field<Int>(name: "id")
    let name = Field<String>(name: "name")
}


final class TypedQueryTests: XCTestCase {
    
    let users = UsersTable()
    let trades = TradesTable()
    
    func testWHEREqualSign() {
        let query = ""
            .SELECT(\.id, FROM: users)
            .WHERE(\.id == 1)
        XCTAssertEqual(query.raw, "SELECT id FROM users WHERE id = 1")
    }
    
    func testWHEREANDEqualSign() {
        let query = ""
            .SELECT(\.id, FROM: users)
            .WHERE(\.id == 1)
            .AND(\.name == "Jack")
        XCTAssertEqual(query.raw, "SELECT id FROM users WHERE id = 1 AND name = 'Jack'")
    }
    
    func testSelectTypesShortKeypath() {
        let query2 = ""
            .SELECT(\.name, FROM: users)
        XCTAssertEqual(query2.raw, "SELECT name FROM users")
    }
    
    func testWhereTypeSafeInt() throws {
        let query = ""
            .SELECT(.all, FROM: users)
            .WHERE(\.id == 1)
        print(query)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1")
    }
    
    func testWhereTypeSafeString() throws {
        let query = ""
            .SELECT(.all, FROM: users)
            .WHERE(\.name == "Alice")
        print(query)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE name = 'Alice'")
    }
    
    func testAndTypeSafe() throws {
        let query = ""
            .SELECT(.all, FROM: users)
            .WHERE(\.id == 1)
            .AND(\.name == "jack")
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack'")
    }
    
    func testAndTypeSafeLimit() throws {
        let query = ""
            .SELECT(.all, FROM: users)
            .WHERE(\.id == 1)
            .AND(\.name, equals: "jack")
            .LIMIT(1)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack' LIMIT 1")
    }
    
    func testDelete() {
        let query = ""
            .DELETE(FROM: users)
            .WHERE(\.id == 243)
        XCTAssertEqual(query.raw, "DELETE FROM users WHERE id = 243")
    }
    
    func testUpdate() {
        let query = ""
            .UPDATE(users, SET: \.name, value: "john")
            .WHERE(\.id == 12)
        XCTAssertEqual(query.raw, "UPDATE users SET name = 'john' WHERE id = 12")
    }
    
    func testINSERT_INTO() {
    let query = ""
        .INSERT(INTO: users, columns: \.id, \.name,
                VALUES: 12, "Jim")

    XCTAssertEqual(query.raw, "INSERT INTO users (id, name) VALUES (12, 'Jim')")
}
    
    func testLimitAfterSelectFrom() throws {
        let query = ""
            .SELECT(.all, FROM: users)
            .LIMIT(17)
        XCTAssertEqual(query.raw, "SELECT * FROM users LIMIT 17")
    }
    
//    func testINSERT_INTO_multiple_values() {
//        let people = [
//            Person(firstname: "John", lastname: "Doe"),
//            Person(firstname: "Ada", lastname: "Lovelace"),
//            Person(firstname: "Alan", lastname: "Turing"),
//        ]
//        
//        let query = ""
//            .INSERT(INTO: trades, columns: "first_name", "last_name",
//            VALUES: people.map { [ $0.firstname, $0.lastname] })
//                    
//    
//        XCTAssertEqual(query.raw, "INSERT INTO trades (first_name, last_name) VALUES ('John', 'Doe'), ('Ada', 'Lovelace'), ('Alan', 'Turing');")
//    }
        
        
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

    // - MARK: Helpers
    
    func testTableAll() {
        let query = users.all()
        XCTAssertEqual(query.raw, "SELECT * FROM users")
    }
    
//    func testFind() {
//        let query = users.find(\.id, equals: 12)
//        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 12 LIMIT 1")
//    }
//    
//    func testFindTable() {
//        let query = users.find(\.id, equals: 12)
//        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 12 LIMIT 1")
//    }
}


struct Person {
    let firstname: String
    let lastname: String
}



//struct StudyStocksTable: Table {
//    let tableName = "'study+stock'" // TODO check '' added ??
//    let study_id = Field<UUID?>(name: "study_id")
//    let stock_id = Field<UUID?>(name: "stock_id")
//}
//
//struct UserTokensTable: Table {
//    let tableName = "user_tokens"
//    let user_id = Field<UUID>(name: "user_id")
//    let value = Field<String>(name: "value")
//}
//
//struct AdminTokensTable: Table {
//    let tableName = "admin_tokens"
//    let admin_id = Field<UUID>(name: "admin_id")
//    let value = Field<String>(name: "value")
//}
//
//struct UsersCompletedStudiesTable: Table {
//    let tableName = "users_completed_studies"
//    let user_id = Field<UUID>(name: "user_id")
//    let study_id = Field<UUID>(name: "study_id")
//}

struct TradesTable: Table {
    let tableName = "trades"
    let user_id = Field<UUID>(name: "user_id")
    let study_id = Field<UUID>(name: "study_id")
    let type = Field<String>(name: "type")
}

//struct AdminsTable: Table {
//    let tableName = "admins"
//    let id = Field<UUID>(name: "id")
//    let email = Field<String>(name: "email")
//}
//
//struct StocksTable: Table {
//    let tableName = "stocks"
//    let id = Field<UUID>(name: "id")
//}
//
//struct UsersTable: Table {
//    let tableName = "users"
//    let id = Field<UUID>(name: "id")
//    let prolific_participant_id = Field<String?>(name: "prolific_participant_id")
//    let available_cash = Field<Double>(name: "available_cash")
//    let study_id = Field<UUID?>(name: "study_id")
//}


// Rename SQLQuery to just SQL
// Typed -> TSQL

// RM Bare API alltogether ?
