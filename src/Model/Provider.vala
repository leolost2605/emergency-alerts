/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

/**
 * The base class for all providers.
 */
public abstract class EmA.Provider : Object {
    /**
     * Takes a location and refreshes its warnings. It should remove outdated warnings from the
     * locations {@link Location.warnings} list, add new ones and update the properties of existing
     * ones.
     * The provider may choose to refresh locations on its own, but it should always refresh when
     * this method is called.
     *
     * @param location The location to refresh.
     */
    public abstract async void refresh_location (Location location);

    /**
     * Returns a list of all locations this provider can provide.
     */
    public abstract async ListModel list_all_locations ();
}
