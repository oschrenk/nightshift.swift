import ArgumentParser

/// Represents local time in 24h format like `HH:mm` from `00:00` to `23:59`
struct LocalTime: ExpressibleByArgument, CustomStringConvertible {
  var hour: Int
  var minute: Int

  var description: String {
    return "\(hour):\(minute)"
  }

  init(hour: Int, minute: Int) {
    self.hour = hour
    self.minute = minute
  }

  /// Smart constructor to build `LocalTime` from string
  ///
  /// Accepts 24h format like `HH:mm` from `00:00` to `23:59`
  init?(argument: String) {
    let timeSplits = argument.trim().split(separator: ":").compactMap { Int($0) }
    if timeSplits.count != 2 {
      return nil
    }
    let maybeHour: Int = timeSplits[0]
    if maybeHour < 0 || maybeHour > 23 {
      return nil
    }
    let maybeMinute: Int = timeSplits[1]
    if maybeMinute < 0 || maybeMinute > 59 {
      return nil
    }

    hour = Int(maybeHour)
    minute = Int(maybeMinute)
  }
}

extension LocalTime: Comparable {
  static func < (lhs: LocalTime, rhs: LocalTime) -> Bool {
    if lhs.hour != rhs.hour {
      return lhs.hour < rhs.hour
    } else {
      return lhs.minute < rhs.minute
    }
  }

  static func == (lhs: LocalTime, rhs: LocalTime) -> Bool {
    return lhs.hour == rhs.hour && lhs.minute == rhs.minute
  }
}
