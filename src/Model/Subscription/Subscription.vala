/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Subscription : Object {
    public ListModel warnings { get; construct; }
    public Location location { get; construct; }

    internal Subscription (ListModel all_warnings, Location location) {
        var filter = new LocationFilter (location);
        var warnings = new Gtk.FilterListModel (all_warnings, filter);

        Object (warnings: warnings, location: location);
    }

    construct {
        warnings.items_changed.connect (on_items_changed);
    }

    private void on_items_changed (uint pos, uint removed, uint added) {
        for (uint i = 0; i < added; i++) {
            send_notification ((Warning) warnings.get_item (pos + i));
        }
    }

    private void send_notification (Warning warning) {
        var notification = new Notification (_("New warning for %s").printf (location.name));
        notification.set_body (warning.title ?? _("No information available. Check the app for more details."));
        GLib.Application.get_default ().send_notification (warning.id, notification);
    }
}
