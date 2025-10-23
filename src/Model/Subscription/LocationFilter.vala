/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.LocationFilter : Gtk.Filter {
    public Coordinate location { get; construct; }

    internal LocationFilter (Coordinate location) {
        Object (location: location);
    }

    public override bool match (Object? obj) requires (obj is Warning) {
        var warning = (Warning) obj;

        if (warning.area == null) {
            return false;
        }

        return warning.area.contains_point (location);
    }
}
