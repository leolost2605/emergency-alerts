/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

 public class EmA.Client : Object {
    public ListModel subscriptions { get { return subscription_manager.subscriptions; } }
    public ListModel warnings { get { return aggregator.warnings; } }

    public bool load_all { get { return refresh_manager.load_all; } set { refresh_manager.load_all = value; } }

    public bool refresh_timed_out { get { return refresh_manager.refresh_timed_out; } }

    private ProviderManager providers;
    private WarningAggregator aggregator;
    private LocationManager location_manager;
    private SubscriptionManager subscription_manager;
    private RefreshManager refresh_manager;

    construct {
        providers = new ProviderManager ();

        aggregator = new WarningAggregator (providers);

        location_manager = new LocationManager ();

        subscription_manager = new SubscriptionManager (aggregator, location_manager.locations);

        refresh_manager = new RefreshManager (providers, location_manager.locations);
        refresh_manager.notify["refresh-timed-out"].connect (() => notify_property ("refresh-timed-out"));
        refresh_manager.notify["load-all"].connect (() => notify_property ("load-all"));
    }

    public void subscribe (Location location) {
        location_manager.subscribe (location);
    }

    public void unsubscribe (string id) {
        location_manager.unsubscribe (id);
    }

    public void refresh_subscribed () {
        refresh_manager.refresh_all ();
    }
}
