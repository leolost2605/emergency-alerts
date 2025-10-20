/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Database : Object {
    public struct LocationData {
        public string provider_id;
        public string location_id;
        public string name;
    }

    private Settings settings = new Settings ("io.github.leolost2605.emergency-alerts");

    public LocationData[] get_locations () {
        LocationData[] data = {};
        var locs = settings.get_strv ("locations");
        foreach (var loc in locs) {
            var split = loc.split ("=");
            if (split.length == 3) {
                var provider_id = split[0];
                var id = split[1];
                var name = split[2];

                data += LocationData () {
                    provider_id = provider_id,
                    location_id = id,
                    name = name
                };
            } else {
                critical ("Invalid location format: %s", loc);
            }
        }

        return data;
    }

    public void set_locations (LocationData[] locations) {
        string[] locs = {};
        foreach (var loc in locations) {
            var as_string = "%s=%s=%s".printf (loc.provider_id, loc.location_id, loc.name);
            locs += as_string;
        }

        settings.set_strv ("locations", locs);
    }
}
