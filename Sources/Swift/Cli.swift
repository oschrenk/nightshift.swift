import ArgumentParser

@main
struct Nightshift: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "Control Night Shift",
    subcommands: [
      Disable.self,
      Enable.self,
      Schedule.self,
      Temperature.self,
    ]
  )

  mutating func run() {
    let contextOrError = NightShift.current()
    switch contextOrError {
    case let .success(context):
      switch context.schedule {
      case .off:
        print("Schedule: off")
        print("Enabled: \(context.enabled)")
        print("Temperature: \(context.temperature)")
      case .sunrise:
        print("Schedule: sunrise")
        print("Enabled: \(context.enabled)")
        print("Temperature: \(context.temperature)")
      case .custom:
        print("Schedule: custom \(context.schedule)")
        print("Enabled: \(context.enabled)")
        print("Temperature: \(context.temperature)")
      }
    case .failure:
      print("Failed to fetch Night Shift settings")
    }
  }
}

extension Nightshift {
  static func validateTemperature(value: Float?) throws {
    guard value ?? 1 <= 1 else {
      throw ValidationError("Temperature value too large. Needs to between (or at) 0 and 1.")
    }

    guard value ?? 0 >= 0 else {
      throw ValidationError("Temperature value too small. Needs to between (or at) 0 and 1.")
    }
  }

  /// `nightshift schedule [off|sunrise|custom]`
  ///
  /// only holds sub-commands
  struct Schedule: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "schedule",
      abstract: "Select schedule",
      subcommands: [
        Off.self,
        Sunrise.self,
        Custom.self,
      ]
    )

    mutating func run() {
      let contextOrError = NightShift.current()
      switch contextOrError {
      case let .success(context):
        print("Schedule: \(context.schedule)")
      case .failure:
        print("Failed to fetch Night Shift settings")
      }
    }
  }

  /// `nightshift schedule off`
  ///
  /// Turns Night Shift off
  struct Off: ParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Set schedule to off"
    )

    mutating func run() {
      NightShift.setMode(value: 0)
      print("Turning Nightshift off")
    }
  }

  /// `nightshift schedule sunrise`
  ///
  /// Activates Night Shift from sunrise to sunset depending on your location
  struct Sunrise: ParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Set schedule to sunrise"
    )

    @Option(
      name: [.customShort("t"), .customLong("temperature")],
      help: "Color temperature. Between 0 (less warm) and 1 (more warm)."
    )
    var temperature: Float?

    mutating func validate() throws {
      try validateTemperature(value: temperature)
    }

    mutating func run() {
      NightShift.setMode(value: 1)
      print("Setting Sunrise schedule")

      if let temperature = temperature {
        let oldTemperature = NightShift.getTemperature()
        NightShift.setTemperature(value: temperature)
        print("Temperature. Old: \(oldTemperature)")
        print("Temperature. New: \(temperature)")
      }
    }
  }

  /// `nightshift schedule custom [--from HH:mm] [--to HH:mm] [--temperature/-t 0-1]`
  ///
  /// Activates Night Shift with a custom start and end time
  struct Custom: ParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Set schedule to custom"
    )

    @Option(
      name: [.customShort("t"), .customLong("temperature")],
      help: "Color temperature. Between 0 (less warm) and 1 (more warm)."
    )
    var temperature: Float?

    @Option(
      name: .customLong("from"),
      help: "From time in 24h format eg. 7:00"
    )
    var maybeFrom: LocalTime?

    @Option(
      name: .customLong("to"),
      help: "To time in 24h format eg. 17:00"
    )
    var maybeTo: LocalTime?

    mutating func validate() throws {
      try validateTemperature(value: temperature)

      if let from = maybeFrom {
        if let to = maybeTo {
          guard from < to else {
            throw ValidationError("`From` must be earlier than `to`")
          }
        }
      }
    }

    mutating func run() {
      NightShift.setMode(value: 2)
      print("Setting custom schedule")

      if let temperature = temperature {
        let oldTemperature = NightShift.getTemperature()
        NightShift.setTemperature(value: temperature)
        print("Temperature. Old: \(oldTemperature)")
        print("Temperature. New: \(temperature)")
      }

      if maybeFrom != nil || maybeTo != nil {
        let (oldFrom, oldTo) = NightShift.getSchedule()
        let from = maybeFrom ?? oldFrom
        let to = maybeTo ?? oldTo
        NightShift.setSchedule(from: from, to: to)
        print("Schedule. Old: From \(oldFrom) to \(oldTo)")
        print("Schedule. New: From \(from) to \(to)")
      }
    }
  }

  /// `nightshift enable`
  ///
  /// Enables Night Shift until tomorrow, or until the next sunrise depending
  /// on the schedule
  struct Enable: ParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Enable Night Shift until tomorrow or next sunrise"
    )

    mutating func run() {
      let contextOrError = NightShift.current()
      switch contextOrError {
      case let .success(context):
        NightShift.enable()

        switch context.schedule {
        case .sunrise:
          print("Enabled until next sunrise")
        default:
          print("Enabled until tomorrow")
        }
      case .failure:
        print("Failed to enable nightshift")
      }
    }
  }

  /// `nightshift disable`
  ///
  /// Disable Night Shift until tomorrow, or until the next sunrise depending
  /// on the schedule
  struct Disable: ParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Disable Nightshift"
    )

    mutating func run() {
      NightShift.disable()
      print("Disabled nightshift")
    }
  }

  /// `nightshift temperature [0-1]`
  ///
  /// Print or control the color temperature. Between 0 (less warm) and 1
  /// (more warm).
  struct Temperature: ParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Get or set color temperature."
    )

    @Argument(help: "Color temperature. Between 0 (less warm) and 1 (more warm).")
    var temperature: Float?

    mutating func validate() throws {
      try validateTemperature(value: temperature)
    }

    mutating func run() {
      let oldTemperature = NightShift.getTemperature()

      if let temperature = temperature {
        NightShift.setTemperature(value: temperature)

        print("Temperature. Old: \(oldTemperature)")
        print("Temperature. New: \(temperature)")
      } else {
        print("Temperature. Current: \(oldTemperature)")
      }
    }
  }
}
