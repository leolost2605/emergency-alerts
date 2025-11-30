/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

 public class EmA.Client : Object {
    public ListModel subscriptions { get { return subscription_manager.subscriptions; } }
    public ListModel warnings { get { return aggregator.warnings; } }

    public bool refresh_timed_out { get { return refresh_manager.refresh_timed_out; } }

    private ProviderManager providers;
    private WarningAggregator aggregator;
    private SubscriptionManager subscription_manager;
    private RefreshManager refresh_manager;

    construct {
        providers = new ProviderManager ();

        aggregator = new WarningAggregator (providers);

        subscription_manager = new SubscriptionManager (aggregator);

        refresh_manager = new RefreshManager (providers, subscription_manager.subscriptions);
        refresh_manager.notify["refresh-timed-out"].connect (() => notify_property ("refresh-timed-out"));
    }

    public void subscribe (Location location) {
        subscription_manager.subscribe (location);
    }

    public void unsubscribe (string id) {
        subscription_manager.unsubscribe (id);
    }

    public void refresh_subscribed () {
        refresh_manager.refresh_all ();
    }
}
