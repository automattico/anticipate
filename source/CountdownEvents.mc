import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

const MAX_EVENT_SLOTS = 5;

class CountdownEvents {

    static function configuredEvents() as Array {
        var events = [];

        for (var slot = 1; slot <= MAX_EVENT_SLOTS; slot += 1) {
            var event = _eventForSlot(slot);
            if (event != null) {
                events.add(event);
            }
        }

        return events;
    }

    static function firstConfiguredEvent() as EventConfig or Null {
        var events = configuredEvents();
        if (events.size() == 0) {
            return null;
        }

        return events[0] as EventConfig;
    }

    static function _eventForSlot(slot as Lang.Number) as EventConfig or Null {
        var targetDate = _propertyNumber(_slotKey(slot, "target_date"));
        if (targetDate == null || targetDate <= 0) {
            return null;
        }

        var targetHour = _boundedNumber(_slotKey(slot, "target_hour"), 0, 23, 0);
        var targetMinute = _boundedNumber(_slotKey(slot, "target_minute"), 0, 59, 0);
        var useSpecificTime = _useSpecificTime(slot, targetHour, targetMinute);
        var allDay = !useSpecificTime;
        var name = _propertyText(_slotKey(slot, "name"));

        if (name == null || name.length() == 0) {
            name = "Event " + slot.toString();
        }

        var epochHour = targetHour;
        var epochMinute = targetMinute;
        if (allDay) {
            epochHour = 0;
            epochMinute = 0;
        }

        var targetEpoch = _storedTargetEpoch(slot, targetDate, epochHour, epochMinute);
        return new EventConfig(name, ICON_CALENDAR, targetEpoch, allDay, targetDate, targetHour, targetMinute);
    }

    static function resolveTargetEpoch(targetDate as Lang.Number, targetHour as Lang.Number, targetMinute as Lang.Number) as Lang.Number {
        var selectedDate = new Time.Moment(targetDate);
        var dateInfo = Gregorian.utcInfo(selectedDate, Time.FORMAT_SHORT);
        return _projectionForInfo(dateInfo, targetHour, targetMinute, 0).value() as Lang.Number;
    }

    static function _storedTargetEpoch(slot as Lang.Number, targetDate as Lang.Number, targetHour as Lang.Number, targetMinute as Lang.Number) as Lang.Number {
        var storedEpoch = _propertyNumber(_slotKey(slot, "target_epoch"));
        if (storedEpoch != null && storedEpoch > 0) {
            return storedEpoch;
        }

        return resolveTargetEpoch(targetDate, targetHour, targetMinute);
    }

    static function _projectionForInfo(info as Gregorian.Info, hour as Lang.Number or Null, minute as Lang.Number or Null, second as Lang.Number or Null) as Time.Moment {
        return Gregorian.moment({
            :year => info.year,
            :month => (info.month as Number),
            :day => info.day,
            :hour => _valueOr(hour, info.hour),
            :minute => _valueOr(minute, info.min),
            :second => _valueOr(second, info.sec)
        });
    }

    static function _valueOr(value as Lang.Number or Null, fallback as Lang.Number) as Lang.Number {
        if (value == null) {
            return fallback;
        }

        return value;
    }

    static function _slotKey(slot as Lang.Number, suffix as String) as String {
        return "event" + slot.toString() + "_" + suffix;
    }

    static function _boundedNumber(key as String, minValue as Lang.Number, maxValue as Lang.Number, defaultValue as Lang.Number) as Lang.Number {
        var value = _propertyNumber(key);
        if (value == null || value < minValue || value > maxValue) {
            return defaultValue;
        }

        return value;
    }

    static function _propertyValue(key as String) as Lang.Object or Null {
        try {
            return Properties.getValue(key);
        } catch (e) {
            return null;
        }
    }

    static function _propertyText(key as String) as String or Null {
        var rawValue = _propertyValue(key);
        if (rawValue == null) {
            return null;
        }

        var text = rawValue.toString();
        if (text.length() == 0) {
            return null;
        }

        return text;
    }

    static function _propertyNumber(key as String) as Lang.Number or Null {
        var text = _propertyText(key);
        if (text == null) {
            return null;
        }

        return text.toNumber();
    }

    static function _propertyBoolean(key as String, defaultValue as Lang.Boolean) as Lang.Boolean {
        var value = _propertyValue(key);
        var parsed = _booleanOrNull(value);
        if (parsed != null) {
            return parsed as Lang.Boolean;
        }

        return defaultValue;
    }

    static function _propertyBooleanOrNull(key as String) as Lang.Boolean or Null {
        return _booleanOrNull(_propertyValue(key));
    }

    static function _useSpecificTime(slot as Lang.Number, targetHour as Lang.Number, targetMinute as Lang.Number) as Lang.Boolean {
        var useSpecificTime = _propertyBooleanOrNull(_slotKey(slot, "use_specific_time"));
        if (useSpecificTime != null) {
            return useSpecificTime as Lang.Boolean;
        }

        var allDay = _propertyBooleanOrNull(_slotKey(slot, "all_day"));
        if (allDay != null) {
            return !(allDay as Lang.Boolean);
        }

        return targetHour != 0 || targetMinute != 0;
    }

    static function _booleanOrNull(value as Lang.Object or Null) as Lang.Boolean or Null {
        if (value == null) {
            return null;
        }

        if (value instanceof Lang.Boolean) {
            return value as Lang.Boolean;
        }

        if (value instanceof Lang.Number) {
            return (value as Lang.Number) != 0;
        }

        var text = value.toString();
        if (text == "true") {
            return true;
        }

        if (text == "1") {
            return true;
        }

        if (text == "false") {
            return false;
        }

        if (text == "0") {
            return false;
        }

        var numericValue = text.toNumber();
        if (numericValue != null) {
            return numericValue != 0;
        }

        return null;
    }
}
