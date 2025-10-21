/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.HomePage : Adw.NavigationPage {
    public Client client { get; construct; }
    public Gtk.SizeGroup header_bar_size_group { get; construct; }

    public HomePage (Client client, Gtk.SizeGroup header_bar_size_group) {
        Object (
            client: client,
            header_bar_size_group: header_bar_size_group
        );
    }

    construct {
        var dashboard_page = new DashboardPage (client);
        var map_page = new MapPage (client);

        var view_stack = new Adw.ViewStack ();
        view_stack.add_titled_with_icon (dashboard_page, "dashboard", _("Dashboard"), "map-marker-symbolic");
        view_stack.add_titled_with_icon (map_page, "map", _("Map"), "earth-symbolic");

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

        var view_switcher = new Adw.ViewSwitcher () {
            stack = view_stack,
            policy = WIDE
        };

        var header_bar = new Adw.HeaderBar () {
            title_widget = view_switcher,
        };
        header_bar.pack_end (menu_button);
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

        header_bar_size_group.add_widget (header_bar);

        var toolbar_view = new Adw.ToolbarView () {
            content = view_stack
        };
        toolbar_view.add_top_bar (header_bar);

        child = toolbar_view;
        title = _("Home");
    }
}
