import Toybox.Application;

class CountdownApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) as Void {
    }

    function onStop(state) as Void {
    }

    function getInitialView() {
        return [new CountdownWidgetView(), new CountdownWidgetDelegate()];
    }

    function onSettingsChanged() as Void {
    }
}
