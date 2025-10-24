/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

/**
 * The base class for all providers.
 */
public abstract class EmA.Provider : Object {
    /**
     * A list with the warnings the provider currently provides.
     * Depending on the capabilities these might be all available warnings the provider has
     * or only the warnings for the locations that were given in the last call to {@link refresh}.
     * See {@link refresh} for more details about what warnings have to appear in this list at a given time.
     * The warnings in this list only require the fields that are required in the warnings constructor
     * i.e. id and area. Everything else may be set at a later time. Note however that adding a warning
     * to this list might immediately send a notification. Therefore warnings should at least already
     * have a meaningful title when added.
     * If a warning has changed enough that the provider deems it worthy a new notification, it should
     * emit an `items_changed (pos, 1, 1)` signal on this list where `pos` is the position of the warning
     * in the list.
     */
    public abstract ListModel warnings { get; }

    /**
     * Tells the provider to refresh warnings. It should remove outdated warnings
     * from {@link warnings}, add new ones and update the properties of existing ones.
     * The provider may choose to refresh locations on its own, but it should always refresh when
     * this method is called.
     * If {@link locations} is not null the provider should try to reduce bandwidth by only refreshing
     * warnings for the given locations. It should also try to remove warnings that aren't relevant
     * for the given locations but may have been relevant previously.
     * All of this of course depends on the capabilities of the provider. It is ok to always provide
     * all warnings if the provider does not support location-based filtering.
     * If {@link locations} is null the provider should try to get all warnings. This happens rarely
     * and usually only when the user opens the map view and requests all warnings to be shown. Therefore
     * it is ok if that is an expensive operation.
     */
    public abstract async void refresh (Coordinate[]? locations);
}
