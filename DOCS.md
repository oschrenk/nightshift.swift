# DOCS

> Night Shift automatically shifts the colours of your display to the warmer end of the colour spectrum after dark. This may help you get a better night's sleep.

Under "System Settings > Display > Night Shift" you find the UI controls.

It supports three schedules

1. Off
2. Sunset to Sunrise
3. Custom

When "Off" (`mode: 0`), you can turn it on for a single day toggling "Turn on until "tomorrow"

When "Sunset to Sunrise" (`mode: 1`), the schedule is automatic, and you can toggle it active until the next "sunrise"

When "Custom" (`mode: 2`), you can set a daily schedule, and additionally toggle it active until "tomorrow"

In all three modes, you can select a colour temperature, on a sliding scale between "Less Warm" and "More Warm"

## Technical

The status object

```
  var status: Status = Status()
  client.getBlueLightStatus(&status)
```

```
// seems to control the temporary setting until tomorrow/sunrise
enabled: true|false
available: true|false

// I guesss this has to do with location based information
sunSchedulePermitted: true|false
disableFlags: 0
mode: 0|1|2
schedule(fromTime(hour,minute),toTime(hour,minute))
```
