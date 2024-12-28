/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public abstract class EmA.Provider : Object {
    public abstract async void refresh_location (Location location);
    public abstract async ListModel list_all_locations ();
}
