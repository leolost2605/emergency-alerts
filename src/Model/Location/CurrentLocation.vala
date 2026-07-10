/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard (leo.kargl@proton.me)
 */

[SingleInstance]
public class EmA.CurrentLocation : Location {
    public const string ID = "current-location";

    private Cancellable cancellable;

    public CurrentLocation () {
        Object (id: ID);
    }

    construct {
        coordinate = new Coordinate (0.0, 0.0);
        name = _("Current Location");
        description = _("Getting location…");

        cancellable = new Cancellable ();

        start.begin ();
    }

    ~CurrentLocation () {
        cancellable.cancel ();
        Utils.get_portal ().location_monitor_stop ();
    }

    private async void start () {
        var portal = Utils.get_portal ();
        portal.location_updated.connect (on_location_updated);

        try {
            yield portal.location_monitor_start (null, 0, 0, EXACT, NONE, cancellable);
        } catch (Error e) {
            description = _("Failed to get location (%s)").printf (e.message);
        }
    }

    private void on_location_updated (
        double latitude, double longitude, double altitude,
        double accuracy, double speed, double heading,
        string description, int64 timestamp_s, int64 timestamp_ms
    ) {
        coordinate = new Coordinate (latitude, longitude);

        update_description.begin ();
    }

    private async void update_description () {
        var location_search = new LocationSearch ();
        yield location_search.search_reverse (coordinate);

        if (location_search.locations.get_n_items () == 0) {
            description = _("Unknown Location");
            country_code = UNKNOWN;
            return;
        }

        var hit = (Location) location_search.locations.get_item (0);
        description = hit.name;
        country_code = hit.country_code;
    }
}
