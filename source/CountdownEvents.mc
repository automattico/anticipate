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

    static function _eventForSlot(slot as Lang.Number) as EventConfig or Null {
        try {
            var targetParts = _targetPartsForSlot(slot);
            if (targetParts == null) {
                return null;
            }

            var targetYear = targetParts[:year] as Lang.Number;
            var targetMonth = targetParts[:month] as Lang.Number;
            var targetDay = targetParts[:day] as Lang.Number;
            if (!_validModeProperty(_slotKey(slot, "use_specific_time"))
                || !_validModeProperty(_slotKey(slot, "all_day"))) {
                return null;
            }

            var targetHour = _boundedNumber(_slotKey(slot, "target_hour"), 0, 23, 0);
            var targetMinute = _boundedNumber(_slotKey(slot, "target_minute"), 0, 59, 0);
            var useSpecificTime = _useSpecificTime(slot, targetHour, targetMinute);
            var allDay = !useSpecificTime;
            if (!allDay && (!_validTimeProperty(_slotKey(slot, "target_hour"), 23)
                || !_validTimeProperty(_slotKey(slot, "target_minute"), 59))) {
                return null;
            }
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
        } catch (e) {
            return null;
        }
    }

    static function _storedTargetEpoch(slot as Lang.Number, targetYear as Lang.Number, targetMonth as Lang.Number, targetDay as Lang.Number, allDay as Lang.Boolean, targetHour as Lang.Number, targetMinute as Lang.Number) as Lang.Number {
        return CountdownTargetTime.forSlot(slot, targetYear, targetMonth, targetDay, allDay, targetHour, targetMinute);
    }

    static function _targetPartsForSlot(slot as Lang.Number) as Lang.Dictionary or Null {
        var year = _propertyNumber(_slotKey(slot, "target_year"));
        var month = _propertyNumber(_slotKey(slot, "target_month"));
        var day = _propertyNumber(_slotKey(slot, "target_day"));

        if (!_validDateProperty(_slotKey(slot, "target_year"))
            || !_validDateProperty(_slotKey(slot, "target_month"))
            || !_validDateProperty(_slotKey(slot, "target_day"))) {
            return null;
        }

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

    static function _validModeProperty(key as String) as Lang.Boolean {
        var value = _propertyValue(key);
        return value == null || _booleanOrNull(value) != null;
    }

    static function _validDateProperty(key as String) as Lang.Boolean {
        var value = _propertyValue(key);
        return value == null || (value instanceof Lang.String && value.length() == 0) || CountdownTargetTime.number(value) != null;
    }

    static function _validTimeProperty(key as String, maximum as Lang.Number) as Lang.Boolean {
        var value = _propertyValue(key);
        if (value == null) {
            return true;
        }
        var parsed = CountdownTargetTime.number(value);
        return parsed != null && parsed >= 0 && parsed <= maximum;
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

        return CountdownTargetTime.number(text);
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
        if (text.equals("true")) {
            return true;
        }

        if (text.equals("1")) {
            return true;
        }

        if (text.equals("false")) {
            return false;
        }

        if (text.equals("0")) {
            return false;
        }

        var numericValue = CountdownTargetTime.number(text);
        if (numericValue != null) {
            return numericValue != 0;
        }

        return null;
    }
}
