import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

class CountdownWidgetView extends WatchUi.View {

    const CENTER_X = 104;
    const KICKER_Y = 16;
    const TITLE_Y = 36;
    const PRIMARY_VALUE_Y = 68;
    const PRIMARY_DETAIL_Y = 132;
    const PRIMARY_AUX_Y = 152;
    const PRIMARY_DATE_Y = 182;
    const PAGE_INDICATOR_X = 10;
    const PAGE_INDICATOR_GAP = 14;
    const PAGE_INDICATOR_RADIUS = 2;
    const PAGE_INDICATOR_ACTIVE_WIDTH = 4;
    const PAGE_INDICATOR_ACTIVE_HEIGHT = 10;
    var _events as Array;
    var _selectedIndex as Lang.Number;
    var _refreshTimer as Timer.Timer or Null;

    function initialize() {
        View.initialize();
        _events = [];
        _selectedIndex = 0;
        _refreshTimer = null;
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        _refreshEvents();
        WatchUi.requestUpdate();
        _startRefreshTimer();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        _refreshEvents();
        var event = _currentEvent();
        if (event == null) {
            _drawEmptyState(dc);
            return;
        }

        var state = CountdownMath.calculate(event, CountdownMath.now());
        _drawConfiguredState(dc, event, state);
        _drawPageIndicator(dc);
    }

    function onHide() as Void {
        _stopRefreshTimer();
    }

