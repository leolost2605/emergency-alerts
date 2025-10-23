/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

/**
 * The base class for all providers.
 */
public abstract class EmA.Provider : Object {
    public abstract ListModel warnings { get; }

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
     */
    public abstract void subscribe (string location_id);

    /**
     * Unsubscribes from the location with the given id. The provider should stop
     * checking for warnings for this location and release any references on the previously
     * returned ListModel and any warnings it contained.
     *
     * @param location_id The id of the location to unsubscribe from.
     */
    public abstract void unsubscribe (string location_id);

    /**
     * Tells the provider to refresh warnings for all locations. It should remove outdated warnings
     * from {@link warnings}, add new ones and update the properties of existing ones.
     * The provider may choose to refresh locations on its own, but it should always refresh when
     * this method is called.
     */
    public abstract async void refresh_all ();
}
