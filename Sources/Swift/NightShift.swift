import Cocoa
import DisplayClient

/// Hold the Swift representation and translation layer to private API
struct NightShift {
  // block strict being initialized
  private init() {}

  /// Night Shift schedule
  enum Schedule {
    case off
    case custom(from: LocalTime, to: LocalTime)
    case sunrise
  }

  /// Night Shift context
  struct Context {
    let schedule: Schedule
    let enabled: Bool
    let temperature: Float
  }

  static func setMode(value: Int) {
    let client = CBBlueLightClient()
    client.setMode(Int32(value))
  }

  static func isEnabled() -> Bool {
    let client = CBBlueLightClient()
    var status = Status()
    client.getBlueLightStatus(&status)
    return status.enabled.boolValue
  }

  static func enable() {
    let client = CBBlueLightClient()
    client.setEnabled(true)
  }

  static func disable() {
    let client = CBBlueLightClient()
    client.setEnabled(false)
  }

  static func setTemperature(value: Float) {
    let client = CBBlueLightClient()
    client.setStrength(value, commit: false)
  }

  static func getTemperature() -> Float {
    let client = CBBlueLightClient()
    var temperature: Float = 0
    client.getStrength(&temperature)
    return temperature
  }

  static func getSchedule() -> (LocalTime, LocalTime) {
    let client = CBBlueLightClient()
    var status = Status()
    client.getBlueLightStatus(&status)

    let schedule = status.schedule
    let from = LocalTime(
      hour: Int(schedule.fromTime.hour),
      minute: Int(schedule.fromTime.minute)
    )
    let to = LocalTime(
      hour: Int(schedule.toTime.hour),
      minute: Int(schedule.toTime.minute)
    )
    return (from, to)
  }

  static func setSchedule(from: LocalTime, to: LocalTime) {
    let client = CBBlueLightClient()

    let schedule = ScheduleObjC(
      fromTime: Time(hour: Int32(from.hour), minute: Int32(from.minute)),
      toTime: Time(hour: Int32(to.hour), minute: Int32(to.minute))
    )
    let scheduleP = UnsafeMutablePointer<ScheduleObjC>.allocate(capacity: 1)
    scheduleP.pointee = schedule
    client.setSchedule(scheduleP)
  }

  static func current() -> Result<NightShift.Context, Error> {
    let client = CBBlueLightClient()

    var status = Status()
    client.getBlueLightStatus(&status)
    let enabled = status.enabled.boolValue

    var temperature: Float = 0
    client.getStrength(&temperature)

    let contextOrError: Result<NightShift.Schedule, Error>
    switch status.mode {
    case 0:
      contextOrError = Result.success(NightShift.Schedule.off)
    case 1:
      contextOrError = Result.success(NightShift.Schedule.sunrise)
    case 2:
      let schedule = status.schedule
      let from = LocalTime(
        hour: Int(schedule.fromTime.hour),
        minute: Int(schedule.fromTime.minute)
      )
      let to = LocalTime(
        hour: Int(schedule.toTime.hour),
        minute: Int(schedule.toTime.minute)
      )
      contextOrError = Result.success(NightShift.Schedule.custom(from: from, to: to))
    default:
      contextOrError = Result.failure(AppError.decodingError("Unknown mode \(status.mode)"))
    }
    return contextOrError.map {
      Context(
        schedule: $0,
        enabled: enabled,
        temperature: temperature
      )
    }
  }
}
