import SwiftCompilerPlugin
import SwiftSyntaxMacros


@main
struct SquealMacros: CompilerPlugin {
    var providingMacros: [Macro.Type] = []//[TableMacro.self]
}
