/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.DashboardPage : Adw.Bin {
    public Client client { get; construct; }

    public DashboardPage (Client client) {
        Object (client: client);
    }

    construct {
        var button = new Gtk.Button.with_label (_("Add location…")) {
            action_name = "win.add-location",
            halign = CENTER,
        };
        button.add_css_class ("suggested-action");
        button.add_css_class ("pill");

        var status_page = new Adw.StatusPage () {
            title = _("No locations added yet"),
            description = _("Add a location to start receiving alerts."),
            child = button,
        };

        var subscription_boxes = new Gtk.ListBox () {
            margin_top = 12,
            margin_bottom = 12,
            margin_end = 18,
            margin_start = 18,
            selection_mode = NONE
        };
        subscription_boxes.add_css_class (Granite.STYLE_CLASS_BACKGROUND);
        subscription_boxes.set_placeholder (status_page);
        subscription_boxes.bind_model (client.subscriptions, create_subscription_box_func);

        var clamp = new Adw.Clamp () {
            child = subscription_boxes,
            maximum_size = 700,
            tightening_threshold = 500
        };

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = clamp,
            vexpand = true,
            hscrollbar_policy = NEVER
        };

        child = scrolled_window;
    }

    private static Gtk.Widget create_subscription_box_func (Object obj) {
        var child = new SubscriptionBox ((Subscription) obj);
        return new Gtk.ListBoxRow () {
            child = child,
            selectable = false,
            activatable = false,
            margin_bottom = 18
        };
    }
}
