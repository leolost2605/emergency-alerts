/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Database : Object {
    private Settings settings = new Settings ("io.github.leolost2605.emergency-alerts");

    public async Location[] get_locations () {
        Location[] locations = {};
        var locs = settings.get_strv ("locations");
        foreach (var loc in locs) {
            try {
                var variant = Variant.parse (null, loc);
                locations += new FixedLocation.from_variant (variant);
                continue;
            } catch (Error e) {
                critical ("Invalid location format, trying old format: %s", loc);
            }

            // Try to convert the old format
            var split = loc.split ("=");
            if (split.length == 3) {
                var name = split[2];

                var search = new LocationSearch ();
                yield search.search (name);

                if (search.locations.get_n_items () > 0) {
                    var updated_location = (Location) search.locations.get_item (0);
                    locations += updated_location;

                    var notification = new Notification (_("Replaced location %s with %s").printf (name, updated_location.name));
                    notification.set_body (_("The location format has changed, so your saved location has been updated to the new format. This was done on a best effort basis. Therefore please check if the new location is correct."));
                    notification.set_icon (new ThemedIcon ("dialog-warning-symbolic"));
                    GLib.Application.get_default ().send_notification (null, notification);
                    continue;
                }
            }

            var notification = new Notification (_("Could not load saved location"));
            notification.set_body (_("An error occured when loading saved locations. Please make sure your saved locations are correct or re-add them if necessary. This is a bug and should be reported to the developers if possible."));
            notification.set_icon (new ThemedIcon ("process-error-symbolic"));
            notification.set_priority (HIGH);
            GLib.Application.get_default ().send_notification (null, notification);
        }

        return locations;
    }

    public void set_locations (FixedLocation[] locations) {
        string[] locs = {};
        foreach (var loc in locations) {
            locs += loc.to_variant ().print (true);
        }

        settings.set_strv ("locations", locs);
    }
}
