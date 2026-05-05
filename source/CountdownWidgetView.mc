import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Timer;
import Toybox.WatchUi;

class CountdownWidgetView extends WatchUi.View {

    const TITLE_Y = 28;
    const PRIMARY_VALUE_Y = 72;
    const PRIMARY_DETAIL_Y = 138;
    const PRIMARY_AUX_Y = 150;
    const PRIMARY_DATE_Y = 178;
    const DAY_LAYOUT_CENTER_Y = 110;
    const DAY_TITLE_VALUE_GAP = 2;
    const DAY_VALUE_TIME_GAP = 0;
    const DAY_TIME_DATE_GAP = 8;
    const TIMED_DAY_TITLE_VALUE_GAP = 3;
    const TIMED_DAY_VALUE_TIME_GAP = 3;
    const TIMED_DAY_TIME_DATE_GAP = 7;
    const DAY_ROW_GAP = 4;
    const DEFAULT_TITLE_MAX_WIDTH = 150;
    const LARGE_SCREEN_TITLE_MAX_WIDTH = 210;
    const DAY_VALUE_MAX_WIDTH = 140;
    const LARGE_SCREEN_DAY_VALUE_MAX_WIDTH = 190;
    const DAY_TITLE_NUDGE_Y = -2;
    const DAY_TIME_NUDGE_Y = -8;
    const TIMED_DAY_LAYOUT_SHIFT_Y = 2;
    const TARGET_TIME_EXTRA_GAP_Y = 4;
    const EMPTY_STATE_TITLE_BODY_GAP = 3;
    const EMPTY_STATE_TITLE_LINE_GAP = 0;
    const EMPTY_STATE_BODY_LINE_GAP = 0;
    const EMPTY_STATE_NUDGE_Y = -6;
    const PAGE_INDICATOR_X = 10;
    const PAGE_INDICATOR_GAP = 14;
    const PAGE_INDICATOR_RADIUS = 2;
    const PAGE_INDICATOR_ACTIVE_WIDTH = 4;
    const PAGE_INDICATOR_ACTIVE_HEIGHT = 10;
    const DEFAULT_SUBDAY_SEPARATOR_OFFSET = 16;
    const DEFAULT_SUBDAY_METRIC_OFFSET = 46;
    const LARGE_SCREEN_SUBDAY_SEPARATOR_OFFSET = 22;
    const LARGE_SCREEN_SUBDAY_METRIC_OFFSET = 58;
    var _pageIndicatorCenterY as Lang.Number;
    var _events as Array;
    var _selectedIndex as Lang.Number;
    var _refreshTimer as Timer.Timer or Null;

    function initialize() {
        View.initialize();
        _events = [];
        _selectedIndex = 0;
        _pageIndicatorCenterY = 0;
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
        _pageIndicatorCenterY = _contentCenterY(dc);

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
        var centerX = _centerX(dc);
        var titleFont = Graphics.FONT_XTINY;
        var bodyFont = Graphics.FONT_XTINY;
        var titleLines = [
            _resourceText(Rez.Strings.FallbackNoEventsTitleLine1),
            _resourceText(Rez.Strings.FallbackNoEventsTitleLine2)
        ];
        var bodyLines = [
            _resourceText(Rez.Strings.FallbackNoEventsLine1),
            _resourceText(Rez.Strings.FallbackNoEventsLine2),
            _resourceText(Rez.Strings.FallbackNoEventsLine3),
            _resourceText(Rez.Strings.FallbackNoEventsLine4),
            _resourceText(Rez.Strings.FallbackNoEventsLine5)
        ];
        var titleBlockHeight = _textBlockHeight(dc, titleLines, titleFont, EMPTY_STATE_TITLE_LINE_GAP);
        var bodyBlockHeight = _textBlockHeight(dc, bodyLines, bodyFont, EMPTY_STATE_BODY_LINE_GAP);
        var totalHeight = titleBlockHeight + EMPTY_STATE_TITLE_BODY_GAP + bodyBlockHeight;
        var centeredStartY = _centeredBlockStartY(dc, totalHeight, _contentCenterY(dc)) + EMPTY_STATE_NUDGE_Y;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        _drawCenteredTextBlock(dc, titleLines, centerX, centeredStartY, titleFont, EMPTY_STATE_TITLE_LINE_GAP);
        _drawCenteredTextBlock(dc, bodyLines, centerX, centeredStartY + titleBlockHeight + EMPTY_STATE_TITLE_BODY_GAP, bodyFont, EMPTY_STATE_BODY_LINE_GAP);
    }

