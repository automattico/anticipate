import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

const MAX_TIMER_SLOTS = 5;
const SPECIFIC_TIME_MIGRATION_FLAG = "use_specific_time_migration_complete";
const DATE_PARTS_MIGRATION_FLAG = "date_parts_migration_complete";

(:typecheck(disableGlanceCheck))
class CountdownApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) as Void {
    }

    function onStop(state) as Void {
    }

    (:typecheck(disableGlanceCheck))
    function getInitialView() {
        _prepareCountdownData();
        var view = new CountdownWidgetView();
        return [view, new CountdownWidgetDelegate(view)];
    }

    (:glance)
    function getGlanceView() {
        var summary = CountdownGlanceSupport.buildFirstCountdownGlanceSummary();
        if (summary == null) {
            return null;
        }

        return [new CountdownGlanceView(summary)];
    }

    function onSettingsChanged() as Void {
        _prepareCountdownData();
    }

    function _prepareCountdownData() as Void {
        _migrateDatePartsIfNeeded();
        _migrateSpecificTimeFlagsIfNeeded();
        CountdownEvents.configuredEvents();
    }

    function _migrateDatePartsIfNeeded() as Void {
        if (_storageBoolean(DATE_PARTS_MIGRATION_FLAG, false)) {
            return;
        }

        for (var slot = 1; slot <= MAX_TIMER_SLOTS; slot += 1) {
            _migrateDatePartsForSlot(slot);
        }

        Storage.setValue(DATE_PARTS_MIGRATION_FLAG, true);
    }

    function _migrateDatePartsForSlot(slot as Lang.Number) as Void {
        var prefix = "event" + slot.toString() + "_";

        // Invalid explicit fields belong to the user too; do not migrate over them.
        if (_hasExplicitDateParts(prefix)
            || !_validDateProperty(prefix + "target_year")
            || !_validDateProperty(prefix + "target_month")
            || !_validDateProperty(prefix + "target_day")) {
            return;
        }

        var legacyTargetDate = _propertyNumber(prefix + "target_date");
        if (legacyTargetDate == null || legacyTargetDate <= 0) {
            return;
        }

        var dateInfo = Gregorian.utcInfo(new Time.Moment(legacyTargetDate), Time.FORMAT_SHORT);
        Properties.setValue(prefix + "target_year", dateInfo.year.toString());
        Properties.setValue(prefix + "target_month", (dateInfo.month as Lang.Number).toString());
        Properties.setValue(prefix + "target_day", dateInfo.day.toString());
    }

    function _migrateSpecificTimeFlagsIfNeeded() as Void {
        if (_storageBoolean(SPECIFIC_TIME_MIGRATION_FLAG, false)) {
            return;
        }

        for (var slot = 1; slot <= MAX_TIMER_SLOTS; slot += 1) {
            _migrateSpecificTimeFlagForSlot(slot);
        }

        Storage.setValue(SPECIFIC_TIME_MIGRATION_FLAG, true);
    }

    function _migrateSpecificTimeFlagForSlot(slot as Lang.Number) as Void {
        var prefix = "event" + slot.toString() + "_";
        var useSpecificTimeKey = prefix + "use_specific_time";
        var rawMode = _propertyValue(useSpecificTimeKey);
        var rawAllDay = _propertyValue(prefix + "all_day");
        if ((rawMode != null && _booleanOrNull(rawMode) == null)
            || (rawAllDay != null && _booleanOrNull(rawAllDay) == null)) {
            return;
        }
        var useSpecificTime;
        var existingUseSpecificTime = _propertyBooleanOrNull(useSpecificTimeKey);
        var allDay = _propertyBooleanOrNull(prefix + "all_day");
        if (existingUseSpecificTime != null && (existingUseSpecificTime as Lang.Boolean)) {
            useSpecificTime = true;
        } else if (allDay != null) {
            useSpecificTime = !(allDay as Lang.Boolean);
        } else {
            var targetHour = _boundedNumber(prefix + "target_hour", 0, 23, 0);
            var targetMinute = _boundedNumber(prefix + "target_minute", 0, 59, 0);
            useSpecificTime = targetHour != 0 || targetMinute != 0;
        }

        Properties.setValue(useSpecificTimeKey, useSpecificTime);
    }

    function _validDateProperty(key as String) as Lang.Boolean {
        var value = _propertyValue(key);
        return value == null || (value instanceof Lang.String && value.length() == 0) || CountdownTargetTime.number(value) != null;
    }

    function _hasExplicitDateParts(prefix as String) as Lang.Boolean {
        return _hasDateParts(_propertyNumber(prefix + "target_year"), _propertyNumber(prefix + "target_month"), _propertyNumber(prefix + "target_day"));
    }

    function _hasDateParts(year as Lang.Number or Null, month as Lang.Number or Null, day as Lang.Number or Null) as Lang.Boolean {
        return (year != null && year > 0) || (month != null && month > 0) || (day != null && day > 0);
    }

    function _boundedNumber(key as String, minValue as Lang.Number, maxValue as Lang.Number, defaultValue as Lang.Number) as Lang.Number {
        var value = _propertyNumber(key);
        if (value == null || value < minValue || value > maxValue) {
            return defaultValue;
        }

        return value;
    }

    function _propertyValue(key as String) as Lang.Object or Null {
        try {
            return Properties.getValue(key);
        } catch (e) {
            return null;
        }
    }

    function _propertyNumber(key as String) as Lang.Number or Null {
        var value = _propertyValue(key);
        if (value == null) {
            return null;
        }

        return CountdownTargetTime.number(value);
    }

    function _storageBoolean(key as String, defaultValue as Lang.Boolean) as Lang.Boolean {
        var value = Storage.getValue(key);
        if (value == null) {
            return defaultValue;
        }

        var parsed = _booleanOrNull(value);
        if (parsed == null) {
            return defaultValue;
        }

        return parsed as Lang.Boolean;
    }

    function _propertyBooleanOrNull(key as String) as Lang.Boolean or Null {
        return _booleanOrNull(_propertyValue(key));
    }

    function _booleanOrNull(value as Lang.Object or Null) as Lang.Boolean or Null {
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
