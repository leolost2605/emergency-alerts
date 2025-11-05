/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Window : Adw.ApplicationWindow {
    public const string ACTION_PREFIX = "win.";
    public const string ACTION_SHOW_WARNING = "show-warning";
    public const string ACTION_CHOOSE_WARNING = "choose-warning";
    private const string ACTION_SHOW_ERROR_DETAILS = "show-error-details";

    private const ActionEntry[] ACTIONS = {
        { "add-location", add_location, },
        { "remove-location", remove_location, "s", },
        { ACTION_SHOW_WARNING, show_warning, "s", },
        { ACTION_CHOOSE_WARNING, choose_warning, "as", },
        { ACTION_SHOW_ERROR_DETAILS, show_error_details, "(ss)", },
    };

    public Client client { get; construct; }

    private Adw.ToastOverlay error_overlay;
    private Adw.NavigationView navigation_view;
    private Settings settings = new Settings ("io.github.leolost2605.emergency-alerts");

    public Window (Application application, Client client) {
        Object (
            application: application,
            client: client,
            title: _("Emergency Alerts")
        );
    }

    construct {
        var home_page = new HomePage (client);

        navigation_view = new Adw.NavigationView ();
        navigation_view.add (home_page);

        error_overlay = new Adw.ToastOverlay () {
            child = navigation_view
        };

        content = error_overlay;
        settings.bind ("window-width", this, "default-width", DEFAULT);
        settings.bind ("window-height", this, "default-height", DEFAULT);

        add_action_entries (ACTIONS, this);

        close_request.connect (() => {
            request_background_permission.begin ();
            return true;
        });

        Log.get_instance ().error_reported.connect (show_error_toast);

        client.refresh_subscribed ();
    }

    private void show_error_toast (string affected_locations, string error_message) {
        var toast = new Adw.Toast ("An error occurred while refreshing %s".printf (affected_locations)) {
            button_label = _("Details"),
            /* 30 seconds is a good value to allow users to get details but also to not stack up too much
             * especially since we probably have refreshed again after 30 seconds resulting in the same error
             * and a toast for it if it still applies
             */
            timeout = 30,
            action_name = Window.ACTION_PREFIX + Window.ACTION_SHOW_ERROR_DETAILS,
            action_target = new Variant.tuple ({
                new Variant.string (affected_locations),
                new Variant.string (error_message)
            }),
        };
        error_overlay.add_toast (toast);
    }

    private void add_location () {
        navigation_view.push (new LocationSearchPage (client));
    }

    private void remove_location (SimpleAction action, Variant? parameter) {
        client.unsubscribe ((string) parameter);
    }

    private void show_warning (SimpleAction action, Variant? parameter) {
        var id = (string) parameter;
        var warn  = Warning.get_by_id (id);
        if (warn != null) {
            navigation_view.push (new WarningPage (warn));
        } else {
            warning ("Warning with ID '%s' not found.", id);
        }
    }

    private void choose_warning (SimpleAction action, Variant? parameter) {
        var ids = (string[]) parameter;

        var warnings = new ListStore (typeof (Warning));

        foreach (var id in ids) {
            var warn = Warning.get_by_id (id);

            if (warn != null) {
                warnings.append (warn);
            } else {
                warning ("Warning with ID '%s' not found.", id);
            }
        }

        var dialog = new WarningChooserDialog (warnings);
        dialog.present (this);
    }

    private void show_error_details (SimpleAction action, Variant? parameter) {
        var affected_locations = parameter.get_child_value (0).get_string ();
        var error_message = parameter.get_child_value (1).get_string ();

        new ErrorDialog (affected_locations, error_message).present (this);
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
