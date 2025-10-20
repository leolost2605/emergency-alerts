/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.DashboardPage : Adw.NavigationPage {
    public Client client { get; construct; }
    public Gtk.SizeGroup header_bar_size_group { get; construct; }

    private Gtk.Box subscription_boxes;
    private Gtk.Stack stack;

    public DashboardPage (Client client, Gtk.SizeGroup header_bar_size_group) {
        Object (client: client, header_bar_size_group: header_bar_size_group);
    }

    construct {
        var content_section = new Menu ();
        content_section.append (_("Add new location…"), "win.add-location");

        var window_section = new Menu ();
        window_section.append (_("Close"), "app.close");

        var menu = new Menu ();
        menu.append_section (null, content_section);
        menu.append_section (null, window_section);

        var menu_button = new Gtk.MenuButton () {
#if ADWAITA
            icon_name = "open-menu-symbolic",
#else
            icon_name = "open-menu",
#endif
            menu_model = menu
        };
#if !ADWAITA
        menu_button.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);
#endif

        var header_bar = new Adw.HeaderBar ();
        header_bar.pack_end (menu_button);
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

        header_bar_size_group.add_widget (header_bar);

        subscription_boxes = new Gtk.Box (VERTICAL, 18) {
            margin_top = 12,
            margin_bottom = 12,
            margin_end = 18,
            margin_start = 18
        };

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

        var placeholder_text = new Gtk.Label (
            _("<big><b>No locations added yet</b></big>\nAdd a location to start receiving alerts.")
        ) {
            margin_top = 12,
            margin_bottom = 12,
            use_markup = true,
            xalign = 0.5f,
            yalign = 0.5f,
            justify = CENTER,
        };

        var button = new Gtk.Button.with_label (_("Add location…")) {
            action_name = "win.add-location"
        };
        button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
        button.add_css_class ("pill");

        var placeholder_box = new Gtk.Box (VERTICAL, 12) {
            margin_bottom = 18,
            margin_end = 18,
            margin_start = 18,
            halign = CENTER,
            valign = CENTER,
        };
        placeholder_box.append (placeholder_text);
        placeholder_box.append (button);

        stack = new Gtk.Stack ();
        stack.add_named (scrolled_window, "subscriptions");
        stack.add_named (placeholder_box, "placeholder");

        var box = new Gtk.Box (VERTICAL, 0);
        box.append (header_bar);
        box.append (stack);

        child = box;
        title = _("Dashboard");

        // TODO: Use ListBox? I don't remember why I didn't use it here.
        repopulate_subscription_box ();
        client.subscriptions.items_changed.connect (repopulate_subscription_box);
    }

    private void repopulate_subscription_box () {
        for (
            var first_child = subscription_boxes.get_first_child ();
            first_child != null;
            first_child = subscription_boxes.get_first_child ()
        ) {
            subscription_boxes.remove (first_child);
        }

        stack.visible_child_name = client.subscriptions.get_n_items () > 0 ? "subscriptions" : "placeholder";

        for (int i = 0; i < client.subscriptions.get_n_items (); i++) {
            var subscription_box = new SubscriptionBox ((Subscription) client.subscriptions.get_item (i));
            subscription_boxes.append (subscription_box);
        }
    }
}
