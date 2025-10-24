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
        view_stack.add_titled_with_icon (map_page, "map", _("Map"), "map-symbolic");

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

        var view_switcher_bar = new Adw.ViewSwitcherBar () {
            stack = view_stack,
            reveal = false,
        };

        var toolbar_view = new Adw.ToolbarView () {
            content = view_stack
        };
        toolbar_view.add_top_bar (header_bar);
        toolbar_view.add_bottom_bar (view_switcher_bar);

        var condition = new Adw.BreakpointCondition.length (MAX_WIDTH, 550, SP);
        var breakpoint = new Adw.Breakpoint ((owned) condition);
        breakpoint.add_setter (header_bar, "title-widget", Value (typeof (Gtk.Widget)));
        breakpoint.add_setter (view_switcher_bar, "reveal", true);

        var bin = new Adw.BreakpointBin () {
            child = toolbar_view,
            height_request = 300,
            width_request = 200,
        };
        bin.add_breakpoint (breakpoint);

        child = bin;
        title = _("Home");
    }
}
