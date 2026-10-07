import Foundation
import os

/// A test clock that moves forward each time it is read.
final class TestClock: Sendable {
    private let current: OSAllocatedUnfairLock<Date>

    init(_ start: Date) {
        current = OSAllocatedUnfairLock(initialState: start)
    }

    func advance(by seconds: TimeInterval) -> Date {
        current.withLock { date in
            date = date.addingTimeInterval(seconds)
            return date
        }
    }
}
