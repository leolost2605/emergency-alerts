/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

 public class EmA.Client : Object {
    public ListModel subscriptions { get { return locations_manager.subscriptions; } }

    public LocationSearch location_search { get; construct; }

    private ProviderManager providers;
    private LocationsManager locations_manager;
    private RefreshManager refresh_manager;

    construct {
        providers = new ProviderManager ();

        locations_manager = new LocationsManager (providers);
        refresh_manager = new RefreshManager (locations_manager.subscriptions, providers);
        location_search = new LocationSearch (locations_manager);
    }

    public void subscribe (Location location) {
        locations_manager.subscribe (location.id);
    }

    public void unsubscribe (string id) {
        locations_manager.unsubscribe (id);
    }

    public void refresh_subscribed () {
        refresh_manager.refresh_all ();
    }
}
