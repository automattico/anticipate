import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

class CountdownWidgetView extends WatchUi.View {

    const CENTER_X = 104;
    const KICKER_Y = 30;
    const TITLE_Y = 56;
    const PRIMARY_VALUE_Y = 92;
    const PRIMARY_DETAIL_Y = 126;
    const PRIMARY_AUX_Y = 148;
    const PRIMARY_DATE_Y = 172;
    var _refreshTimer as Timer.Timer or Null;

    function initialize() {
        View.initialize();
        _refreshTimer = null;
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        WatchUi.requestUpdate();
        _startRefreshTimer();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var event = _currentEvent();
        if (event == null) {
            _drawEmptyState(dc);
            return;
        }

        var state = CountdownMath.calculate(event, CountdownMath.now());
        _drawConfiguredState(dc, event, state);
    }

    function onHide() as Void {
        _stopRefreshTimer();
    }

    function _drawEmptyState(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(CENTER_X, 42, Graphics.FONT_XTINY, "ANTICIPATE", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(CENTER_X, 88, Graphics.FONT_SMALL, _resourceText(Rez.Strings.FallbackNoEventsTitle), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(CENTER_X, 120, Graphics.FONT_XTINY, _resourceText(Rez.Strings.FallbackNoEventsHintLine1), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(CENTER_X, 134, Graphics.FONT_XTINY, _resourceText(Rez.Strings.FallbackNoEventsHintLine2), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _drawConfiguredState(dc as Dc, event as EventConfig, state as CountdownState) as Void {
        var title = CountdownFormatter.fitTitleToWidth(dc, event.name, 150);
        var dateLine = CountdownFormatter.formatTargetDateLine(event);
        _drawTitle(dc, title);

        if (state.isDone) {
            dc.drawText(CENTER_X, PRIMARY_VALUE_Y, Graphics.FONT_LARGE, "DONE", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(CENTER_X, PRIMARY_DETAIL_Y, Graphics.FONT_TINY, "Event passed", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(CENTER_X, PRIMARY_DATE_Y, Graphics.FONT_XTINY, dateLine, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (state.isNow) {
            dc.drawText(CENTER_X, PRIMARY_VALUE_Y, Graphics.FONT_LARGE, "TODAY", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(CENTER_X, PRIMARY_DETAIL_Y, Graphics.FONT_TINY, "It's happening", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(CENTER_X, PRIMARY_DATE_Y, Graphics.FONT_XTINY, dateLine, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (state.days > 0) {
            var dayText = state.days.toString();
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            _drawDayNumber(dc, dayText);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(CENTER_X, PRIMARY_DETAIL_Y, Graphics.FONT_TINY, _dayLabel(state.days), Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(CENTER_X, PRIMARY_AUX_Y, Graphics.FONT_XTINY, _formatInlineTime(state), Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(CENTER_X, PRIMARY_DATE_Y, Graphics.FONT_XTINY, dateLine, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        _drawSubdayStrip(dc, state);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(CENTER_X, PRIMARY_DATE_Y, Graphics.FONT_XTINY, dateLine, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _drawTitle(dc as Dc, title as String) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(CENTER_X, KICKER_Y, Graphics.FONT_XTINY, "COUNTDOWN TO", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(CENTER_X, TITLE_Y, Graphics.FONT_SMALL, title, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _drawDayNumber(dc as Dc, text as String) as Void {
        if (dc.getTextWidthInPixels(text, Graphics.FONT_NUMBER_MEDIUM) <= 108) {
            dc.drawText(CENTER_X, PRIMARY_VALUE_Y, Graphics.FONT_NUMBER_MEDIUM, text, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (dc.getTextWidthInPixels(text, Graphics.FONT_NUMBER_MILD) <= 120) {
            dc.drawText(CENTER_X, PRIMARY_VALUE_Y, Graphics.FONT_NUMBER_MILD, text, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (dc.getTextWidthInPixels(text, Graphics.FONT_LARGE) <= 96) {
            dc.drawText(CENTER_X, PRIMARY_VALUE_Y, Graphics.FONT_LARGE, text, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        dc.drawText(CENTER_X, PRIMARY_VALUE_Y, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _drawSubdayStrip(dc as Dc, state as CountdownState) as Void {
        _drawStripSeparator(dc, 88, 86, 128);
        _drawStripSeparator(dc, 120, 86, 128);

        _drawLargeStripMetric(dc, 58, PRIMARY_VALUE_Y, CountdownFormatter.twoDigits(state.hours), "HRS");
        _drawLargeStripMetric(dc, CENTER_X, PRIMARY_VALUE_Y, CountdownFormatter.twoDigits(state.minutes), "MIN");
        _drawLargeStripMetric(dc, 150, PRIMARY_VALUE_Y, CountdownFormatter.twoDigits(state.seconds), "SEC");
    }

    function _drawStripMetric(dc as Dc, x as Lang.Number, valueY as Lang.Number, value as String, label as String) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(x, valueY, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(x, valueY + 12, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _drawLargeStripMetric(dc as Dc, x as Lang.Number, valueY as Lang.Number, value as String, label as String) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(x, valueY, Graphics.FONT_SMALL, value, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(x, valueY + 28, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _drawStripSeparator(dc as Dc, x as Lang.Number, topY as Lang.Number, bottomY as Lang.Number) as Void {
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawLine(x, topY, x, bottomY);
    }

    function _formatInlineTime(state as CountdownState) as String {
        return CountdownFormatter.twoDigits(state.hours) + "h  "
            + CountdownFormatter.twoDigits(state.minutes) + "m  "
            + CountdownFormatter.twoDigits(state.seconds) + "s";
    }

    function _dayLabel(days as Lang.Number) as String {
        if (days == 1) {
            return "day";
        }

        return "days";
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

    function _startRefreshTimer() as Void {
        if (_refreshTimer == null) {
            _refreshTimer = new Timer.Timer();
        }

        _refreshTimer.start(method(:_onRefreshTick), 1000, true);
    }

    function _stopRefreshTimer() as Void {
        if (_refreshTimer != null) {
            _refreshTimer.stop();
        }
    }

    function _onRefreshTick() as Void {
        WatchUi.requestUpdate();
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