    function _drawEmptyState(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(CENTER_X, 42, Graphics.FONT_XTINY, "ANTICIPATE", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(CENTER_X, 88, Graphics.FONT_SMALL, _resourceText(Rez.Strings.FallbackNoEventsTitle), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(CENTER_X, 120, Graphics.FONT_XTINY, _resourceText(Rez.Strings.FallbackNoEventsHintLine1), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(CENTER_X, 134, Graphics.FONT_XTINY, _resourceText(Rez.Strings.FallbackNoEventsHintLine2), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _drawConfiguredState(dc as Dc, event as EventConfig, state as CountdownState) as Void {
        var title = CountdownFormatter.fitTitleToWidth(dc, event.name, 150);
        var dateLine = CountdownFormatter.formatTargetDateLine(event);
        _drawTitle(dc, title);

        if (state.isDone) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(CENTER_X, PRIMARY_VALUE_Y, Graphics.FONT_LARGE, "DONE", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(CENTER_X, PRIMARY_DETAIL_Y, Graphics.FONT_TINY, "Event passed", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(CENTER_X, PRIMARY_DATE_Y, Graphics.FONT_XTINY, dateLine, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (state.isNow) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(CENTER_X, PRIMARY_VALUE_Y, Graphics.FONT_LARGE, "TODAY", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(CENTER_X, PRIMARY_DETAIL_Y, Graphics.FONT_TINY, "It's happening", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(CENTER_X, PRIMARY_DATE_Y, Graphics.FONT_XTINY, dateLine, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (state.days > 0) {
            _drawDayNumber(dc, state.days.toString());
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(CENTER_X, PRIMARY_DETAIL_Y, Graphics.FONT_XTINY, _dayLabel(state.days), Graphics.TEXT_JUSTIFY_CENTER);
            _drawInlineTime(dc, state, PRIMARY_AUX_Y);
            dc.drawText(CENTER_X, PRIMARY_DATE_Y, Graphics.FONT_XTINY, dateLine, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        _drawSubdayStrip(dc, state);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(CENTER_X, PRIMARY_DATE_Y, Graphics.FONT_XTINY, dateLine, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _drawTitle(dc as Dc, title as String) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(CENTER_X, KICKER_Y, Graphics.FONT_XTINY, "COUNTDOWN TO", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(CENTER_X, TITLE_Y, Graphics.FONT_SMALL, title, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _drawDayNumber(dc as Dc, text as String) as Void {
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);

        if (dc.getTextWidthInPixels(text, Graphics.FONT_NUMBER_MEDIUM) <= 140) {
            dc.drawText(CENTER_X, PRIMARY_VALUE_Y, Graphics.FONT_NUMBER_MEDIUM, text, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (dc.getTextWidthInPixels(text, Graphics.FONT_NUMBER_MILD) <= 140) {
            dc.drawText(CENTER_X, PRIMARY_VALUE_Y, Graphics.FONT_NUMBER_MILD, text, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        dc.drawText(CENTER_X, PRIMARY_VALUE_Y, Graphics.FONT_LARGE, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _drawSubdayStrip(dc as Dc, state as CountdownState) as Void {
        _drawStripSeparator(dc, 88, 86, 128);
        _drawStripSeparator(dc, 120, 86, 128);

        _drawLargeStripMetric(dc, 58, PRIMARY_VALUE_Y, CountdownFormatter.twoDigits(state.hours), "HRS");
        _drawLargeStripMetric(dc, CENTER_X, PRIMARY_VALUE_Y, CountdownFormatter.twoDigits(state.minutes), "MIN");
        _drawLargeStripMetric(dc, 150, PRIMARY_VALUE_Y, CountdownFormatter.twoDigits(state.seconds), "SEC");
    }

    function _drawStripMetric(dc as Dc, x as Lang.Number, valueY as Lang.Number, value as String, label as String) as Void {
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawText(x, valueY, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(x, valueY + 12, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _drawLargeStripMetric(dc as Dc, x as Lang.Number, valueY as Lang.Number, value as String, label as String) as Void {
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawText(x, valueY, Graphics.FONT_SMALL, value, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(x, valueY + 28, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _drawStripSeparator(dc as Dc, x as Lang.Number, topY as Lang.Number, bottomY as Lang.Number) as Void {
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawLine(x, topY, x, bottomY);
    }

    function _drawInlineTime(dc as Dc, state as CountdownState, y as Lang.Number) as Void {
        var segments = [
            [CountdownFormatter.twoDigits(state.hours), "h"],
            [CountdownFormatter.twoDigits(state.minutes), "m"],
            [CountdownFormatter.twoDigits(state.seconds), "s"]
        ];
        var gap = "  ";
        var totalWidth = 0;

        for (var i = 0; i < segments.size(); i += 1) {
            var value = segments[i][0];
            var unit = segments[i][1];
            totalWidth += dc.getTextWidthInPixels(value, Graphics.FONT_TINY);
            totalWidth += dc.getTextWidthInPixels(unit, Graphics.FONT_XTINY);

            if (i < segments.size() - 1) {
                totalWidth += dc.getTextWidthInPixels(gap, Graphics.FONT_XTINY);
            }
        }

        var x = CENTER_X - (totalWidth / 2);
        for (var j = 0; j < segments.size(); j += 1) {
            var segValue = segments[j][0];
            var segUnit = segments[j][1];

            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
            dc.drawText(x, y, Graphics.FONT_TINY, segValue, Graphics.TEXT_JUSTIFY_LEFT);
            x += dc.getTextWidthInPixels(segValue, Graphics.FONT_TINY);

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(x, y + 3, Graphics.FONT_XTINY, segUnit, Graphics.TEXT_JUSTIFY_LEFT);
            x += dc.getTextWidthInPixels(segUnit, Graphics.FONT_XTINY);

            if (j < segments.size() - 1) {
                dc.drawText(x, y + 3, Graphics.FONT_XTINY, gap, Graphics.TEXT_JUSTIFY_LEFT);
                x += dc.getTextWidthInPixels(gap, Graphics.FONT_XTINY);
            }
        }
    }

    function _drawPageIndicator(dc as Dc) as Void {
        if (_events.size() <= 1) {
            return;
        }

        var totalHeight = ((_events.size() - 1) * PAGE_INDICATOR_GAP) + (PAGE_INDICATOR_RADIUS * 2);
        var firstY = (dc.getHeight() / 2) - (totalHeight / 2) + PAGE_INDICATOR_RADIUS;
        var y = firstY;
        var centerY = dc.getHeight() / 2;

        for (var i = 0; i < _events.size(); i += 1) {
            var x = _pageIndicatorX(y, centerY);

            if (i == _selectedIndex) {
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
                dc.fillRoundedRectangle(
                    x - (PAGE_INDICATOR_ACTIVE_WIDTH / 2),
                    y - (PAGE_INDICATOR_ACTIVE_HEIGHT / 2),
                    PAGE_INDICATOR_ACTIVE_WIDTH,
                    PAGE_INDICATOR_ACTIVE_HEIGHT,
                    2
                );
            } else {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.fillCircle(x, y, PAGE_INDICATOR_RADIUS);
            }

            y += PAGE_INDICATOR_GAP;
        }
    }

    function _pageIndicatorX(y as Lang.Number, centerY as Lang.Number) as Lang.Number {
        return PAGE_INDICATOR_X;
    }

    function _dayLabel(days as Lang.Number) as String {
        if (days == 1) {
            return "day";
        }

        return "days";
    }

    function _currentEvent() as EventConfig or Null {
        if (_events.size() == 0) {
            return null;
        }

        return _events[_selectedIndex] as EventConfig;
    }

    function _refreshEvents() as Void {
        _events = CountdownEvents.configuredEvents();

        if (_events.size() == 0) {
            _selectedIndex = 0;
            return;
        }

        if (_selectedIndex >= _events.size()) {
            _selectedIndex = 0;
        }
    }

    function showNextEvent() as Boolean {
        _refreshEvents();
        if (_events.size() <= 1) {
            return false;
        }

        _selectedIndex = (_selectedIndex + 1) % _events.size();
        WatchUi.requestUpdate();
        return true;
    }

    function showPreviousEvent() as Boolean {
        _refreshEvents();
        if (_events.size() <= 1) {
            return false;
        }

        _selectedIndex -= 1;
        if (_selectedIndex < 0) {
            _selectedIndex = _events.size() - 1;
        }

        WatchUi.requestUpdate();
        return true;
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
    var _view as CountdownWidgetView;

    function initialize(view as CountdownWidgetView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onNextPage() as Boolean {
        return _view.showNextEvent();
    }

    function onPreviousPage() as Boolean {
        return _view.showPreviousEvent();
    }

    function onSelect() as Boolean {
        return false;
    }
}
