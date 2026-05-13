import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

const MAX_TIMER_SLOTS = 5;
const SPECIFIC_TIME_MIGRATION_FLAG = "use_specific_time_migration_complete";
const DATE_PARTS_MIGRATION_FLAG = "date_parts_migration_complete";
const TARGET_SIGNATURE_SUFFIX = "target_signature";

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
        _syncStoredTargetEpochs();
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

        if (_hasExplicitDateParts(prefix)) {
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

    function _syncStoredTargetEpochs() as Void {
        for (var slot = 1; slot <= MAX_TIMER_SLOTS; slot += 1) {
            _syncStoredTargetEpoch(slot);
        }
    }

    function _syncStoredTargetEpoch(slot as Lang.Number) as Void {
        var prefix = "event" + slot.toString() + "_";
        var epochKey = prefix + "target_epoch";
        var signatureKey = prefix + TARGET_SIGNATURE_SUFFIX;
        var dateParts = _datePartsForSlot(prefix);

        if (dateParts == null) {
            Storage.deleteValue(epochKey);
            Storage.deleteValue(signatureKey);
            return;
        }

        try {
            var targetYear = dateParts[:year] as Lang.Number;
            var targetMonth = dateParts[:month] as Lang.Number;
            var targetDay = dateParts[:day] as Lang.Number;
            var useSpecificTime = _useSpecificTime(prefix);
            var targetHour = _boundedNumber(prefix + "target_hour", 0, 23, 0);
            var targetMinute = _boundedNumber(prefix + "target_minute", 0, 59, 0);
            if (!useSpecificTime) {
                targetHour = 0;
                targetMinute = 0;
            }

            var currentSignature = CountdownEvents.targetSignature(targetYear, targetMonth, targetDay, !useSpecificTime, targetHour, targetMinute);
            var storedSignature = _storageText(signatureKey);
            var storedEpoch = _storageNumber(epochKey);
            if (storedEpoch != null && storedEpoch > 0 && storedSignature == currentSignature) {
                return;
            }

            var resolvedEpoch = CountdownEvents.resolveTargetEpochForDate(targetYear, targetMonth, targetDay, targetHour, targetMinute);
            var legacyEpoch = _propertyNumber(epochKey);
            if (legacyEpoch != null && legacyEpoch > 0 && (storedSignature == currentSignature || legacyEpoch == resolvedEpoch)) {
                Storage.setValue(epochKey, legacyEpoch);
            } else {
                Storage.setValue(epochKey, resolvedEpoch);
            }

            Storage.setValue(signatureKey, currentSignature);
        } catch (e) {
            return;
        }
    }

    function _useSpecificTime(prefix as String) as Lang.Boolean {
        var useSpecificTime = _propertyBooleanOrNull(prefix + "use_specific_time");
        if (useSpecificTime != null) {
            return useSpecificTime as Lang.Boolean;
        }

        var allDay = _propertyBooleanOrNull(prefix + "all_day");
        if (allDay != null) {
            return !(allDay as Lang.Boolean);
        }

        var targetHour = _boundedNumber(prefix + "target_hour", 0, 23, 0);
        var targetMinute = _boundedNumber(prefix + "target_minute", 0, 59, 0);
        return targetHour != 0 || targetMinute != 0;
    }

    function _datePartsForSlot(prefix as String) as Lang.Dictionary or Null {
        var year = _propertyNumber(prefix + "target_year");
        var month = _propertyNumber(prefix + "target_month");
        var day = _propertyNumber(prefix + "target_day");

        if (_hasDateParts(year, month, day)) {
            if (_isValidDate(year, month, day)) {
                return { :year => year, :month => month, :day => day };
            }

            return null;
        }

        var legacyTargetDate = _propertyNumber(prefix + "target_date");
        if (legacyTargetDate == null || legacyTargetDate <= 0) {
            return null;
        }

        var dateInfo = Gregorian.utcInfo(new Time.Moment(legacyTargetDate), Time.FORMAT_SHORT);
        return { :year => dateInfo.year, :month => dateInfo.month as Lang.Number, :day => dateInfo.day };
    }

    function _hasExplicitDateParts(prefix as String) as Lang.Boolean {
        return _hasDateParts(_propertyNumber(prefix + "target_year"), _propertyNumber(prefix + "target_month"), _propertyNumber(prefix + "target_day"));
    }

    function _hasDateParts(year as Lang.Number or Null, month as Lang.Number or Null, day as Lang.Number or Null) as Lang.Boolean {
        return (year != null && year > 0) || (month != null && month > 0) || (day != null && day > 0);
    }

    function _isValidDate(year as Lang.Number or Null, month as Lang.Number or Null, day as Lang.Number or Null) as Lang.Boolean {
        if (year == null || month == null || day == null) {
            return false;
        }

        if (year < 1970 || month < 1 || month > 12 || day < 1) {
            return false;
        }

        return day <= _daysInMonth(year, month);
    }

    function _daysInMonth(year as Lang.Number, month as Lang.Number) as Lang.Number {
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

    function _isLeapYear(year as Lang.Number) as Lang.Boolean {
        if (year % 400 == 0) {
            return true;
        }

        if (year % 100 == 0) {
            return false;
        }

        return year % 4 == 0;
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

        return value.toString().toNumber();
    }

    function _storageNumber(key as String) as Lang.Number or Null {
        var value = Storage.getValue(key);
        if (value == null) {
            return null;
        }

        return value.toString().toNumber();
    }

    function _propertyText(key as String) as String or Null {
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

    function _storageText(key as String) as String or Null {
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

    function _propertyBoolean(key as String, defaultValue as Lang.Boolean) as Lang.Boolean {
        var value = _propertyValue(key);
        var parsed = _booleanOrNull(value);
        if (parsed != null) {
            return parsed as Lang.Boolean;
        }

        return defaultValue;
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
