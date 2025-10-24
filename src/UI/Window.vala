/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Window : Gtk.ApplicationWindow {
    public const string ACTION_PREFIX = "win.";
    public const string ACTION_SHOW_WARNING = "show-warning";

    private const ActionEntry[] ACTIONS = {
        { "add-location", add_location, },
        { "remove-location", remove_location, "s", },
        { ACTION_SHOW_WARNING, show_warning, "s", }
    };

    public Client client { get; construct; }

    private Adw.NavigationView navigation_view;
    private Gtk.SizeGroup header_bar_size_group;
    private Settings settings = new Settings ("io.github.leolost2605.emergency-alerts");

    public Window (Application application, Client client) {
        Object (
            application: application,
            client: client,
            title: _("Emergency Alerts"),
            titlebar: new Gtk.Grid () { visible = false }
        );
    }

    construct {
        header_bar_size_group = new Gtk.SizeGroup (VERTICAL);

        var home_page = new HomePage (client, header_bar_size_group);

        navigation_view = new Adw.NavigationView ();
        navigation_view.add (home_page);

        child = navigation_view;
        settings.bind ("window-width", this, "default-width", DEFAULT);
        settings.bind ("window-height", this, "default-height", DEFAULT);

        add_action_entries (ACTIONS, this);

        close_request.connect (() => {
            request_background_permission.begin ();
            return true;
        });

        client.refresh_subscribed ();
    }

    private void add_location () {
        navigation_view.push (new LocationSearchPage (client, header_bar_size_group));
    }

    private void remove_location (SimpleAction action, Variant? parameter) {
        client.unsubscribe ((string) parameter);
    }

    private void show_warning (SimpleAction action, Variant? parameter) {
        var id = (string) parameter;
        var warn  = Warning.get_by_id (id);
        if (warn != null) {
            navigation_view.push (new WarningPage (warn, header_bar_size_group));
        } else {
            warning ("Warning with ID '%s' not found.", id);
        }
    }

    private async void request_background_permission () {
        var portal = new Xdp.Portal ();

        var commandline = new GenericArray<weak string> ();
        commandline.add ("io.github.leolost2605.emergency-alerts");
        commandline.add ("--background");

        try {
            yield portal.request_background (
                null,
                _("Emergency Alerts has to run in the background in order to send notifications about incoming alerts."),
                commandline,
                AUTOSTART,
                null
            );
        } catch (Error e) {
            warning ("Failed to request background permission: %s", e.message);
        }

        destroy ();
    }
}
