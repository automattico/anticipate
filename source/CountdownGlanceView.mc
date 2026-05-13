import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

(:glance)
class CountdownGlanceView extends WatchUi.GlanceView {
    const CONTENT_INSET_X = 8;
    const COMPACT_CONTENT_INSET_X = 6;
    const LARGE_CONTENT_INSET_X = 12;
    const DETAIL_GAP = 2;

    var _summary as Lang.Dictionary;

    function initialize(summary as Lang.Dictionary) {
        GlanceView.initialize();
        _summary = summary;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var title = _summary[:title] as String;
        var detail = _summary[:detail] as String;
        var maxWidth = _maxContentWidth(dc);
        var titleFont = _titleFont(dc, title, maxWidth);
        var detailFont = _detailFont(dc);
        var fittedTitle = _fitTextToWidth(dc, title, maxWidth, titleFont);
        var fittedDetail = _fitMetricTextToWidth(dc, detail, maxWidth, detailFont);
        var titleHeight = dc.getFontHeight(titleFont);
        var detailHeight = dc.getFontHeight(detailFont);
        var totalHeight = titleHeight + DETAIL_GAP + detailHeight;
        var titleY = Math.floor((dc.getHeight() - totalHeight) / 2) as Lang.Number;
        var detailY = titleY + titleHeight + DETAIL_GAP;
        var textX = _contentInsetX(dc);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(textX, titleY, titleFont, fittedTitle, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawText(textX, detailY, detailFont, fittedDetail, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function _titleFont(dc as Dc, title as String, maxWidth as Lang.Number) as FontDefinition {
        if (dc.getWidth() >= 360 && dc.getTextWidthInPixels(title, Graphics.FONT_SMALL) <= maxWidth) {
            return Graphics.FONT_SMALL;
        }

        if (dc.getWidth() >= 240 && dc.getTextWidthInPixels(title, Graphics.FONT_TINY) <= maxWidth) {
            return Graphics.FONT_TINY;
        }

        return Graphics.FONT_XTINY;
    }

    function _detailFont(dc as Dc) as FontDefinition {
        if (dc.getWidth() >= 360) {
            return Graphics.FONT_TINY;
        }

        return Graphics.FONT_XTINY;
    }

    function _maxContentWidth(dc as Dc) as Lang.Number {
        return dc.getWidth() - (_contentInsetX(dc) * 2);
    }

    function _contentInsetX(dc as Dc) as Lang.Number {
        var inset = CONTENT_INSET_X;
        if (dc.getWidth() <= 220) {
            inset = COMPACT_CONTENT_INSET_X;
        } else if (dc.getWidth() >= 360) {
            inset = LARGE_CONTENT_INSET_X;
        }

        return inset;
    }

    function _fitTextToWidth(dc as Dc, text as String, maxWidth as Lang.Number, font as FontDefinition) as String {
        if (text.length() == 0) {
            return "";
        }

        if (dc.getTextWidthInPixels(text, font) <= maxWidth) {
            return text;
        }

        var clipped = text;
        while (clipped.length() > 0) {
            clipped = clipped.substring(0, clipped.length() - 1);
            var candidate = clipped + "...";
            if (dc.getTextWidthInPixels(candidate, font) <= maxWidth) {
                return candidate;
            }
        }

        return "...";
    }

    function _fitMetricTextToWidth(dc as Dc, text as String, maxWidth as Lang.Number, font as FontDefinition) as String {
        return _fitTextToWidth(dc, text, maxWidth, font);
    }
}
