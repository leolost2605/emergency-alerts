/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.RefreshManager : Object {
    public ListModel locations { get; construct; }
    public ProviderManager providers { get; construct; }

    public RefreshManager (ListModel locations, ProviderManager providers) {
        Object (locations: locations, providers: providers);
    }

    construct {
        Timeout.add_seconds (5, () => {
            refresh_all ();
            return Source.CONTINUE;
        });
    }

    public void refresh_all () {
        for (uint i = 0; i < locations.get_n_items (); i++) {
            var location = (Location) locations.get_item (i);
            providers[location.provider_id].refresh_location.begin (location.location_id);
        }
    }
}
