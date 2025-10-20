/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Subscription : Object, ListModel {
    public Provider provider { get; construct; }

    public Location location { get; construct; }

    private ListModel warnings;

    internal Subscription (Provider provider, Location location) {
        Object (provider: provider, location: location);
    }

    construct {
        warnings = provider.subscribe (location.location_id);
        warnings.items_changed.connect (on_items_changed);
    }

    private void on_items_changed (uint pos, uint removed, uint added) {
        items_changed (pos, removed, added);

        for (uint i = 0; i < added; i++) {
            send_notification ((Warning) warnings.get_item (pos + i));
        }
    }

    private void send_notification (Warning warning) {
        var notification = new Notification (_("New warning for %s").printf (location.name));
        notification.set_body (warning.title);
        GLib.Application.get_default ().send_notification (warning.id, notification);
    }

    public void refresh () {
        provider.refresh_location.begin (location.location_id);
    }

    public Type get_item_type () {
        return typeof (Warning);
    }

    public uint get_n_items () {
        return warnings.get_n_items ();
    }

    public Object? get_item (uint position) {
        return warnings.get_item (position);
    }
}
