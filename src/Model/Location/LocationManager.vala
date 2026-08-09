/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.LocationManager : Object {
    private ListStore _locations;
    public ListModel locations { get { return _locations; } }

    private Database db;
    private Settings settings;

    construct {
        db = new Database ();

        _locations = new ListStore (typeof (Location));
        _locations.items_changed.connect (save_locations);

        load_locations.begin ();

        settings = new Settings ("io.github.leolost2605.emergency-alerts");
        settings.changed["current-location"].connect (check_current_location_setting);
        check_current_location_setting ();
    }

    private void save_locations () {
        var locations_array = new FixedLocation[0];
        for (uint i = 0; i < locations.get_n_items (); i++) {
            var location = locations.get_item (i);
            if (location is FixedLocation) {
                locations_array += (FixedLocation) location;
            }
        }

        db.set_locations (locations_array);
    }

    private void check_current_location_setting () {
        uint pos;
        var exists = find_location (CurrentLocation.ID, out pos);

        if (!exists && settings.get_boolean ("current-location")) {
            _locations.insert (0, new CurrentLocation ());
        } else if (exists && !settings.get_boolean ("current-location")) {
            _locations.remove (pos);
        }
    }

    private async void load_locations () {
        foreach (var location in yield db.get_locations ()) {
            subscribe (location);
        }
    }

    public void subscribe (Location location) requires (location is FixedLocation) {
        if (find_location (location.id, null)) {
            return;
        }

        _locations.append (location);
    }

    public void unsubscribe (string id) {
        if (id == CurrentLocation.ID) {
            settings.set_boolean ("current-location", false);
            return;
        }

        uint pos;
        if (find_location (id, out pos)) {
            _locations.remove (pos);
        }
    }

    private bool find_location (string id, out uint pos) {
        for (uint i = 0; i < locations.get_n_items (); i++) {
            var location = (Location) locations.get_item (i);
            if (location.id == id) {
                pos = i;
                return true;
            }
        }

        pos = Gtk.INVALID_LIST_POSITION;
        return false;
    }
}
