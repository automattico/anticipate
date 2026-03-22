import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Lang;

const MAX_TIMER_SLOTS = 5;

class CountdownApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) as Void {
        _seedDemoTimersIfMissing();
        _migrateLegacyDemoTimerOrderIfNeeded();
        _refreshStoredTargetEpochs();
    }

    function onStop(state) as Void {
    }

    (:typecheck(disableGlanceCheck))
    function getInitialView() {
        var view = new CountdownWidgetView();
        return [view, new CountdownWidgetDelegate(view)];
    }

    function onSettingsChanged() as Void {
        _refreshStoredTargetEpochs();
    }

    function _seedDemoTimersIfMissing() as Void {
        if (CountdownEvents.firstConfiguredEvent() != null) {
            return;
        }

        _setTimer(1, "My Birthday", 1796860800L, 0, 0);
        _setTimer(2, "Jule Bday 🥳 Party", 1790640000L, 12, 0);
        _setTimer(3, "End of Brasil ban", 1780531200L, 0, 0);
        _setTimer(4, "4:20", 1776643200L, 16, 20);
        _setTimer(5, "", 0, 0, 0);
    }

    function _migrateLegacyDemoTimerOrderIfNeeded() as Void {
        if (!_matchesLegacyDemoTimerOrder()) {
            return;
        }

        _setTimer(1, "My Birthday", 1796860800L, 0, 0);
        _setTimer(2, "Jule Bday 🥳 Party", 1790640000L, 12, 0);
        _setTimer(3, "End of Brasil ban", 1780531200L, 0, 0);
        _setTimer(4, "4:20", 1776643200L, 16, 20);
    }

    function _matchesLegacyDemoTimerOrder() as Lang.Boolean {
        return _matchesTimer(1, "End of Brasil ban", 1780531200, 0, 0)
            && _matchesTimer(2, "4:20", 1776643200, 16, 20)
            && _matchesTimer(3, "My Birthday", 1796860800, 0, 0)
            && _matchesLegacyJuleTimer(4);
    }

    function _matchesLegacyJuleTimer(slot as Lang.Number) as Lang.Boolean {
        return _matchesTimer(slot, "Jule Bday Party 🥳", 1790640000, 12, 0)
            || _matchesTimer(slot, "Jule Bday 🥳 Party", 1790640000, 12, 0);
    }

    function _matchesTimer(slot as Lang.Number, name as Lang.String, targetDate as Lang.Number, hour as Lang.Number, minute as Lang.Number) as Lang.Boolean {
        var prefix = "event" + slot.toString() + "_";
        return _propertyText(prefix + "name") == name
            && _propertyNumber(prefix + "target_date") == targetDate
            && _boundedNumber(prefix + "target_hour", 0, 23, 0) == hour
            && _boundedNumber(prefix + "target_minute", 0, 59, 0) == minute;
    }

    function _setTimer(slot as Lang.Number, name as Lang.String, targetDate as Lang.Numeric, hour as Lang.Number, minute as Lang.Number) as Void {
        var prefix = "event" + slot.toString() + "_";
        Properties.setValue(prefix + "name", name);
        Properties.setValue(prefix + "target_date", targetDate);
        Properties.setValue(prefix + "target_hour", hour);
        Properties.setValue(prefix + "target_minute", minute);
        Properties.setValue(prefix + "target_epoch", _resolvedTargetEpoch(targetDate, hour, minute));
    }

    function _refreshStoredTargetEpochs() as Void {
        for (var slot = 1; slot <= MAX_TIMER_SLOTS; slot += 1) {
            _refreshStoredTargetEpoch(slot);
        }
    }

    function _refreshStoredTargetEpoch(slot as Lang.Number) as Void {
        var prefix = "event" + slot.toString() + "_";
        var targetDate = _propertyNumber(prefix + "target_date");

        if (targetDate == null || targetDate <= 0) {
            Properties.setValue(prefix + "target_epoch", 0);
            return;
        }

        var targetHour = _boundedNumber(prefix + "target_hour", 0, 23, 0);
        var targetMinute = _boundedNumber(prefix + "target_minute", 0, 59, 0);
        Properties.setValue(prefix + "target_epoch", CountdownEvents.resolveTargetEpoch(targetDate, targetHour, targetMinute));
    }

    function _resolvedTargetEpoch(targetDate as Lang.Numeric, hour as Lang.Number, minute as Lang.Number) as Lang.Number {
        if (targetDate <= 0) {
            return 0;
        }

        return CountdownEvents.resolveTargetEpoch(targetDate, hour, minute);
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
}
