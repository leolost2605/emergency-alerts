/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Database : Object {
    private Settings settings = new Settings ("io.github.leolost2605.emergency-alerts");

    public Location[] get_locations () {
        Location[] locations = {};
        var locs = settings.get_strv ("locations");
        foreach (var loc in locs) {
            try {
                var variant = Variant.parse (null, loc);
                locations += new Location.from_variant (variant);
            } catch (Error e) {
                critical ("Invalid location format, trying old format: %s", loc);
                // Send notification?
            }

            // TODO: Handle old format by just ignoring it or sending a notification
        }

        return locations;
    }

    public void set_locations (Location[] locations) {
        string[] locs = {};
        foreach (var loc in locations) {
            locs += loc.to_variant ().print (true);
        }

        settings.set_strv ("locations", locs);
    }
}
