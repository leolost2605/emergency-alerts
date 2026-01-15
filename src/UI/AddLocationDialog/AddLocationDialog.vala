/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.AddLocationDialog : Adw.Dialog {
    public Client client { get; construct; }

    private Adw.NavigationView navigation_view;

    public AddLocationDialog (Client client) {
        Object (client: client);
    }

    construct {
        var settings = new Settings ("io.github.leolost2605.emergency-alerts");

        var current_location_row = new Adw.SwitchRow () {
            title = _("Current Location"),
            subtitle = _("Show alerts for your current location"),
        };
        settings.bind ("current-location", current_location_row, "active", DEFAULT);

        var search_image = new Gtk.Image.from_icon_name ("go-next-symbolic");

        var search_row = new Adw.ActionRow () {
            title = _("Search Location"),
            subtitle = _("Add a location by searching for it"),
            activatable_widget = search_image,
        };
        search_row.add_suffix (search_image);
        search_row.activated.connect (on_search_activated);

        var preferences_group = new Adw.PreferencesGroup () {
            valign = START,
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12,
        };
        preferences_group.add (current_location_row);
        preferences_group.add (search_row);

        var toolbar_view = new Adw.ToolbarView () {
            content = preferences_group,
        };
        toolbar_view.add_top_bar (new Adw.HeaderBar ());

        var choose_page = new Adw.NavigationPage (toolbar_view, _("Add Location"));

        navigation_view = new Adw.NavigationView ();
        navigation_view.push (choose_page);

        child = navigation_view;
        title = _("Add Location");
        content_width = 400;
        content_height = 500;
    }

    private void on_search_activated () {
        navigation_view.push (new LocationSearchPage (client));
    }
}
