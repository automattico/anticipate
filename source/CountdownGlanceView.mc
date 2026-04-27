import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

(:glance)
class CountdownGlanceView extends WatchUi.GlanceView {

    const TITLE_GAP = 2;
    const BODY_GAP = 4;

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var centerX = Math.floor(dc.getWidth() / 2) as Lang.Number;
        var titleFont = Graphics.FONT_XTINY;
        var bodyFont = Graphics.FONT_XTINY;
        var titleLine1 = "ANTICIPATE";
        var titleLine2 = "COUNTDOWNS";
        var body = "Open for details";
        var titleHeight = dc.getFontHeight(titleFont);
        var bodyHeight = dc.getFontHeight(bodyFont);
        var totalHeight = (titleHeight * 2) + TITLE_GAP + BODY_GAP + bodyHeight;
        var y = Math.floor(((dc.getHeight() - totalHeight) / 2) + 0.5) as Lang.Number;

        _drawCenteredLine(dc, titleLine1, centerX, y, titleFont);
        y += titleHeight + TITLE_GAP;
        _drawCenteredLine(dc, titleLine2, centerX, y, titleFont);
        y += titleHeight + BODY_GAP;
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
        _drawCenteredLine(dc, body, centerX, y, bodyFont);
    }

    function _drawCenteredLine(dc as Graphics.Dc, text as Lang.String, centerX as Lang.Number, y as Lang.Number, font as Graphics.FontDefinition) as Void {
        var x = Math.floor((centerX - (dc.getTextWidthInPixels(text, font) / 2)) + 0.5) as Lang.Number;
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_LEFT);
    }
}
