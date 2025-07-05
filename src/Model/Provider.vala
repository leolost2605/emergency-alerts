/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

/**
 * The base class for all providers.
 */
public abstract class EmA.Provider : Object {
    public delegate void ForeachLocationFunc (Provider provider, string location_id, string name);

    public abstract string id { get; }

    /**
     * Subscribes to the location with the given id. The provider should start
     * checking for warnings for this location and fill the returned ListModel with
     * warnings as they come in. If possible the provider should update warnings
     * once received. If that is not possible it should update warnings on
     * the refresh_location call which will be called periodically and can be configured
     * by the user.
     * The given location_id is guaranteed to be one previously gotten via the list_all_locations
     * method.
     *
     * @param location_id The id of the location to subscribe to.
     * @return A ListModel containing the warnings for the location.
     */
    public abstract ListModel subscribe (string location_id);

    /**
     * Unsubscribes from the location with the given id. The provider should stop
     * checking for warnings for this location and release any references on the previously
     * returned ListModel and any warnings it contained.
     *
     * @param location_id The id of the location to unsubscribe from.
     */
    public abstract void unsubscribe (string location_id);

    /**
     * Tells the provider to refresh warnings for the given location. It should remove outdated warnings
     * from the ListModel it returned on subscribe, add new ones and update the properties of existing
     * ones.
     * The provider may choose to refresh locations on its own, but it should always refresh when
     * this method is called.
     *
     * @param location_id The id of the location to refresh.
     */
    public abstract async void refresh_location (string location_id);

    /**
     * Calls func for each location this provider provides.
     */
    public abstract async void list_all_locations (ForeachLocationFunc func);
}
