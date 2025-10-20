/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.RefreshManager : Object {
    public ListModel subscriptions { get; construct; }

    public RefreshManager (ListModel subscriptions) {
        Object (subscriptions: subscriptions);
    }

    construct {
        Timeout.add_seconds (5, () => {
            refresh_all ();
            return Source.CONTINUE;
        });
    }

    public void refresh_all () {
        for (uint i = 0; i < subscriptions.get_n_items (); i++) {
            var subscription = (Subscription) subscriptions.get_item (i);
            subscription.refresh ();
        }
    }
}
