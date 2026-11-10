import Toybox.Application.Properties;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

// The adapter also lets regression tests exercise interrupted writes without
// touching the simulator's real countdowns.
(:glance)
class CountdownTargetStore {
    function getValue(key as String) as Lang.Object or Null {
        return Storage.getValue(key);
    }

    function setValue(key as String, value as Lang.Object) as Void {
        Storage.setValue(key, value as Storage.ValueType);
    }
}

(:glance)
class CountdownTargetTime {
    static function utcEpoch(year as Lang.Number, month as Lang.Number, day as Lang.Number, hour as Lang.Number, minute as Lang.Number) as Lang.Number {
        return Gregorian.moment({:year => year, :month => month, :day => day,
            :hour => hour, :minute => minute, :second => 0}).value();
    }

    static function offsetForSample(sample as Time.Moment, local as Gregorian.Info) as Lang.Number {
        return utcEpoch(local.year, local.month as Lang.Number, local.day, local.hour, local.min)
            + local.sec - sample.value();
    }

    static function localOffset() as Lang.Number {
        var sample = Time.now();
        return offsetForSample(sample, Gregorian.info(sample, Time.FORMAT_SHORT));
    }

    static function signature(year as Lang.Number, month as Lang.Number, day as Lang.Number, allDay as Lang.Boolean, hour as Lang.Number, minute as Lang.Number) as String {
        var date = year.toString() + "-" + month.toString() + "-" + day.toString();
        if (allDay) {
            return date + "|1";
        }
        return date + "|0|" + hour.toString() + "|" + minute.toString();
    }

    static function forSlot(slot as Lang.Number, year as Lang.Number, month as Lang.Number, day as Lang.Number, allDay as Lang.Boolean, hour as Lang.Number, minute as Lang.Number) as Lang.Number {
        if (allDay) {
            hour = 0;
            minute = 0;
        }
        var prefix = "event" + slot.toString() + "_";
        var legacy;
        try {
            legacy = Properties.getValue(prefix + "target_epoch");
        } catch (e) {
            legacy = null;
        }
        return resolve(prefix, utcEpoch(year, month, day, hour, minute),
            signature(year, month, day, allDay, hour, minute), localOffset(),
            new CountdownTargetStore(), legacy);
    }

    static function same(left as Lang.Object or Null, right as Lang.Object or Null) as Lang.Boolean {
        return left == null ? right == null : left.equals(right);
    }

    static function number(value as Lang.Object or Null) as Lang.Number or Null {
        if (value instanceof Lang.Number) {
            return value;
        }
        if (value instanceof Lang.String) {
            var text = value as Lang.String;
            var first = 0;
            var negative = text.length() > 0 && (text.substring(0, 1) as Lang.String).equals("-");
            if (negative) {
                first = 1;
            }
            // Accept zero-padded settings, but reject partial parses/overflow.
            while (first < text.length() - 1 && (text.substring(first, first + 1) as Lang.String).equals("0")) {
                first += 1;
            }
            var canonical = text.substring(first, text.length()) as Lang.String;
            if (negative && !canonical.equals("0")) {
                canonical = "-" + canonical;
            }
            var parsed = text.toNumber();
            if (parsed != null && parsed.toString().equals(canonical)) {
                return parsed;
            }
        }
        return null;
    }

    static function backupOffset(backup as Lang.Dictionary) as Lang.Number or Null {
        var offset = number(backup["offset"] as Lang.Object or Null);
        if (offset == null || offset < -86400 || offset > 86400) {
            return null;
        }
        return offset;
    }

