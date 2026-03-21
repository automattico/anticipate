import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

class CountdownFormatter {

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
        var info = Gregorian.utcInfo(new Time.Moment(event.targetEpoch), Time.FORMAT_MEDIUM);
        return info.month.toString() + " " + info.day.toString();
    }

    static function fitTitleToWidth(dc as Graphics.Dc, text as Lang.String, maxWidth as Lang.Number) as Lang.String {
        if (text.length() == 0) {
            return "";
        }

        if (dc.getTextWidthInPixels(text, Graphics.FONT_SMALL) <= maxWidth) {
            return text;
        }

        var clipped = text;
        while (clipped.length() > 0) {
            clipped = clipped.substring(0, clipped.length() - 1);
            var candidate = clipped + "...";
            if (dc.getTextWidthInPixels(candidate, Graphics.FONT_SMALL) <= maxWidth) {
                return candidate;
            }
        }

        return "...";
    }
}
