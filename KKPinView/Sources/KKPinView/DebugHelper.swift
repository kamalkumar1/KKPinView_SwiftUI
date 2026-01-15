//
//  DebugHelper.swift
//  KKPinView
//
//  Created for debug logging support
//

import Foundation

/// Prints a message only in debug builds.
/// This function is a no-op in release builds, ensuring no debug output in production.
///
/// - Parameter items: The items to print (same as Swift's print function)
/// - Parameter separator: The separator between items (default: " ")
/// - Parameter terminator: The terminator string (default: "\n")
@inlinable
public func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    print(items.map { "\($0)" }.joined(separator: separator), terminator: terminator)
    #endif
}

