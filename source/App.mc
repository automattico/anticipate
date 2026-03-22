import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Lang;

class CountdownApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) as Void {
        _seedDemoTimersIfMissing();
    }

    function onStop(state) as Void {
    }

    (:typecheck(disableGlanceCheck))
    function getInitialView() {
        var view = new CountdownWidgetView();
        return [view, new CountdownWidgetDelegate(view)];
    }

    function onSettingsChanged() as Void {
    }

    function _seedDemoTimersIfMissing() as Void {
        if (CountdownEvents.firstConfiguredEvent() != null) {
            return;
        }

        _setTimer(1, "End of Brasil ban", 1780531200L, 0, 0);
        _setTimer(2, "4:20", 1776643200L, 16, 20);
        _setTimer(3, "My Birthday", 1796860800L, 0, 0);
        _setTimer(4, "Jule Bday Party 🥳", 1790640000L, 12, 0);
        _setTimer(5, "", 0, 0, 0);
    }

    function _setTimer(slot as Lang.Number, name as Lang.String, targetDate as Lang.Numeric, hour as Lang.Number, minute as Lang.Number) as Void {
        var prefix = "event" + slot.toString() + "_";
        Properties.setValue(prefix + "name", name);
        Properties.setValue(prefix + "target_date", targetDate);
        Properties.setValue(prefix + "target_hour", hour);
        Properties.setValue(prefix + "target_minute", minute);
    }
}
