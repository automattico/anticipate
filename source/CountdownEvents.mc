import Toybox.Application.Properties;
import Toybox.Application.Storage;
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
        var targetParts = _targetPartsForSlot(slot);
        if (targetParts == null) {
            return null;
        }

        var targetYear = targetParts[:year] as Lang.Number;
        var targetMonth = targetParts[:month] as Lang.Number;
        var targetDay = targetParts[:day] as Lang.Number;
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

        var targetEpoch = _storedTargetEpoch(slot, targetYear, targetMonth, targetDay, allDay, epochHour, epochMinute);
        return new EventConfig(name, ICON_CALENDAR, targetEpoch, allDay, targetYear, targetMonth, targetDay, targetHour, targetMinute);
    }

    static function resolveTargetEpoch(targetDate as Lang.Number, targetHour as Lang.Number, targetMinute as Lang.Number) as Lang.Number {
        var selectedDate = new Time.Moment(targetDate);
        var dateInfo = Gregorian.utcInfo(selectedDate, Time.FORMAT_SHORT);
        return resolveTargetEpochForDate(dateInfo.year, dateInfo.month as Lang.Number, dateInfo.day, targetHour, targetMinute);
    }

    static function resolveTargetEpochForDate(year as Lang.Number, month as Lang.Number, day as Lang.Number, targetHour as Lang.Number, targetMinute as Lang.Number) as Lang.Number {
        return Gregorian.moment({
            :year => year,
            :month => month,
            :day => day,
            :hour => targetHour,
            :minute => targetMinute,
            :second => 0
        }).value() as Lang.Number;
    }

    static function targetSignature(year as Lang.Number, month as Lang.Number, day as Lang.Number, isAllDay as Lang.Boolean, targetHour as Lang.Number, targetMinute as Lang.Number) as Lang.String {
        if (isAllDay) {
            return year.toString() + "-" + month.toString() + "-" + day.toString() + "|1";
        }

        return year.toString() + "-" + month.toString() + "-" + day.toString() + "|0|" + targetHour.toString() + "|" + targetMinute.toString();
    }

    static function _storedTargetEpoch(slot as Lang.Number, targetYear as Lang.Number, targetMonth as Lang.Number, targetDay as Lang.Number, allDay as Lang.Boolean, targetHour as Lang.Number, targetMinute as Lang.Number) as Lang.Number {
        var signature = targetSignature(targetYear, targetMonth, targetDay, allDay, targetHour, targetMinute);
        var storedSignature = _storageText(_slotKey(slot, "target_signature"));
        var storedEpoch = _storageNumber(_slotKey(slot, "target_epoch"));
        if (storedEpoch != null && storedEpoch > 0 && storedSignature == signature) {
            return storedEpoch;
        }

        return resolveTargetEpochForDate(targetYear, targetMonth, targetDay, targetHour, targetMinute);
    }

    static function _targetPartsForSlot(slot as Lang.Number) as Lang.Dictionary or Null {
        var year = _propertyNumber(_slotKey(slot, "target_year"));
        var month = _propertyNumber(_slotKey(slot, "target_month"));
        var day = _propertyNumber(_slotKey(slot, "target_day"));

        if (_hasExplicitDateParts(year, month, day)) {
            if (_isValidDate(year, month, day)) {
                return { :year => year, :month => month, :day => day };
            }

            return null;
        }

        var legacyTargetDate = _propertyNumber(_slotKey(slot, "target_date"));
        if (legacyTargetDate == null || legacyTargetDate <= 0) {
            return null;
        }

        var dateInfo = Gregorian.utcInfo(new Time.Moment(legacyTargetDate), Time.FORMAT_SHORT);
        return { :year => dateInfo.year, :month => dateInfo.month as Lang.Number, :day => dateInfo.day };
    }

    static function _hasExplicitDateParts(year as Lang.Number or Null, month as Lang.Number or Null, day as Lang.Number or Null) as Lang.Boolean {
        return (year != null && year > 0) || (month != null && month > 0) || (day != null && day > 0);
    }

    static function _isValidDate(year as Lang.Number or Null, month as Lang.Number or Null, day as Lang.Number or Null) as Lang.Boolean {
        if (year == null || month == null || day == null) {
            return false;
        }

        if (year < 1970 || month < 1 || month > 12 || day < 1) {
            return false;
        }

        return day <= _daysInMonth(year, month);
    }

    static function _daysInMonth(year as Lang.Number, month as Lang.Number) as Lang.Number {
        if (month == 2) {
            if (_isLeapYear(year)) {
                return 29;
            }

            return 28;
        }

        if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        }

        return 31;
    }

    static function _isLeapYear(year as Lang.Number) as Lang.Boolean {
        if (year % 400 == 0) {
            return true;
        }

        if (year % 100 == 0) {
            return false;
        }

        return year % 4 == 0;
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

    static function _storageNumber(key as String) as Lang.Number or Null {
        var value = Storage.getValue(key);
        if (value == null) {
            return null;
        }

        return value.toString().toNumber();
    }

    static function _storageText(key as String) as String or Null {
        var value = Storage.getValue(key);
        if (value == null) {
            return null;
        }

        var text = value.toString();
        if (text.length() == 0) {
            return null;
        }

        return text;
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
