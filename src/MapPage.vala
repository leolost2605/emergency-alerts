/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.MapPage : Adw.Bin {
    public Client client { get; construct; }

    private Shumate.SimpleMap simple_map;

    private Gee.List<Gee.List<Shumate.Layer>> warning_layers;

    public MapPage (Client client) {
        Object (client: client);
    }

    construct {
        warning_layers = new Gee.LinkedList<Gee.List<Shumate.Layer>> ();

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
            var layers = warning_layers.remove_at ((int) pos);
            foreach (var layer in layers) {
                simple_map.remove_overlay_layer (layer);
            }
        }

        for (uint i = pos; i < pos + added; i++) {
            var warning = (Warning) client.warnings.get_item (i);
            var layers = new Gee.ArrayList<Shumate.Layer> ();

            foreach (var border_ring in warning.area.get_border_rings ()) {
                var color = Gdk.RGBA ();
                color.parse ("red");
                color.alpha = 0.3f;

                var layer = new Shumate.PathLayer (simple_map.viewport) {
                    closed = true,
                    fill = true,
                    fill_color = color
                };

                foreach (var coord in border_ring) {
                    var location = new Shumate.Coordinate.full (coord.latitude, coord.longitude);
                    layer.add_node (location);
                }

                simple_map.add_overlay_layer (layer);
                layers.add (layer);
            }

            warning_layers.insert ((int) i, layers);
        }
    }
}
