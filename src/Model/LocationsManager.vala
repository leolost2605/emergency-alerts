/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.LocationsManager : Object {
    public ProviderManager providers { get; construct;}

    private ListStore store;
    public ListModel locations { get { return store; } }

    public ListModel subscriptions { get; construct; }

    private Gtk.Filter subscription_filter;
    private bool loaded = false;

    private Database db;

    public LocationsManager (ProviderManager providers) {
        Object (providers: providers);
    }

    construct {
        store = new ListStore (typeof (Location));

        subscription_filter = new Gtk.BoolFilter (new Gtk.PropertyExpression (typeof (Location), null, "subscribed"));

        subscriptions = new Gtk.FilterListModel (store, subscription_filter) {
            incremental = true
        };

        db = new Database ();

        load_subscriptions ();
    }

    private Location create_location (Provider provider, string location_id, string name) {
        for (int i = 0; i < store.n_items; i++) {
            var loc = (Location) store.get_item (i);
            if (loc.provider_id == provider.id && loc.location_id == location_id) {
                warning ("Already created");
                return loc;
            }
        }

        var location = new Location (provider.id, location_id, name);
        store.append (location);

        return location;
    }

    public async void load_all () {
        loaded = true;
        warning ("Loading all locations from providers...");
        foreach (var provider in providers.list_all ()) {
            yield provider.list_all_locations ((provider_id, location_id, name) => {
                create_location (provider, location_id, name);
            });
        }
        warning ("LOADED all locations from providers...");
    }

    public void unload_all () {
        loaded = false;
        cleanup ();
    }

    private void cleanup () {
        if (loaded) {
            return;
        }

        for (int i = (int) store.n_items - 1; i >= 0; i--) {
            var location = (Location) store.get_item (i);
            if (!location.subscribed) {
                store.remove (i);
            }
        }
    }

    public void subscribe (string id) {
        var location = find_location (id, false);

        if (location == null) {
            warning ("Location with id '%s' not found", id);
            return;
        }

        db.add_location (location.provider_id, location.location_id, location.name);
        location.set_warnings (providers[location.provider_id].subscribe (location.location_id));
        subscription_filter.changed (LESS_STRICT);

        providers[location.provider_id].refresh_location.begin (location.location_id);
    }

    public void unsubscribe (string id) {
        var location = find_location (id, true);

        if (location == null) {
            debug ("Location with id '%s' not found", id);
            return;
        }

        db.remove_location (location.provider_id, location.location_id);
        providers[location.provider_id].unsubscribe (location.location_id);
        location.set_warnings (null);
        subscription_filter.changed (MORE_STRICT);
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

    private Location? find_location (string id, bool subscribed_only) {
        ListModel list = subscribed_only ? subscriptions : store;
        for (uint i = 0; i < list.get_n_items (); i++) {
            var location = (Location) list.get_item (i);
            if (location.id == id) {
                return location;
            }
        }

        return null;
    }
}
