/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.LocationsManager : Object {
    public ProviderManager providers { get; construct;}

    private ListStore store;
    public ListModel locations { get { return store; } }

    private Gtk.SliceListModel slice;
    public ListModel subscriptions { get { return slice; } }

    private bool loaded = false;

    private Database db;

    public LocationsManager (ProviderManager providers) {
        Object (providers: providers);
    }

    construct {
        store = new ListStore (typeof (Location));

        slice = new Gtk.SliceListModel (store, 0, 0);

        db = new Database ();

        load_subscriptions ();
    }

    private Location create_location (Provider provider, string location_id, string name) {
        //  for (int i = 0; i < store.n_items; i++) {
        //      var loc = (Location) store.get_item (i);
        //      if (loc.provider_id == provider.id && loc.location_id == location_id) {
        //          warning ("Already created");
        //          return loc;
        //      }
        //  }

        var location = new Location (provider.id, location_id, name);
        store.append (location);

        return location;
    }

    public async void load_all () {
        loaded = true;
        foreach (var provider in providers.list_all ()) {
            yield provider.list_all_locations ((provider_id, location_id, name) => {
                create_location (provider, location_id, name);
            });
        }
    }

    public void unload_all () {
        loaded = false;
        cleanup ();
    }

    private void cleanup () {
        if (loaded) {
            return;
        }

        store.splice (slice.size, store.n_items - slice.size, {});
    }

    public void subscribe (string id) {
        uint position;
        var location = find_location (id, false, out position);

        if (location == null) {
            warning ("Location with id '%s' not found", id);
            return;
        }

        db.add_location (location.provider_id, location.location_id, location.name);
        location.set_warnings (providers[location.provider_id].subscribe (location.location_id));

        store.remove (position);
        store.insert (0, location);
        slice.size++;

        providers[location.provider_id].refresh_location.begin (location.location_id);
    }

    public void unsubscribe (string id) {
        uint position;
        var location = find_location (id, false, out position);

        if (location == null) {
            debug ("Location with id '%s' not found", id);
            return;
        }

        db.remove_location (location.provider_id, location.location_id);
        providers[location.provider_id].unsubscribe (location.location_id);
        location.set_warnings (null);

        store.remove (position);
        store.append (location);
        slice.size--;

        cleanup ();
    }

    private void load_subscriptions () {
        var data = db.get_locations ();
        foreach (var loc in data) {
            var provider = providers[loc.provider_id];

            if (provider == null) {
                warning ("Provider with id '%s' not found for location '%s'", loc.provider_id, loc.name);
                continue;
            }

            var location = create_location (providers[loc.provider_id], loc.location_id, loc.name);
            subscribe (location.id);
        }
    }

    private Location? find_location (string id, bool subscribed_only, out uint position) {
        ListModel list = subscribed_only ? subscriptions : store;
        for (uint i = 0; i < list.get_n_items (); i++) {
            var location = (Location) list.get_item (i);
            if (location.id == id) {
                position = i;
                return location;
            }
        }

        return null;
    }
}
