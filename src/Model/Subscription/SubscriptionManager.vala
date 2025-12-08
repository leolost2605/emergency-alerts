/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.SubscriptionManager : Object {
    public WarningAggregator aggregator { private get; construct; }
    public ListModel locations { private get; construct; }

    private ListStore _subscriptions;
    public ListModel subscriptions { get { return _subscriptions; } }

    public SubscriptionManager (WarningAggregator aggregator, ListModel locations) {
        Object (aggregator: aggregator, locations: locations);
    }

    construct {
        // We manually sync subscriptions with locations and don't use MapListModel
        // because the subscriptions objects have to be created immediately as they are
        // responsible for sending notifications and map list model creates them lazily.
        _subscriptions = new ListStore (typeof (Subscription));

        locations.items_changed.connect (on_locations_changed);
        on_locations_changed (0, 0, locations.get_n_items ());
    }

    private void on_locations_changed (uint pos, uint removed, uint added) {
        var new_subscriptions = new Subscription[added];

        for (uint i = 0; i < added; i++) {
            var location = (Location) locations.get_item (pos + i);
            new_subscriptions[i] = new Subscription (aggregator.warnings, location);
        }

        _subscriptions.splice (pos, removed, new_subscriptions);
    }
}
