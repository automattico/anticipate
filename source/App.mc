import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Lang;

class CountdownApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) as Void {
        _seedDemoEventIfMissing();
    }

    function onStop(state) as Void {
    }

    function getInitialView() {
        return [new CountdownWidgetView(), new CountdownWidgetDelegate()];
    }

    function onSettingsChanged() as Void {
    }

    function _seedDemoEventIfMissing() as Void {
        var targetDate = _propertyValue("event1_target_date");

        if (_positiveNumber(targetDate) != null) {
            return;
        }

        Properties.setValue("event1_name", "Summer Trip");
        Properties.setValue("event1_target_date", 1780531200L);
    }

    function _propertyValue(key as String) as Lang.Object or Null {
        try {
            return Properties.getValue(key);
        } catch (e) {
            return null;
        }
    }

    function _positiveNumber(rawValue as Lang.Object or Null) as Lang.Number or Null {
        if (rawValue == null) {
            return null;
        }

        var parsed = rawValue.toString().toNumber();
        if (parsed != null && parsed > 0) {
            return parsed;
        }

        return null;
    }
}
