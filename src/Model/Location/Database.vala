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

    public void add_location (string provider_id, string location_id, string name) {
        var as_string = "%s=%s=%s".printf (provider_id, location_id, name);
        var saved_locations = settings.get_strv ("locations");

        if (as_string in saved_locations) {
            return;
        }

        saved_locations += as_string;
        settings.set_strv ("locations", saved_locations);
    }

    public void remove_location (string provider_id, string id) {
        var locs = settings.get_strv ("locations");

        string[] new_locs = {};
        foreach (var loc in locs) {
            if (!(id in loc) || !(provider_id in loc)) {
                new_locs += loc;
            }
        }

        settings.set_strv ("locations", new_locs);
    }

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
}