    function _drawConfiguredState(dc as Dc, event as EventConfig, state as CountdownState) as Void {
        var centerX = _centerX(dc);
        var titleMaxWidth = _titleMaxWidth(dc);
        var titleFont = CountdownFormatter.titleFontForWidth(dc, event.name, titleMaxWidth);
        var title = CountdownFormatter.fitTitleToWidth(dc, event.name, titleMaxWidth, titleFont);
        var dateLine = CountdownFormatter.formatTargetDateLine(event);
        var timeLine = CountdownFormatter.formatTargetTimeLine(event);

        if (state.isDone) {
            var doneTop = TITLE_Y;
            var doneBottom = PRIMARY_DATE_Y + _targetDateBlockHeight(dc, timeLine);
            var doneOffset = _centeredBlockOffset(dc, doneTop, doneBottom);

            _drawTitleAt(dc, title, titleFont, TITLE_Y + doneOffset, centerX);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(centerX, PRIMARY_VALUE_Y + doneOffset, Graphics.FONT_LARGE, "DONE", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(centerX, PRIMARY_DETAIL_Y + doneOffset, Graphics.FONT_TINY, "Event passed", Graphics.TEXT_JUSTIFY_CENTER);
            _drawTargetDateBlock(dc, dateLine, timeLine, PRIMARY_DATE_Y + doneOffset, centerX);
            _setPageIndicatorCenterY(doneTop + doneOffset, doneBottom + doneOffset);
            return;
        }

        if (state.isNow) {
            var nowTop = TITLE_Y;
            var nowBottom = PRIMARY_DATE_Y + _targetDateBlockHeight(dc, timeLine);
            var nowOffset = _centeredBlockOffset(dc, nowTop, nowBottom);

            _drawTitleAt(dc, title, titleFont, TITLE_Y + nowOffset, centerX);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(centerX, PRIMARY_VALUE_Y + nowOffset, Graphics.FONT_LARGE, "TODAY", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(centerX, PRIMARY_DETAIL_Y + nowOffset, Graphics.FONT_TINY, "It's happening", Graphics.TEXT_JUSTIFY_CENTER);
            _drawTargetDateBlock(dc, dateLine, timeLine, PRIMARY_DATE_Y + nowOffset, centerX);
            _setPageIndicatorCenterY(nowTop + nowOffset, nowBottom + nowOffset);
            return;
        }

        if (state.days > 0) {
            _drawDayCountdownState(dc, title, titleFont, state, dateLine, timeLine, centerX);
            return;
        }

        var subdayTop = TITLE_Y;
        var subdayBottom = PRIMARY_DATE_Y + _targetDateBlockHeight(dc, timeLine);
        var subdayOffset = _centeredBlockOffset(dc, subdayTop, subdayBottom);

        _drawTitleAt(dc, title, titleFont, TITLE_Y + subdayOffset, centerX);
        _drawSubdayStrip(dc, state, centerX, subdayOffset);
        _drawTargetDateBlock(dc, dateLine, timeLine, PRIMARY_DATE_Y + subdayOffset, centerX);
        _setPageIndicatorCenterY(subdayTop + subdayOffset, subdayBottom + subdayOffset);
    }

    function _drawTitle(dc as Dc, title as String, titleFont as FontDefinition, centerX as Lang.Number) as Void {
        _drawTitleAt(dc, title, titleFont, TITLE_Y, centerX);
    }

    function _drawTitleAt(dc as Dc, title as String, titleFont as FontDefinition, y as Lang.Number, centerX as Lang.Number) as Void {
        var x = Math.floor((centerX - (dc.getTextWidthInPixels(title, titleFont) / 2)) + 0.5) as Lang.Number;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(x, y, titleFont, title, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function _drawDayCountdownState(dc as Dc, title as String, titleFont as FontDefinition, state as CountdownState, dateLine as String, timeLine as String, centerX as Lang.Number) as Void {
        var titleValueGap = DAY_TITLE_VALUE_GAP;
        var valueTimeGap = DAY_VALUE_TIME_GAP;
        var timeDateGap = DAY_TIME_DATE_GAP;
        if (timeLine.length() > 0) {
            titleValueGap = TIMED_DAY_TITLE_VALUE_GAP;
            valueTimeGap = TIMED_DAY_VALUE_TIME_GAP;
            timeDateGap = TIMED_DAY_TIME_DATE_GAP;
        }

        var titleHeight = dc.getFontHeight(titleFont);
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
        var layoutCenterY = _contentCenterY(dc);
        if (timeLine.length() > 0) {
            layoutCenterY += TIMED_DAY_LAYOUT_SHIFT_Y;
        }

        var titleY = _centeredBlockStartY(dc, totalHeight, layoutCenterY);
        var valueY = titleY + titleHeight + titleValueGap;
        var timeY = valueY + valueRowHeight + valueTimeGap;
        var dateY = timeY + timeRowHeight + timeDateGap;

        titleY += DAY_TITLE_NUDGE_Y;
        timeY += DAY_TIME_NUDGE_Y;
        dateY += DAY_TIME_NUDGE_Y;

        _drawTitleAt(dc, title, titleFont, titleY, centerX);
        _drawDayCountdownRow(dc, state.days, valueFont, valueY, centerX);
        _drawInlineTime(dc, state, timeY, centerX);
        _drawTargetDateBlock(dc, dateLine, timeLine, dateY, centerX);
        _setPageIndicatorCenterY(titleY, dateY + dateBlockHeight);
    }

    function _drawDayCountdownRow(dc as Dc, days as Lang.Number, valueFont as FontDefinition, valueY as Lang.Number, centerX as Lang.Number) as Void {
        var prefix = "in";
        var value = days.toString();
        var suffix = _dayLabel(days);
        var labelFont = Graphics.FONT_XTINY;
        var valueWidth = dc.getTextWidthInPixels(value, valueFont);
        var valueLeftX = Math.floor((centerX - (valueWidth / 2)) + 0.5) as Lang.Number;
        var valueRightX = Math.floor((centerX + (valueWidth / 2)) + 0.5) as Lang.Number;
        var labelBaselineY = valueY + Graphics.getFontAscent(valueFont);
        var labelY = labelBaselineY - Graphics.getFontAscent(labelFont);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(valueLeftX - DAY_ROW_GAP, labelY, labelFont, prefix, Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, valueY, valueFont, value, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(valueRightX + DAY_ROW_GAP, labelY, labelFont, suffix, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function _dayCountdownValueFont(dc as Dc, value as String, preferCompact as Lang.Boolean) as FontDefinition {
        var maxWidth = _dayValueMaxWidth(dc);
        if (preferCompact) {
            if (dc.getTextWidthInPixels(value, Graphics.FONT_NUMBER_MILD) <= maxWidth) {
                return Graphics.FONT_NUMBER_MILD;
            }

            return Graphics.FONT_LARGE;
        }

        if (dc.getTextWidthInPixels(value, Graphics.FONT_NUMBER_MEDIUM) <= maxWidth) {
            return Graphics.FONT_NUMBER_MEDIUM;
        }

        if (dc.getTextWidthInPixels(value, Graphics.FONT_NUMBER_MILD) <= maxWidth) {
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

    function _drawTargetDateBlock(dc as Dc, dateLine as String, timeLine as String, y as Lang.Number, centerX as Lang.Number) as Void {
        var dateFont = _targetDateFont(timeLine);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, y, dateFont, dateLine, Graphics.TEXT_JUSTIFY_CENTER);

        if (timeLine.length() > 0) {
            var timeFont = _targetTimeFont();
            dc.drawText(centerX, y + dc.getFontHeight(dateFont) + TARGET_TIME_EXTRA_GAP_Y, timeFont, timeLine, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function _targetDateFont(timeLine as String) as FontDefinition {
        return Graphics.FONT_XTINY;
    }

    function _targetTimeFont() as FontDefinition {
        return Graphics.FONT_XTINY;
    }

    function _drawSubdayStrip(dc as Dc, state as CountdownState, centerX as Lang.Number, offsetY as Lang.Number) as Void {
        var separatorOffset = _subdaySeparatorOffset(dc);
        var metricOffset = _subdayMetricOffset(dc);
        _drawStripSeparator(dc, centerX - separatorOffset, 86 + offsetY, 128 + offsetY);
        _drawStripSeparator(dc, centerX + separatorOffset, 86 + offsetY, 128 + offsetY);

        _drawLargeStripMetric(dc, centerX - metricOffset, PRIMARY_VALUE_Y + offsetY, CountdownFormatter.twoDigits(state.hours), "HRS");
        _drawLargeStripMetric(dc, centerX, PRIMARY_VALUE_Y + offsetY, CountdownFormatter.twoDigits(state.minutes), "MIN");
        _drawLargeStripMetric(dc, centerX + metricOffset, PRIMARY_VALUE_Y + offsetY, CountdownFormatter.twoDigits(state.seconds), "SEC");
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

    function _drawInlineTime(dc as Dc, state as CountdownState, y as Lang.Number, centerX as Lang.Number) as Void {
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
            var value = values[i] as String;
            var unit = units[i] as String;
            totalWidth += dc.getTextWidthInPixels(value, valueFont);
            totalWidth += dc.getTextWidthInPixels(unit, unitFont);

            if (i < values.size() - 1) {
                totalWidth += dc.getTextWidthInPixels(gap, unitFont);
            }
        }

        var x = (centerX - (totalWidth / 2)) as Lang.Number;
        for (var j = 0; j < values.size(); j += 1) {
            var segValue = values[j] as String;
            var segUnit = units[j] as String;

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
        var centerY = _pageIndicatorCenterY;
        var firstY = Math.floor((centerY - (totalHeight / 2) + PAGE_INDICATOR_RADIUS) + 0.5) as Lang.Number;
        var topSafeY = _safeVerticalInset(dc) + PAGE_INDICATOR_RADIUS;
        var bottomSafeY = dc.getHeight() - _safeVerticalInset(dc) - totalHeight + PAGE_INDICATOR_RADIUS;

        if (firstY < topSafeY) {
            firstY = topSafeY;
        } else if (firstY > bottomSafeY) {
            firstY = bottomSafeY;
        }

        var y = firstY;

        for (var i = 0; i < _events.size(); i += 1) {
            var x = _pageIndicatorX(dc);

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

    function _pageIndicatorX(dc as Dc) as Lang.Number {
        var safeInset = _safeHorizontalInset(dc);
        var indicatorX = safeInset - 4;
        if (indicatorX < PAGE_INDICATOR_X) {
            return PAGE_INDICATOR_X;
        }

        return indicatorX;
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

    function _drawCenteredLine(dc as Dc, line as String, centerX as Lang.Number, y as Lang.Number, font as FontDefinition) as Void {
        var x = Math.floor((centerX - (dc.getTextWidthInPixels(line, font) / 2)) + 0.5) as Lang.Number;
        dc.drawText(x, y, font, line, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function _centerX(dc as Dc) as Lang.Number {
        return Math.floor(dc.getWidth() / 2) as Lang.Number;
    }

    function _contentCenterY(dc as Dc) as Lang.Number {
        return Math.floor(dc.getHeight() / 2) as Lang.Number;
    }

    function _screenBucketSize(dc as Dc) as Lang.Number {
        var minDimension = dc.getWidth();
        if (dc.getHeight() < minDimension) {
            minDimension = dc.getHeight();
        }

        return minDimension;
    }

    function _safeVerticalInset(dc as Dc) as Lang.Number {
        var bucket = _screenBucketSize(dc);
        if (bucket <= 218) {
            return 16;
        }

        if (bucket <= 240) {
            return 18;
        }

        if (bucket <= 260) {
            return 20;
        }

        if (bucket <= 280) {
            return 22;
        }

        if (bucket <= 390) {
            return 30;
        }

        return 22;
    }

    function _safeHorizontalInset(dc as Dc) as Lang.Number {
        var bucket = _screenBucketSize(dc);
        if (bucket <= 218) {
            return 12;
        }

        if (bucket <= 240) {
            return 14;
        }

        if (bucket <= 260) {
            return 16;
        }

        if (bucket <= 280) {
            return 18;
        }

        if (bucket <= 390) {
            return 28;
        }

        return 18;
    }

    function _titleMaxWidth(dc as Dc) as Lang.Number {
        if (_screenBucketSize(dc) <= 280) {
            return DEFAULT_TITLE_MAX_WIDTH;
        }

        return LARGE_SCREEN_TITLE_MAX_WIDTH;
    }

    function _dayValueMaxWidth(dc as Dc) as Lang.Number {
        if (_screenBucketSize(dc) <= 280) {
            return DAY_VALUE_MAX_WIDTH;
        }

        return LARGE_SCREEN_DAY_VALUE_MAX_WIDTH;
    }

    function _subdaySeparatorOffset(dc as Dc) as Lang.Number {
        if (_screenBucketSize(dc) <= 280) {
            return DEFAULT_SUBDAY_SEPARATOR_OFFSET;
        }

        return LARGE_SCREEN_SUBDAY_SEPARATOR_OFFSET;
    }

    function _subdayMetricOffset(dc as Dc) as Lang.Number {
        if (_screenBucketSize(dc) <= 280) {
            return DEFAULT_SUBDAY_METRIC_OFFSET;
        }

        return LARGE_SCREEN_SUBDAY_METRIC_OFFSET;
    }

    function _centeredBlockStartY(dc as Dc, totalHeight as Lang.Number, centerY as Lang.Number) as Lang.Number {
        var startY = Math.floor((centerY - (totalHeight / 2)) + 0.5) as Lang.Number;
        var minY = _safeVerticalInset(dc);
        var maxY = dc.getHeight() - _safeVerticalInset(dc) - totalHeight;

        if (maxY < minY) {
            return minY;
        }

        if (startY < minY) {
            return minY;
        }

        if (startY > maxY) {
            return maxY;
        }

        return startY;
    }

    function _centeredBlockOffset(dc as Dc, topY as Lang.Number, bottomY as Lang.Number) as Lang.Number {
        var totalHeight = bottomY - topY;
        var targetTopY = _centeredBlockStartY(dc, totalHeight, _contentCenterY(dc));
        return targetTopY - topY;
    }

    function _setPageIndicatorCenterY(topY as Lang.Number, bottomY as Lang.Number) as Void {
        _pageIndicatorCenterY = Math.floor((topY + bottomY) / 2) as Lang.Number;
    }

    function _textBlockHeight(dc as Dc, lines as Array<String>, font as FontDefinition, lineGap as Lang.Number) as Lang.Number {
        if (lines.size() == 0) {
            return 0;
        }

        return (lines.size() * dc.getFontHeight(font)) + ((lines.size() - 1) * lineGap);
    }

    function _drawCenteredTextBlock(dc as Dc, lines as Array<String>, centerX as Lang.Number, startY as Lang.Number, font as FontDefinition, lineGap as Lang.Number) as Void {
        var y = startY;
        var lineHeight = dc.getFontHeight(font);

        for (var i = 0; i < lines.size(); i += 1) {
            _drawCenteredLine(dc, lines[i] as String, centerX, y, font);
            y += lineHeight + lineGap;
        }
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
