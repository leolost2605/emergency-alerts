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
                continue;
            } catch (Error e) {
                warning ("Invalid location format, trying old format: %s", loc);
            }

            var split = loc.split ("=");
            if (split.length == 3) {
                var provider_id = split[0];
                var id = split[1];
                var name = split[2];

                locations += new Location (provider_id, id, name, "");
            } else {
                critical ("Invalid location format: %s", loc);
            }
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