    static function resolve(prefix as String, utc as Lang.Number, inputSignature as String, offset as Lang.Number, store as CountdownTargetStore, legacy as Lang.Object or Null) as Lang.Number {
        var fallback = utc - offset;
        var epoch = null;
        try {
            var rawEpoch = store.getValue(prefix + "target_epoch");
            if (rawEpoch == null && legacy != null && number(legacy) != 0) {
                // The hidden legacy property defaults to zero: it is not a cache.
                rawEpoch = legacy;
            }
            epoch = number(rawEpoch);
            var savedSignature = store.getValue(prefix + "target_signature");
            var version = store.getValue(prefix + "target_time_version");
            var backup = store.getValue(prefix + "target_time_backup");

            // A corrupt cache is not evidence that the user removed an event.
            if (rawEpoch != null && (epoch == null || epoch <= 0)) {
                return fallback;
            }
            if (version != null && version != 1) {
                return epoch != null ? (epoch as Lang.Number) : fallback;
            }

            if (epoch != null) {
                if (version == 1) {
                    if (same(savedSignature, inputSignature)) {
                        return epoch;
                    }
                    // An ambiguous old signature was deliberately preserved.
                    if (backup instanceof Lang.Dictionary && backup["preserved"] == true
                        && same(backup["signature"] as Lang.Object or Null, savedSignature)
                        && same(backup["observed_signature"] as Lang.Object or Null, inputSignature)) {
                        return epoch;
                    }
                    if (!(savedSignature instanceof Lang.String)
                        && !(backup instanceof Lang.Dictionary && backup["preserved"] == true
                            && same(backup["signature"] as Lang.Object or Null, savedSignature)
                            && backup["observed_signature"] instanceof Lang.String)) {
                        return epoch;
                    }
                    // Inputs changed after this slot was observed by version 1.
                } else if (same(savedSignature, inputSignature) && epoch == utc) {
                    if (backup == null) {
                        backup = {"epoch" => epoch, "signature" => savedSignature,
                            "offset" => offset};
                        store.setValue(prefix + "target_time_backup", backup);
                    }
                    // Never replace an unrelated backup to make a repair fit.
                    if (!(backup instanceof Lang.Dictionary)
                        || backup["epoch"] != utc || !same(backup["signature"] as Lang.Object or Null, inputSignature)
                        || backupOffset(backup) == null) {
                        return epoch;
                    }
                    fallback = utc - (backupOffset(backup) as Lang.Number);
                } else {
                    // A repair may have stopped after writing its epoch. Finish
                    // using its original offset, even if the timezone changed.
                    if (backup instanceof Lang.Dictionary && same(backup["signature"] as Lang.Object or Null, inputSignature)
                        && backup["epoch"] == utc && backupOffset(backup) != null
                        && epoch == utc - (backupOffset(backup) as Lang.Number)) {
                        store.setValue(prefix + "target_time_version", 1);
                        return epoch;
                    }
                    if (backup == null) {
                        store.setValue(prefix + "target_time_backup", {
                            "epoch" => epoch, "signature" => savedSignature,
                            "offset" => offset, "preserved" => true,
                            "observed_signature" => inputSignature});
                    } else if (!(backup instanceof Lang.Dictionary)
                        || backup["preserved"] != true
                        || !same(backup["signature"] as Lang.Object or Null, savedSignature)
                        || !same(backup["observed_signature"] as Lang.Object or Null, inputSignature)) {
                        return epoch;
                    }
                    // Keep the original signature as well as the custom epoch.
                    if (store.getValue(prefix + "target_epoch") == null) {
                        store.setValue(prefix + "target_epoch", epoch);
                    }
                    store.setValue(prefix + "target_time_version", 1);
                    return epoch;
                }
            } else if (savedSignature != null || backup != null || version != null) {
                // Partially missing data: display a safe result, retain evidence.
                return fallback;
            }

            store.setValue(prefix + "target_epoch", fallback);
            store.setValue(prefix + "target_signature", inputSignature);
            store.setValue(prefix + "target_time_version", 1);
            return fallback;
        } catch (e) {
            // Full storage or interrupted writes must not hide the countdown.
            return epoch != null ? (epoch as Lang.Number) : fallback;
        }
    }
}
