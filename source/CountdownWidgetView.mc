import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Timer;
import Toybox.WatchUi;

class CountdownWidgetView extends WatchUi.View {

    const CENTER_X = 104;
    const TITLE_Y = 28;
    const PRIMARY_VALUE_Y = 72;
    const PRIMARY_DETAIL_Y = 138;
    const PRIMARY_AUX_Y = 150;
    const PRIMARY_DATE_Y = 178;
    const DAY_LAYOUT_CENTER_Y = 110;
    const DAY_TITLE_VALUE_GAP = 3;
    const DAY_VALUE_TIME_GAP = 3;
    const DAY_TIME_DATE_GAP = 8;
    const TIMED_DAY_TITLE_VALUE_GAP = 3;
    const TIMED_DAY_VALUE_TIME_GAP = 3;
    const TIMED_DAY_TIME_DATE_GAP = 7;
    const DAY_ROW_GAP = 4;
    const DAY_VALUE_MAX_WIDTH = 140;
    const DAY_TITLE_NUDGE_Y = 3;
    const DAY_TIME_NUDGE_Y = -3;
    const TIMED_DAY_LAYOUT_SHIFT_Y = 2;
    const TARGET_TIME_EXTRA_GAP_Y = 4;
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
        var timeLine = CountdownFormatter.formatTargetTimeLine(event);

