/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.SubscriptionManager : Object {
    public WarningAggregator aggregator { get; construct; }

    private ListStore store;
    public ListModel subscriptions { get { return store; } }

    private Database db;

    public SubscriptionManager (WarningAggregator aggregator) {
        Object (aggregator: aggregator);
    }

    construct {
        store = new ListStore (typeof (Subscription));
        store.items_changed.connect (save_subscriptions);

        db = new Database ();

        load_subscriptions.begin ();
    }

    public void subscribe (Location location) {
        if (find_subscription (location.id, null)) {
            return;
        }

        var subscription = new Subscription (aggregator.warnings, location);
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

    private async void load_subscriptions () {
        foreach (var location in yield db.get_locations ()) {
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
