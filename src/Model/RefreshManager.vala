/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.RefreshManager : Object {
    public ProviderManager providers { get; construct; }
    public ListModel subscriptions { get; construct; }

    public RefreshManager (ProviderManager providers, ListModel subscriptions) {
        Object (providers: providers, subscriptions: subscriptions);
    }

    construct {
        Timeout.add_seconds (5, () => {
            refresh_all ();
            return Source.CONTINUE;
        });
    }

    public void refresh_all () {
        foreach (var provider in providers.list_all ()) {
            provider.refresh_all.begin ();
        }
    }
}
