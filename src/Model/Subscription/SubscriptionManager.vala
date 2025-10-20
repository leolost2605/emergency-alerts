/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.SubscriptionManager : Object {
    public ProviderManager providers { get; construct; }

    private ListStore store;
    public ListModel subscriptions { get { return store; } }

    private Database db;

    public SubscriptionManager (ProviderManager providers) {
        Object (providers: providers);
    }

    construct {
        store = new ListStore (typeof (Subscription));
        store.items_changed.connect (save_subscriptions);

        db = new Database ();

        load_subscriptions ();
    }

    public void subscribe (Location location) {
        if (find_subscription (location.id, null)) {
            return;
        }

        var provider = providers[location.provider_id];

        if (provider == null) {
            warning ("Provider with id '%s' not found for location '%s'", location.provider_id, location.name);
            return;
        }

        var subscription = new Subscription (provider, location);
        store.append (subscription);
    }

    public void unsubscribe (string id) {
        uint pos;
        if (find_subscription (id, out pos)) {
            store.remove (pos);
        }
    }

    private bool find_subscription (string id, out uint pos) {
        for (uint i = 0; i < store.get_n_items (); i++) {
            var subscription = (Subscription) store.get_item (i);
            if (subscription.location.id == id) {
                pos = i;
                return true;
            }
        }

        pos = Gtk.INVALID_LIST_POSITION;
        return false;
    }

    private void load_subscriptions () {
        foreach (var location in db.get_locations ()) {
            subscribe (location);
        }
    }

    private void save_subscriptions () {
        var locations = new Location[store.get_n_items ()];
        for (uint i = 0; i < store.get_n_items (); i++) {
            var subscription = (Subscription) store.get_item (i);
            locations[i] = subscription.location;
        }

        db.set_locations (locations);
    }
}
