/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.RefreshManager : Object {
    public ProviderManager providers { get; construct; }
    public ListModel subscriptions { get; construct; }

    public RefreshManager (ProviderManager providers, ListModel subscriptions) {
        Object (providers: providers, subscriptions: subscriptions);
    }

    construct {
        // A location might have been added, refresh immediately
        subscriptions.items_changed.connect (refresh_all);

        Timeout.add_seconds (5, () => {
            refresh_all ();
            return Source.CONTINUE;
        });
    }

    public void refresh_all () {
        var locations = new Coordinate[subscriptions.get_n_items ()];
        for (uint i = 0; i < subscriptions.get_n_items (); i++) {
            var subscription = (Subscription) subscriptions.get_item (i);
            locations[i] = subscription.location.coordinate;
        }

        foreach (var provider in providers.list_all ()) {
            provider.refresh.begin (locations);
        }
    }
}
