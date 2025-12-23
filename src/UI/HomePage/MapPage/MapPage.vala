/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.MapPage : Adw.Bin {
    public Client client { get; construct; }

    private Shumate.SimpleMap simple_map;

    private Gee.List<WarningLayer> warning_layers;

    public MapPage (Client client) {
        Object (client: client);
    }

    construct {
        warning_layers = new Gee.LinkedList<WarningLayer> ();

        var source = new Shumate.RasterRenderer.from_url ("https://tile.openstreetmap.org/{z}/{x}/{y}.png");

        simple_map = new Shumate.SimpleMap () {
            map_source = source
        };

        var load_all_banner = new Adw.Banner (
            _("Only showing alerts for your subscribed locations or where the provider doesn't support location based fetching.")
        ) {
            button_label = _("Load All (Experimental)"),
        };
        load_all_banner.button_clicked.connect (on_load_all_clicked);
        client.bind_property ("load-all", load_all_banner, "revealed", SYNC_CREATE | INVERT_BOOLEAN);

        var toolbar_view = new Adw.ToolbarView () {
            content = simple_map
        };
        toolbar_view.add_top_bar (load_all_banner);

        child = toolbar_view;

        var gesture_controller = new Gtk.GestureClick ();
        simple_map.add_controller (gesture_controller);
        gesture_controller.released.connect (on_released);

        client.warnings.items_changed.connect (on_warnings_changed);
        on_warnings_changed (0, 0, (uint) client.warnings.get_n_items ());
    }

    private async void on_load_all_clicked () {
        var dialog = new Adw.AlertDialog (
            _("Load All Alerts?"),
            _("Loading all alerts is currently experimental and not optimized yet. It may result in a large amout of data being downloaded and degraded performance. Loading all alerts will be automatically disabled again after 3 minutes.")
        ) {
            default_response = "cancel",
        };

        dialog.add_response ("cancel", _("Cancel"));
        dialog.add_response ("load", _("Load All Alerts"));

        dialog.set_response_appearance ("load", DESTRUCTIVE);

        var response = yield dialog.choose (this, null);

        if (response == "load") {
            client.load_all = true;
        }
    }

    private void on_released (int n_press, double x, double y) {
        var warnings = new Gee.ArrayList<string> ();

        foreach (var layer in warning_layers) {
            if (layer.contains (x, y)) {
                warnings.add (layer.warning.id);
            }
        }

        if (warnings.is_empty) {
            return;
        }

        if (warnings.size == 1) {
            activate_action_variant (Window.ACTION_PREFIX + Window.ACTION_SHOW_WARNING, warnings.first ());
        } else {
            activate_action_variant (Window.ACTION_PREFIX + Window.ACTION_CHOOSE_WARNING, warnings.to_array ());
        }
    }

    private void on_warnings_changed (uint pos, uint removed, uint added) {
        for (uint i = pos; i < pos + removed; i++) {
            var layer = warning_layers.remove_at ((int) pos);
            simple_map.remove_overlay_layer (layer);
        }

        for (uint i = pos; i < pos + added; i++) {
            var warning = (Warning) client.warnings.get_item (i);

            var layer = new WarningLayer (simple_map.viewport, warning);

            warning_layers.insert ((int) i, layer);
            simple_map.add_overlay_layer (layer);
        }
    }
}
