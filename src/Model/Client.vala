/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

 public class EmA.Client : Object {
    public ListModel subscriptions { get { return subscription_manager.subscriptions; } }

    public LocationSearch location_search { get; construct; }

    private ProviderManager providers;
    private SubscriptionManager subscription_manager;
    private RefreshManager refresh_manager;

    construct {
        providers = new ProviderManager ();

        subscription_manager = new SubscriptionManager (providers);
        refresh_manager = new RefreshManager (subscription_manager.subscriptions);

        location_search = new LocationSearch (providers);
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