        if (state.isDone) {
            _drawTitle(dc, title);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(CENTER_X, PRIMARY_VALUE_Y, Graphics.FONT_LARGE, "DONE", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(CENTER_X, PRIMARY_DETAIL_Y, Graphics.FONT_TINY, "Event passed", Graphics.TEXT_JUSTIFY_CENTER);
            _drawTargetDateBlock(dc, dateLine, timeLine, PRIMARY_DATE_Y);
            return;
        }

        if (state.isNow) {
            _drawTitle(dc, title);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(CENTER_X, PRIMARY_VALUE_Y, Graphics.FONT_LARGE, "TODAY", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(CENTER_X, PRIMARY_DETAIL_Y, Graphics.FONT_TINY, "It's happening", Graphics.TEXT_JUSTIFY_CENTER);
            _drawTargetDateBlock(dc, dateLine, timeLine, PRIMARY_DATE_Y);
            return;
        }

        if (state.days > 0) {
            _drawDayCountdownState(dc, title, state, dateLine, timeLine);
            return;
        }

        _drawTitle(dc, title);
        _drawSubdayStrip(dc, state);
        _drawTargetDateBlock(dc, dateLine, timeLine, PRIMARY_DATE_Y);
    }

    function _drawTitle(dc as Dc, title as String) as Void {
        _drawTitleAt(dc, title, TITLE_Y);
    }

    function _drawTitleAt(dc as Dc, title as String, y as Lang.Number) as Void {
        var x = Math.floor((CENTER_X - (dc.getTextWidthInPixels(title, Graphics.FONT_SMALL) / 2)) + 0.5);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(x, y, Graphics.FONT_SMALL, title, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function _drawDayCountdownState(dc as Dc, title as String, state as CountdownState, dateLine as String, timeLine as String) as Void {
        var titleValueGap = DAY_TITLE_VALUE_GAP;
        var valueTimeGap = DAY_VALUE_TIME_GAP;
        var timeDateGap = DAY_TIME_DATE_GAP;
        if (timeLine.length() > 0) {
            titleValueGap = TIMED_DAY_TITLE_VALUE_GAP;
            valueTimeGap = TIMED_DAY_VALUE_TIME_GAP;
            timeDateGap = TIMED_DAY_TIME_DATE_GAP;
        }

        var titleHeight = dc.getFontHeight(Graphics.FONT_SMALL);
        var labelFont = Graphics.FONT_XTINY;
        var valueFont = _dayCountdownValueFont(dc, state.days.toString(), timeLine.length() > 0);
        var valueHeight = dc.getFontHeight(valueFont);
        var labelRowBottom = (Graphics.getFontAscent(valueFont) - Graphics.getFontAscent(labelFont)) + dc.getFontHeight(labelFont);
        var valueRowHeight = valueHeight;

        if (labelRowBottom > valueRowHeight) {
            valueRowHeight = labelRowBottom;
        }

        var timeRowHeight = _inlineTimeRowHeight(dc);

        var dateBlockHeight = _targetDateBlockHeight(dc, timeLine);
        var totalHeight = titleHeight + titleValueGap + valueRowHeight + valueTimeGap + timeRowHeight + timeDateGap + dateBlockHeight;
        var layoutCenterY = DAY_LAYOUT_CENTER_Y;
        if (timeLine.length() > 0) {
            layoutCenterY += TIMED_DAY_LAYOUT_SHIFT_Y;
        }

        var titleY = Math.floor((layoutCenterY - (totalHeight / 2)) + 0.5);
        var valueY = titleY + titleHeight + titleValueGap;
        var timeY = valueY + valueRowHeight + valueTimeGap;
        var dateY = timeY + timeRowHeight + timeDateGap;

        titleY += DAY_TITLE_NUDGE_Y;
        timeY += DAY_TIME_NUDGE_Y;
        dateY += DAY_TIME_NUDGE_Y;

        _drawTitleAt(dc, title, titleY);
        _drawDayCountdownRow(dc, state.days, valueFont, valueY);
        _drawInlineTime(dc, state, timeY);
        _drawTargetDateBlock(dc, dateLine, timeLine, dateY);
    }

    function _drawDayCountdownRow(dc as Dc, days as Lang.Number, valueFont, valueY as Lang.Number) as Void {
        var prefix = "in";
        var value = days.toString();
        var suffix = _dayLabel(days);
        var labelFont = Graphics.FONT_XTINY;
        var valueWidth = dc.getTextWidthInPixels(value, valueFont);
        var valueLeftX = Math.floor((CENTER_X - (valueWidth / 2)) + 0.5);
        var valueRightX = Math.floor((CENTER_X + (valueWidth / 2)) + 0.5);
        var labelBaselineY = valueY + Graphics.getFontAscent(valueFont);
        var labelY = labelBaselineY - Graphics.getFontAscent(labelFont);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(valueLeftX - DAY_ROW_GAP, labelY, labelFont, prefix, Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawText(CENTER_X, valueY, valueFont, value, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(valueRightX + DAY_ROW_GAP, labelY, labelFont, suffix, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function _dayCountdownValueFont(dc as Dc, value as String, preferCompact as Lang.Boolean) {
        if (preferCompact) {
            if (dc.getTextWidthInPixels(value, Graphics.FONT_NUMBER_MILD) <= DAY_VALUE_MAX_WIDTH) {
                return Graphics.FONT_NUMBER_MILD;
            }

            return Graphics.FONT_LARGE;
        }

        if (dc.getTextWidthInPixels(value, Graphics.FONT_NUMBER_MEDIUM) <= DAY_VALUE_MAX_WIDTH) {
            return Graphics.FONT_NUMBER_MEDIUM;
        }

        if (dc.getTextWidthInPixels(value, Graphics.FONT_NUMBER_MILD) <= DAY_VALUE_MAX_WIDTH) {
            return Graphics.FONT_NUMBER_MILD;
        }

        return Graphics.FONT_LARGE;
    }

    function _targetDateBlockHeight(dc as Dc, timeLine as String) as Lang.Number {
        var dateFont = _targetDateFont(timeLine);
        var height = dc.getFontHeight(dateFont);
        if (timeLine.length() > 0) {
            var timeFont = _targetTimeFont();
            height += dc.getFontHeight(timeFont) + TARGET_TIME_EXTRA_GAP_Y;
        }

        return height;
    }

    function _drawTargetDateBlock(dc as Dc, dateLine as String, timeLine as String, y as Lang.Number) as Void {
        var dateFont = _targetDateFont(timeLine);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(CENTER_X, y, dateFont, dateLine, Graphics.TEXT_JUSTIFY_CENTER);

        if (timeLine.length() > 0) {
            var timeFont = _targetTimeFont();
            dc.drawText(CENTER_X, y + dc.getFontHeight(dateFont) + TARGET_TIME_EXTRA_GAP_Y, timeFont, timeLine, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function _targetDateFont(timeLine as String) {
        return Graphics.FONT_XTINY;
    }

    function _targetTimeFont() {
        return Graphics.FONT_XTINY;
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
        var valueFont = Graphics.FONT_SMALL;
        var unitFont = Graphics.FONT_XTINY;
        var unitY = (y + Graphics.getFontAscent(valueFont)) - Graphics.getFontAscent(unitFont);
        var values = [
            CountdownFormatter.twoDigits(state.hours),
            CountdownFormatter.twoDigits(state.minutes),
            CountdownFormatter.twoDigits(state.seconds)
        ];
        var units = ["h", "m", "s"];
        var gap = "  ";
        var totalWidth = 0;

        for (var i = 0; i < values.size(); i += 1) {
            var value = values[i];
            var unit = units[i];
            totalWidth += dc.getTextWidthInPixels(value, valueFont);
            totalWidth += dc.getTextWidthInPixels(unit, unitFont);

            if (i < values.size() - 1) {
                totalWidth += dc.getTextWidthInPixels(gap, unitFont);
            }
        }

        var x = CENTER_X - (totalWidth / 2);
        for (var j = 0; j < values.size(); j += 1) {
            var segValue = values[j];
            var segUnit = units[j];

            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
            dc.drawText(x, y, valueFont, segValue, Graphics.TEXT_JUSTIFY_LEFT);
            x += dc.getTextWidthInPixels(segValue, valueFont);

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(x, unitY, unitFont, segUnit, Graphics.TEXT_JUSTIFY_LEFT);
            x += dc.getTextWidthInPixels(segUnit, unitFont);

            if (j < values.size() - 1) {
                dc.drawText(x, unitY, unitFont, gap, Graphics.TEXT_JUSTIFY_LEFT);
                x += dc.getTextWidthInPixels(gap, unitFont);
            }
        }
    }

    function _inlineTimeRowHeight(dc as Dc) as Lang.Number {
        var valueHeight = dc.getFontHeight(Graphics.FONT_SMALL);
        var unitBottom = (Graphics.getFontAscent(Graphics.FONT_SMALL) - Graphics.getFontAscent(Graphics.FONT_XTINY)) + dc.getFontHeight(Graphics.FONT_XTINY);

        if (unitBottom > valueHeight) {
            return unitBottom;
        }

        return valueHeight;
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
