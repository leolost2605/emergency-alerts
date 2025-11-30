/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.RefreshManager : Object {
    public ProviderManager providers { get; construct; }
    public ListModel subscriptions { get; construct; }

    /**
     * Will be set to true if any provider's refresh operation
     * is taking too long (more than 20 seconds).
     */
    public bool refresh_timed_out { get; private set; }

    private uint n_refreshing = 0;
    private uint check_timed_out_id = 0;

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
            refresh_provider (provider, locations);
        }
    }

    private void refresh_provider (Provider provider, Coordinate[] locations) {
        n_refreshing++;
        provider.refresh.begin (locations, on_refresh_done);

        if (check_timed_out_id == 0) {
            check_timed_out_id = Timeout.add_seconds_once (20, notify_refresh_timed_out);
        }
    }

    private void on_refresh_done () {
        n_refreshing--;

        if (n_refreshing > 0) {
            return;
        }

        if (check_timed_out_id != 0) {
            Source.remove (check_timed_out_id);
            check_timed_out_id = 0;
        }

        refresh_timed_out = false;
    }

    private void notify_refresh_timed_out () {
        if (check_timed_out_id > 0) {
            refresh_timed_out = true;
        }

        check_timed_out_id = 0;
    }
}
