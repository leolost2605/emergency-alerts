/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.DashboardPage : Adw.NavigationPage {
    public Client client { get; construct; }
    public Gtk.SizeGroup header_bar_size_group { get; construct; }

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

        var button = new Gtk.Button.with_label (_("Add location…")) {
            action_name = "win.add-location",
            halign = CENTER,
        };
        button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
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

        var box = new Gtk.Box (VERTICAL, 0);
        box.append (header_bar);
        box.append (scrolled_window);

        child = box;
        title = _("Dashboard");
    }

    private Gtk.Widget create_subscription_box_func (Object obj) {
        var child = new SubscriptionBox ((Subscription) obj);
        return new Gtk.ListBoxRow () {
            child = child,
            selectable = false,
            activatable = false,
            margin_bottom = 18
        };
    }
}
