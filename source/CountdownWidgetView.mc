import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class CountdownWidgetView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        _drawStage(dc);

        var event = _currentEvent();
        if (event == null) {
            _drawEmptyState(dc);
            return;
        }

        var state = CountdownMath.calculate(event, CountdownMath.now());
        _drawConfiguredState(dc, event, state);
    }

    function onHide() as Void {
    }

    function _drawStage(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_BLACK);
        dc.fillCircle(104, 104, 78);

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_DK_BLUE);
        dc.drawCircle(104, 104, 78);
        dc.drawCircle(104, 104, 77);
    }

    function _drawEmptyState(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_DK_BLUE);
        dc.drawText(104, 84, Graphics.FONT_SMALL, _resourceText(Rez.Strings.FallbackNoEventsTitle), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(104, 110, Graphics.FONT_XTINY, _resourceText(Rez.Strings.FallbackNoEventsHintLine1), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(104, 124, Graphics.FONT_XTINY, _resourceText(Rez.Strings.FallbackNoEventsHintLine2), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _drawConfiguredState(dc as Dc, event as EventConfig, state as CountdownState) as Void {
        var title = CountdownFormatter.fitTitleToWidth(dc, event.name, 128);
        var dateLine = CountdownFormatter.formatTargetDateLine(event);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_DK_BLUE);
        dc.drawText(104, 50, Graphics.FONT_SMALL, title, Graphics.TEXT_JUSTIFY_CENTER);

        if (state.isDone) {
            dc.drawText(104, 98, Graphics.FONT_LARGE, "DONE", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(104, 136, Graphics.FONT_TINY, "Event passed", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(104, 158, Graphics.FONT_XTINY, dateLine, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (state.isNow) {
            dc.drawText(104, 98, Graphics.FONT_LARGE, "TODAY", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(104, 136, Graphics.FONT_TINY, "It's happening", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(104, 158, Graphics.FONT_XTINY, dateLine, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (state.days > 0) {
            var dayText = state.days.toString();
            dc.drawText(104, 72, Graphics.FONT_TINY, "Only", Graphics.TEXT_JUSTIFY_CENTER);
            _drawDayNumber(dc, dayText);
            dc.drawText(104, 144, Graphics.FONT_SMALL, _dayLabel(state.days), Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(104, 164, Graphics.FONT_XTINY, dateLine, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        var primary = CountdownFormatter.formatMainPrimary(state);
        var secondary = CountdownFormatter.formatMainSecondary(state);
        dc.drawText(104, 74, Graphics.FONT_TINY, "Next up", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(104, 112, Graphics.FONT_LARGE, primary, Graphics.TEXT_JUSTIFY_CENTER);

        if (secondary != "") {
            dc.drawText(104, 144, Graphics.FONT_SMALL, secondary + " left", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(104, 144, Graphics.FONT_SMALL, "to go", Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.drawText(104, 164, Graphics.FONT_XTINY, dateLine, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _drawDayNumber(dc as Dc, text as String) as Void {
        if (dc.getTextWidthInPixels(text, Graphics.FONT_NUMBER_MEDIUM) <= 108) {
            dc.drawText(104, 104, Graphics.FONT_NUMBER_MEDIUM, text, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (dc.getTextWidthInPixels(text, Graphics.FONT_NUMBER_MILD) <= 120) {
            dc.drawText(104, 104, Graphics.FONT_NUMBER_MILD, text, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        dc.drawText(104, 104, Graphics.FONT_LARGE, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _dayLabel(days as Lang.Number) as String {
        if (days == 1) {
            return "day left";
        }

        return "days left";
    }

    function _currentEvent() as EventConfig or Null {
        var targetEpoch = _propertyNumber("event1_target_date");
        if (targetEpoch == null || targetEpoch <= 0) {
            return null;
        }

        var name = _propertyText("event1_name");
        if (name == null || name.length() == 0) {
            name = "Event";
        }

        return new EventConfig(name, ICON_CALENDAR, targetEpoch, true);
    }

    function _propertyValue(key as String) as Lang.Object or Null {
        try {
            return Properties.getValue(key);
        } catch (e) {
            return null;
        }
    }

    function _propertyText(key as String) as String or Null {
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

    function _propertyNumber(key as String) as Lang.Number or Null {
        var text = _propertyText(key);
        if (text == null) {
            return null;
        }

        return text.toNumber();
    }

    function _resourceText(resourceId as Lang.ResourceId) as String {
        return WatchUi.loadResource(resourceId).toString();
    }
}

class CountdownWidgetDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onNextPage() as Boolean {
        return false;
    }

    function onPreviousPage() as Boolean {
        return false;
    }

    function onSelect() as Boolean {
        return false;
    }
}
