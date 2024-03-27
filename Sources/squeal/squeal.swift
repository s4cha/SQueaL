
enum SQLSelectValue: String {
    case all = "*"
}

//protocol Table {
//    associatedtype ColumnsEnum
//    static var tableName: String { get }
//}

//typealias TableName = String
//typealias ColumnName = String
//
//struct DefaultTable: Table {
//    static let tableName = ""
//    typealias ColumnsEnum = Columns
//    enum Columns: String {
//        case id
//    }
//}

//extension Table {
//    static func all() -> SQLQuery {
//        SQLQuery().all(self)
//    }
//}


// Code
//struct DBSchema {
//    static let users: TableName = "users"
    
//struct DB {
//struct Users: Table {
//    static let tableName = "users"
//    typealias ColumnsEnum = Columns
//    enum Columns: String {
//        case id
//        case name
//    }
//}
//
//struct TestQuery<T: DatabaseSchema> {
//    func WHERE<U>(_ kp: KeyPath<T, Field<U>>, equals: U) -> TestQuery {
//        return self
//    }
//}

