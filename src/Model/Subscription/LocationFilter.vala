/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.LocationFilter : Gtk.Filter {
    public Location location { get; construct; }

    internal LocationFilter (Location location) {
        Object (location: location);
    }

    construct {
        location.notify["coordinate"].connect (() => changed (DIFFERENT));
    }

    public override bool match (Object? obj) requires (obj is Warning) {
        var warning = (Warning) obj;

        if (warning.area == null) {
            return false;
        }

        return warning.area.contains_point (location.coordinate);
    }
}
