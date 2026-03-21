import Toybox.Lang;

const SECONDS_PER_MINUTE = 60;
const SECONDS_PER_HOUR = 60 * SECONDS_PER_MINUTE;
const SECONDS_PER_DAY = 24 * SECONDS_PER_HOUR;

const ICON_CALENDAR = "calendar";

class EventConfig {
    var name as Lang.String;
    var icon as Lang.String;
    var targetEpoch as Lang.Number;
    var allDay as Lang.Boolean;

    function initialize(name as Lang.String, icon as Lang.String, targetEpoch as Lang.Number, allDay as Lang.Boolean) {
        self.name = name;
        self.icon = icon;
        self.targetEpoch = targetEpoch;
        self.allDay = allDay;
    }
}

class CountdownState {
    var targetEpoch as Lang.Number;
    var nowEpoch as Lang.Number;
    var deltaSeconds as Lang.Number;
    var isNow as Lang.Boolean;
    var isDone as Lang.Boolean;
    var days as Lang.Number;
    var hours as Lang.Number;
    var minutes as Lang.Number;

    function initialize(targetEpoch as Lang.Number, nowEpoch as Lang.Number, deltaSeconds as Lang.Number, isNow as Lang.Boolean, isDone as Lang.Boolean, days as Lang.Number, hours as Lang.Number, minutes as Lang.Number) {
        self.targetEpoch = targetEpoch;
        self.nowEpoch = nowEpoch;
        self.deltaSeconds = deltaSeconds;
        self.isNow = isNow;
        self.isDone = isDone;
        self.days = days;
        self.hours = hours;
        self.minutes = minutes;
    }
}
