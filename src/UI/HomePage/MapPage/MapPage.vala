/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.MapPage : Adw.Bin {
    public Client client { get; construct; }

    private Shumate.SimpleMap simple_map;

    private Gee.List<MultiPolygonLayer> warning_layers;

    public MapPage (Client client) {
        Object (client: client);
    }

    construct {
        warning_layers = new Gee.LinkedList<MultiPolygonLayer> ();

        var source = new Shumate.RasterRenderer.from_url ("https://tile.openstreetmap.org/{z}/{x}/{y}.png");

        simple_map = new Shumate.SimpleMap () {
            map_source = source
        };

        child = simple_map;

        client.warnings.items_changed.connect (on_warnings_changed);
        on_warnings_changed (0, 0, (uint) client.warnings.get_n_items ());
    }

    private void on_warnings_changed (uint pos, uint removed, uint added) {
        for (uint i = pos; i < pos + removed; i++) {
            var layer = warning_layers.remove_at ((int) pos);
            simple_map.remove_overlay_layer (layer);
        }

        for (uint i = pos; i < pos + added; i++) {
            var warning = (Warning) client.warnings.get_item (i);

            var layer = new MultiPolygonLayer (simple_map.viewport, warning.area);
            warning.bind_property ("severity", layer, "stroke-color", SYNC_CREATE, transform_severity_to_color);
            warning.bind_property ("severity", layer, "fill-color", SYNC_CREATE, transform_severity_to_fill_color);

            warning_layers.insert ((int) i, layer);
            simple_map.add_overlay_layer (layer);
        }
    }

    private static bool transform_severity_to_color (Binding binding, Value from_val, ref Value to_val) {
        var color = Utils.severity_to_color (from_val.get_enum ());
        to_val.set_boxed (&color);
        return true;
    }

    private static bool transform_severity_to_fill_color (Binding binding, Value from_val, ref Value to_val) {
        var color = Utils.severity_to_color (from_val.get_enum ());
        color.alpha = 0.3f;
        to_val.set_boxed (&color);
        return true;
    }
}
