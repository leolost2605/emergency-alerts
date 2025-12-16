/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public enum EmA.CountryCode {
    DE,
    UA,
    US,
    UNKNOWN,
    OTHER;

    public string to_string () {
        var val = ((EnumClass) typeof (CountryCode).class_ref ()).get_value (this);
        return val.value_nick.up ();
    }

    public static CountryCode from_string (string code) {
        if (code == "??") {
            return UNKNOWN;
        }

        var enum_class = (EnumClass) typeof (CountryCode).class_ref ();
        var val = enum_class.get_value_by_nick (code.down ());

        return val != null ? val.value : OTHER;
    }
}
