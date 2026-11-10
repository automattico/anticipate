import Toybox.Lang;
import Toybox.Test;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:test)
class MemoryTargetStore extends CountdownTargetStore {
    var values as Lang.Dictionary = {};
    var writes as Lang.Number = 0;
    var failAfter as Lang.Number = -1;

    function initialize() {
        CountdownTargetStore.initialize();
    }

    function getValue(key as String) as Lang.Object or Null {
        return values[key] as Lang.Object or Null;
    }

    function setValue(key as String, value as Lang.Object) as Void {
        if (writes == failAfter) {
            throw new Lang.InvalidValueException("Simulated interrupted write");
        }
        values[key] = value;
        writes += 1;
    }
}

(:test)
function localOffsetsAndRollover(logger as Test.Logger) as Boolean {
    // The sample crosses New Year in both directions; seconds must cancel too.
    var sample = new Time.Moment(1798761577); // 2026-12-31 23:59:37 UTC
    var offsets = [0, 7200, -18000, 19800, 20700, -43200, 50400];
    for (var i = 0; i < offsets.size(); i += 1) {
        var offset = offsets[i] as Lang.Number;
        var wall = Gregorian.utcInfo(new Time.Moment(sample.value() + offset), Time.FORMAT_SHORT);
        Test.assert((CountdownTargetTime.offsetForSample(sample, wall) == offset) as Boolean);
        var store = new MemoryTargetStore();
        var target = CountdownTargetTime.utcEpoch(2027, 1, 1, 0, 0);
        Test.assert((CountdownTargetTime.resolve("event1_", target, "2027-1-1|1", offset, store, null) == target - offset) as Boolean);
    }
    return true;
}

(:test)
function pinnedTargetsAndEdits(logger as Test.Logger) as Boolean {
    var store = new MemoryTargetStore();
    var utc = CountdownTargetTime.utcEpoch(2027, 1, 1, 18, 0);
    var sig = CountdownTargetTime.signature(2027, 1, 1, false, 18, 0);
    var pinned = CountdownTargetTime.resolve("event1_", utc, sig, 7200, store, null);
    Test.assert((pinned == utc - 7200) as Boolean);
    var writes = store.writes;
    // Restart, rename, travel and DST: the target signature is unchanged.
    Test.assert((CountdownTargetTime.resolve("event1_", utc, sig, -18000, store, null) == pinned) as Boolean);
    Test.assert((CountdownTargetTime.resolve("event1_", utc, sig, 3600, store, null) == pinned) as Boolean);
    Test.assert((store.writes == writes) as Boolean);
    // A real time edit uses the new offset.
    Test.assert((CountdownTargetTime.resolve("event1_", utc + 3600, "2027-1-1|0|19|0", 3600, store, null) == utc) as Boolean);
    return true;
}

(:test)
function utcRepairAllSlots(logger as Test.Logger) as Boolean {
    var store = new MemoryTargetStore();
    var utc = CountdownTargetTime.utcEpoch(2027, 1, 1, 18, 0);
    var sig = CountdownTargetTime.signature(2027, 1, 1, false, 18, 0);
    for (var slot = 1; slot <= 5; slot += 1) {
        var prefix = "event" + slot.toString() + "_";
        store.values[prefix + "target_epoch"] = utc;
        store.values[prefix + "target_signature"] = sig;
        Test.assert((CountdownTargetTime.resolve(prefix, utc, sig, 19800, store, null) == utc - 19800) as Boolean);
        var backup = store.values[prefix + "target_time_backup"] as Lang.Dictionary;
        Test.assert((backup["epoch"] == utc) as Boolean);
        Test.assert((backup["signature"] == sig) as Boolean);
        Test.assert((backup["offset"] == 19800) as Boolean);
        Test.assert((store.values[prefix + "target_time_version"] == 1) as Boolean);
        Test.assert((CountdownTargetTime.resolve(prefix, utc, sig, -18000, store, null) == utc - 19800) as Boolean);
        Test.assert((store.values[prefix + "target_time_backup"] == backup) as Boolean);
    }
    return true;
}

(:test)
function interruptedRepairs(logger as Test.Logger) as Boolean {
    var utc = CountdownTargetTime.utcEpoch(2027, 1, 1, 0, 0);
    var sig = "2027-1-1|1";
    // Fail before each migration write, then retry after changing timezone.
    for (var stop = 0; stop < 4; stop += 1) {
        var store = new MemoryTargetStore();
        store.values["event1_target_epoch"] = utc;
        store.values["event1_target_signature"] = sig;
        store.failAfter = stop;
        CountdownTargetTime.resolve("event1_", utc, sig, 7200, store, null);
        store.failAfter = -1;
        var expected = stop == 0 ? utc - 3600 : utc - 7200;
        Test.assert((CountdownTargetTime.resolve("event1_", utc, sig, 3600, store, null) == expected) as Boolean);
        Test.assert((store.values["event1_target_time_version"] == 1) as Boolean);
        Test.assert((CountdownTargetTime.resolve("event1_", utc, sig, -18000, store, null) == expected) as Boolean);
    }
    return true;
}

