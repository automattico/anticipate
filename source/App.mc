import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Application.Storage;
import Toybox.Lang;

const MAX_TIMER_SLOTS = 5;
const ALL_DAY_MIGRATION_FLAG = "all_day_migration_complete";
const TARGET_SIGNATURE_SUFFIX = "target_signature";

class CountdownApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) as Void {
        _migrateAllDayFlagsIfNeeded();
        _syncStoredTargetEpochs();
    }

    function onStop(state) as Void {
    }

    (:typecheck(disableGlanceCheck))
    function getInitialView() {
        var view = new CountdownWidgetView();
        return [view, new CountdownWidgetDelegate(view)];
    }

    function onSettingsChanged() as Void {
        _migrateAllDayFlagsIfNeeded();
        _syncStoredTargetEpochs();
    }

    function _migrateAllDayFlagsIfNeeded() as Void {
        if (_propertyBoolean(ALL_DAY_MIGRATION_FLAG, false)) {
            return;
        }

        for (var slot = 1; slot <= MAX_TIMER_SLOTS; slot += 1) {
            _migrateAllDayFlagForSlot(slot);
        }

        Properties.setValue(ALL_DAY_MIGRATION_FLAG, true);
    }

    function _migrateAllDayFlagForSlot(slot as Lang.Number) as Void {
        var prefix = "event" + slot.toString() + "_";
        var allDayKey = prefix + "all_day";
        var targetDate = _propertyNumber(prefix + "target_date");
        if (targetDate == null || targetDate <= 0) {
            Properties.setValue(allDayKey, true);
            return;
        }

        var targetHour = _boundedNumber(prefix + "target_hour", 0, 23, 0);
        var targetMinute = _boundedNumber(prefix + "target_minute", 0, 59, 0);
        Properties.setValue(allDayKey, targetHour == 0 && targetMinute == 0);
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
        var targetDate = _propertyNumber(prefix + "target_date");

        if (targetDate == null || targetDate <= 0) {
            Properties.setValue(epochKey, 0);
            Storage.deleteValue(signatureKey);
            return;
        }

        var isAllDay = _propertyBoolean(prefix + "all_day", true);
        var targetHour = _boundedNumber(prefix + "target_hour", 0, 23, 0);
        var targetMinute = _boundedNumber(prefix + "target_minute", 0, 59, 0);
        if (isAllDay) {
            targetHour = 0;
            targetMinute = 0;
        }

        var currentSignature = _targetSignature(targetDate, isAllDay, targetHour, targetMinute);
        var storedSignature = _storageText(signatureKey);
        var storedEpoch = _propertyNumber(epochKey);
        if (storedEpoch != null && storedEpoch > 0) {
            if (storedSignature == null) {
                Storage.setValue(signatureKey, currentSignature);
                return;
            }

            if (storedSignature == currentSignature) {
                return;
            }
        }

        Properties.setValue(epochKey, CountdownEvents.resolveTargetEpoch(targetDate, targetHour, targetMinute));
        Storage.setValue(signatureKey, currentSignature);
    }

    function _targetSignature(targetDate as Lang.Number, isAllDay as Lang.Boolean, targetHour as Lang.Number, targetMinute as Lang.Number) as String {
        if (isAllDay) {
            return targetDate.toString() + "|1";
        }

        return targetDate.toString() + "|0|" + targetHour.toString() + "|" + targetMinute.toString();
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
        if (value == null) {
            return defaultValue;
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

        return defaultValue;
    }
}
