import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:glance)
class CountdownGlanceSupport {

    static function buildFirstCountdownGlanceSummary() as Lang.Dictionary or Null {
        var event = _firstConfiguredEvent();
        if (event == null) {
            return null;
        }

        var detail = formatDetail(event as Lang.Dictionary);
        if (detail == null || detail.length() == 0) {
            return null;
        }

        return {
            :title => _safeTitle(event as Lang.Dictionary),
            :detail => detail
        };
    }

    static function formatDetail(event as Lang.Dictionary) as String or Null {
        if ((event[:allDay] as Lang.Boolean)) {
            return _formatAllDayDetail(event);
        }

        return _formatTimedDetail(event);
    }

    static function glanceSeparator() as Lang.String {
        return 32.toChar().toString() + 183.toChar().toString() + 32.toChar().toString();
    }

    static function _safeTitle(event as Lang.Dictionary) as String {
        var name = event[:name] as String;
        if (name.length() == 0) {
            return "EVENT";
        }

        return name.toUpper();
    }

    static function _formatAllDayDetail(event as Lang.Dictionary) as String or Null {
        var state = _calculateTimedState(event);
        if ((state[:isDone] as Lang.Boolean)) {
            return "DONE";
        }

        if ((state[:isNow] as Lang.Boolean)) {
            return "TODAY";
        }

        return _formatStateDetail(state);
    }

    static function _formatTimedDetail(event as Lang.Dictionary) as String or Null {
        var state = _calculateTimedState(event);
        if ((state[:isDone] as Lang.Boolean)) {
            return "DONE";
        }

        if ((state[:isNow] as Lang.Boolean)) {
            return "TODAY";
        }

        return _formatStateDetail(state);
    }

    static function _formatStateDetail(state as Lang.Dictionary) as String {
        return (state[:days] as Lang.Number).toString() + "d "
            + (state[:hours] as Lang.Number).toString() + "h "
            + (state[:minutes] as Lang.Number).toString() + "m "
            + (state[:seconds] as Lang.Number).toString() + "s";
    }

    static function _firstConfiguredEvent() as Lang.Dictionary or Null {
        for (var slot = 1; slot <= 5; slot += 1) {
            var event = _eventForSlot(slot);
            if (event != null) {
                return event;
            }
        }

        return null;
    }

    static function _eventForSlot(slot as Lang.Number) as Lang.Dictionary or Null {
        var dateParts = _datePartsForSlot(slot);
        if (dateParts == null) {
            return null;
        }

        var targetHour = _boundedNumber(_slotKey(slot, "target_hour"), 0, 23, 0);
        var targetMinute = _boundedNumber(_slotKey(slot, "target_minute"), 0, 59, 0);
        var useSpecificTime = _useSpecificTime(slot, targetHour, targetMinute);
        var allDay = !useSpecificTime;
        var epochHour = targetHour;
        var epochMinute = targetMinute;
        if (allDay) {
            epochHour = 0;
            epochMinute = 0;
        }

        return {
            :name => _eventName(slot),
            :allDay => allDay,
            :targetYear => dateParts[:year] as Lang.Number,
            :targetMonth => dateParts[:month] as Lang.Number,
            :targetDay => dateParts[:day] as Lang.Number,
            :targetHour => targetHour,
            :targetMinute => targetMinute,
            :targetEpoch => _resolveTargetEpochForDate(dateParts[:year] as Lang.Number, dateParts[:month] as Lang.Number, dateParts[:day] as Lang.Number, epochHour, epochMinute)
        };
    }

    static function _eventName(slot as Lang.Number) as String {
        var name = _propertyText(_slotKey(slot, "name"));
        if (name == null) {
            return "Event " + slot.toString();
        }

        return name;
    }

    static function _datePartsForSlot(slot as Lang.Number) as Lang.Dictionary or Null {
        var year = _propertyNumber(_slotKey(slot, "target_year"));
        var month = _propertyNumber(_slotKey(slot, "target_month"));
        var day = _propertyNumber(_slotKey(slot, "target_day"));

        if (_hasDateParts(year, month, day)) {
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

    static function _calculateTimedState(event as Lang.Dictionary) as Lang.Dictionary {
        var nowEpoch = Time.now().value();
        var targetEpoch = event[:targetEpoch] as Lang.Number;
        var deltaSeconds = targetEpoch - nowEpoch;
        var secondsPerDay = _secondsPerDay();
        var secondsPerHour = _secondsPerHour();
        var secondsPerMinute = _secondsPerMinute();
        var isNow = nowEpoch >= targetEpoch && nowEpoch < (targetEpoch + secondsPerDay);
        var isDone = nowEpoch >= (targetEpoch + secondsPerDay);
        var remaining = deltaSeconds;

        if (remaining < 0) {
            remaining = 0;
        }

        var days = _wholeNumber(Math.floor(remaining / secondsPerDay));
        var hours = _wholeNumber(Math.floor((remaining % secondsPerDay) / secondsPerHour));
        var minutes = _wholeNumber(Math.floor((remaining % secondsPerHour) / secondsPerMinute));
        var seconds = _wholeNumber(Math.floor(remaining % secondsPerMinute));

        if (isNow || isDone) {
            days = 0;
            hours = 0;
            minutes = 0;
            seconds = 0;
        }

        return {
            :isNow => isNow,
            :isDone => isDone,
            :days => days,
            :hours => hours,
            :minutes => minutes,
            :seconds => seconds
        };
    }

    static function _resolveTargetEpochForDate(year as Lang.Number, month as Lang.Number, day as Lang.Number, targetHour as Lang.Number, targetMinute as Lang.Number) as Lang.Number {
        return Gregorian.moment({
            :year => year,
            :month => month,
            :day => day,
            :hour => targetHour,
            :minute => targetMinute,
            :second => 0
        }).value() as Lang.Number;
    }

    static function _slotKey(slot as Lang.Number, suffix as String) as String {
        return "event" + slot.toString() + "_" + suffix;
    }

    static function _propertyValue(key as String) as Lang.Object or Null {
        try {
            return Properties.getValue(key);
        } catch (e) {
            return null;
        }
    }

    static function _propertyText(key as String) as String or Null {
        var value = _propertyValue(key);
        if (value == null) {
            return null;
        }

        var text = value.toString();
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

    static function _boundedNumber(key as String, minValue as Lang.Number, maxValue as Lang.Number, defaultValue as Lang.Number) as Lang.Number {
        var value = _propertyNumber(key);
        if (value == null || value < minValue || value > maxValue) {
            return defaultValue;
        }

        return value;
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

    static function _hasDateParts(year as Lang.Number or Null, month as Lang.Number or Null, day as Lang.Number or Null) as Lang.Boolean {
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

    static function _secondsPerMinute() as Lang.Number {
        return 60;
    }

    static function _secondsPerHour() as Lang.Number {
        return 60 * _secondsPerMinute();
    }

    static function _secondsPerDay() as Lang.Number {
        return 24 * _secondsPerHour();
    }

    static function _wholeNumber(value as Lang.Numeric) as Lang.Number {
        var parsed = value.toString().toNumber();
        if (parsed == null) {
            return 0;
        }

        return parsed;
    }
}