(:test)
function preserveAmbiguousAndLegacyTargets(logger as Test.Logger) as Boolean {
    var utc = CountdownTargetTime.utcEpoch(2027, 1, 1, 0, 0);
    var sig = "2027-1-1|1";
    var signatures = [sig, "2026-12-31|1", null];
    for (var i = 0; i < signatures.size(); i += 1) {
        var store = new MemoryTargetStore();
        store.values["event1_target_epoch"] = utc - 123;
        store.values["event1_target_signature"] = signatures[i];
        Test.assert((CountdownTargetTime.resolve("event1_", utc, sig, 7200, store, null) == utc - 123) as Boolean);
        Test.assert((store.values["event1_target_signature"] == signatures[i]) as Boolean);
        Test.assert((CountdownTargetTime.resolve("event1_", utc, sig, -18000, store, null) == utc - 123) as Boolean);
        Test.assert((CountdownTargetTime.resolve("event1_", utc + 86400, "2027-1-2|1", 3600, store, null) == utc + 82800) as Boolean);
    }
    var legacyStore = new MemoryTargetStore();
    Test.assert((CountdownTargetTime.resolve("event1_", utc, sig, 7200, legacyStore, utc - 123) == utc - 123) as Boolean);
    Test.assert((legacyStore.values["event1_target_epoch"] == utc - 123) as Boolean);
    return true;
}

(:test)
function preserveCorruptStorage(logger as Test.Logger) as Boolean {
    var utc = CountdownTargetTime.utcEpoch(2027, 1, 1, 0, 0);
    var sig = "2027-1-1|1";
    var malformed = ["broken", "123garbage", false, {}, -1, 0];
    for (var i = 0; i < malformed.size(); i += 1) {
        var store = new MemoryTargetStore();
        store.values["event1_target_epoch"] = malformed[i];
        Test.assert((CountdownTargetTime.resolve("event1_", utc, sig, 7200, store, null) == utc - 7200) as Boolean);
        Test.assert((store.writes == 0) as Boolean);
    }
    var store = new MemoryTargetStore();
    store.values["event1_target_epoch"] = utc;
    store.values["event1_target_signature"] = sig;
    store.values["event1_target_time_backup"] = {"unrelated" => true};
    Test.assert((CountdownTargetTime.resolve("event1_", utc, sig, 7200, store, null) == utc) as Boolean);
    Test.assert((store.writes == 0) as Boolean);
    store.values["event1_target_time_backup"] = {"epoch" => utc, "signature" => sig, "offset" => 1000000000};
    Test.assert(CountdownTargetTime.resolve("event1_", utc, sig, 7200, store, null) == utc);
    Test.assert(store.writes == 0);
    store.values["event1_target_time_version"] = "broken";
    Test.assert((CountdownTargetTime.resolve("event1_", utc, sig, 7200, store, null) == utc) as Boolean);
    Test.assert((store.writes == 0) as Boolean);
    return true;
}

(:test)
function legacyZeroAndEmptyCache(logger as Test.Logger) as Boolean {
    var store = new MemoryTargetStore();
    var utc = CountdownTargetTime.utcEpoch(2027, 1, 1, 0, 0);
    Test.assert(CountdownTargetTime.resolve("event1_", utc, "2027-1-1|1", 20700, store, 0) == utc - 20700);
    Test.assert((store.values["event1_target_time_version"] == 1) as Boolean);
    Test.assert(CountdownTargetTime.resolve("event1_", utc, "2027-1-1|1", 0, store, 0) == utc - 20700);
    return true;
}

(:test)
function strictNumbersAllowPaddedSettings(logger as Test.Logger) as Boolean {
    Test.assert(CountdownTargetTime.number("01") == 1);
    Test.assert(CountdownTargetTime.number("000") == 0);
    Test.assert(CountdownTargetTime.number("-001") == -1);
    Test.assert(CountdownTargetTime.number("") == null);
    Test.assert(CountdownTargetTime.number("-") == null);
    Test.assert(CountdownTargetTime.number("01oops") == null);
    Test.assert(CountdownTargetTime.number("99999999999999999999") == null);
    return true;
}

(:test)
function interruptedFirstSaveAndZeroOffset(logger as Test.Logger) as Boolean {
    var utc = CountdownTargetTime.utcEpoch(2027, 1, 1, 0, 0);
    var sig = "2027-1-1|1";
    for (var stop = 0; stop < 3; stop += 1) {
        var store = new MemoryTargetStore();
        store.failAfter = stop;
        CountdownTargetTime.resolve("event1_", utc, sig, 7200, store, 0);
        store.failAfter = -1;
        var expected = stop == 0 ? utc - 3600 : utc - 7200;
        Test.assert(CountdownTargetTime.resolve("event1_", utc, sig, 3600, store, 0) == expected);
        Test.assert(CountdownTargetTime.resolve("event1_", utc, sig, 0, store, 0) == expected);
    }
    var store = new MemoryTargetStore();
    store.values["event1_target_epoch"] = utc;
    store.values["event1_target_signature"] = sig;
    Test.assert(CountdownTargetTime.resolve("event1_", utc, sig, 0, store, null) == utc);
    Test.assert(CountdownTargetTime.resolve("event1_", utc, sig, 7200, store, null) == utc);
    return true;
}
