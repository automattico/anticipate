import Toybox.Lang;
import Toybox.Math;
import Toybox.Time;

class CountdownMath {

    static function calculate(event as EventConfig, nowEpoch as Lang.Number) as CountdownState {
        var deltaSeconds = event.targetEpoch - nowEpoch;
        var isNow = nowEpoch >= event.targetEpoch && nowEpoch < (event.targetEpoch + SECONDS_PER_DAY);
        var isDone = nowEpoch >= (event.targetEpoch + SECONDS_PER_DAY);
        var remaining = deltaSeconds;

        if (remaining < 0) {
            remaining = 0;
        }

        var days = _wholeNumber(Math.floor(remaining / SECONDS_PER_DAY));
        var hours = _wholeNumber(Math.floor((remaining % SECONDS_PER_DAY) / SECONDS_PER_HOUR));
        var minutes = _wholeNumber(Math.floor((remaining % SECONDS_PER_HOUR) / SECONDS_PER_MINUTE));

        if (isNow || isDone) {
            days = 0;
            hours = 0;
            minutes = 0;
        }

        return new CountdownState(event.targetEpoch, nowEpoch, remaining, isNow, isDone, days, hours, minutes);
    }

    static function now() as Lang.Number {
        return Time.now().value();
    }

    static function _wholeNumber(value as Lang.Numeric) as Lang.Number {
        var parsed = value.toString().toNumber();
        if (parsed == null) {
            return 0;
        }

        return parsed;
    }
}
