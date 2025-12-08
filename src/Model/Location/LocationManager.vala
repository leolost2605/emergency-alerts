/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.LocationManager : Object {
    private ListStore _locations;
    public ListModel locations { get { return _locations; } }

    private Database db;

    construct {
        db = new Database ();

        _locations = new ListStore (typeof (FixedLocation));
        _locations.items_changed.connect (save_locations);

        load_locations.begin ();
    }

    private void save_locations () {
        var locations_array = new FixedLocation[locations.get_n_items ()];
        for (uint i = 0; i < locations.get_n_items (); i++) {
            var location = (FixedLocation) locations.get_item (i);
            locations_array[i] = location;
        }

        db.set_locations (locations_array);
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
