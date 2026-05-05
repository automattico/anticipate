import Toybox.Graphics;
import Toybox.Lang;

class CountdownFormatter {

    static function _showsTimedDetails(event as EventConfig) as Lang.Boolean {
        if (!event.allDay) {
            return true;
        }

        return event.targetHour != 0 || event.targetMinute != 0;
    }

    static function twoDigits(value as Lang.Number) as Lang.String {
        if (value < 10) {
            return "0" + value.toString();
        }

        return value.toString();
    }

    static function formatMainPrimary(state as CountdownState) as Lang.String {
        if (state.isDone) {
            return "DONE";
        }

        if (state.isNow) {
            return "TODAY";
        }

        if (state.days > 0) {
            return state.days.toString() + "d";
        }

        if (state.hours > 0) {
            return state.hours.toString() + "h";
        }

        return state.minutes.toString() + "m";
    }

    static function formatMainSecondary(state as CountdownState) as Lang.String {
        if (state.isDone || state.isNow) {
            return "";
        }

        if (state.days > 0 && state.hours > 0) {
            return state.hours.toString() + "h";
        }

        if (state.hours > 0) {
            return state.minutes.toString() + "m";
        }

        return "";
    }

    static function formatTargetDateLine(event as EventConfig) as Lang.String {
        var dateText = twoDigits(event.targetDay) + " " + monthName(event.targetMonth) + " " + event.targetYear.toString();
        if (!_showsTimedDetails(event)) {
            return dateText;
        }

        var yearText = event.targetYear.toString();
        var shortYearText = yearText;
        if (yearText.length() > 2) {
            shortYearText = yearText.substring(yearText.length() - 2, yearText.length());
        }

        return twoDigits(event.targetDay) + " " + monthName(event.targetMonth) + " " + shortYearText + " " + twoDigits(event.targetHour) + ":" + twoDigits(event.targetMinute);
    }

    static function formatTargetTimeLine(event as EventConfig) as Lang.String {
        return "";
    }

    static function monthName(month as Lang.Number) as Lang.String {
        if (month == 1) {
            return "Jan";
        }

        if (month == 2) {
            return "Feb";
        }

        if (month == 3) {
            return "Mar";
        }

        if (month == 4) {
            return "Apr";
        }

        if (month == 5) {
            return "May";
        }

        if (month == 6) {
            return "Jun";
        }

        if (month == 7) {
            return "Jul";
        }

        if (month == 8) {
            return "Aug";
        }

        if (month == 9) {
            return "Sep";
        }

        if (month == 10) {
            return "Oct";
        }

        if (month == 11) {
            return "Nov";
        }

        if (month == 12) {
            return "Dec";
        }

        return month.toString();
    }

    static function titleFontForWidth(dc as Graphics.Dc, text as Lang.String, maxWidth as Lang.Number) as FontDefinition {
        if (text.length() > 12) {
            return Graphics.FONT_TINY;
        }

        if (dc.getTextWidthInPixels(text, Graphics.FONT_SMALL) <= maxWidth) {
            return Graphics.FONT_SMALL;
        }

        return Graphics.FONT_TINY;
    }

    static function fitTitleToWidth(dc as Graphics.Dc, text as Lang.String, maxWidth as Lang.Number, font as FontDefinition) as Lang.String {
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
}
