//
//  SQLValues.swift
//
//
//  Created by Sacha Durand Saint Omer on 07/10/2026.
//

import Foundation

/// Renders a list of values for a VALUES row or a SET clause, binding parameters as `$n`
/// numbered after the `parameterOffset` parameters already in the query.
/// - `SQLExpr`: its SQL, with each `?` replaced by the next `$n` and its arguments bound.
/// - `RawSQL`: inlined as is.
/// - any other `Encodable` (including nil optionals): bound as the next `$n`.
func renderSQLValues(_ values: [Any], parameterOffset: Int) -> (fragments: [String], parameters: [(any Encodable)?]) {
    var parameters: [(any Encodable)?] = []
    var fragments: [String] = []
    var pIndex = parameterOffset

    func nextPlaceholder() -> String {
        pIndex += 1
        return "$\(pIndex)"
    }

    for v in values {
        if let expr = v as? SQLExpr {
            var frag = expr.sql
            for arg in expr.parameters {
                let ph = nextPlaceholder()
                if let qRange = frag.range(of: "?") {
                    frag.replaceSubrange(qRange, with: ph)
                }
                parameters.append(arg)
            }
            fragments.append(frag)
        } else if let raw = v as? RawSQL {
            fragments.append(raw.expression)
        } else if let enc = v as? any Encodable {
            parameters.append(enc)
            fragments.append(nextPlaceholder())
        } else {
            // Fallback – treat unknowns as NULL
            fragments.append("NULL")
        }
    }
    return (fragments, parameters)
}
