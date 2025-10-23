/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.WarningLayer : Object {
    public Shumate.SimpleMap map { get; construct; }
    public Warning warning { get; construct; }

    private Gee.List<Shumate.Layer> sub_layers;

    public WarningLayer (Shumate.SimpleMap map, Warning warning) {
        Object (map: map, warning: warning);
    }

    construct {
        sub_layers = new Gee.ArrayList<Shumate.Layer> ();

        warning.notify["area"].connect (update_layers);
        update_layers ();
    }

    ~WarningLayer () {
        foreach (var layer in sub_layers) {
            map.remove_overlay_layer (layer);
        }
    }

    private void update_layers () {
        foreach (var layer in sub_layers) {
            map.remove_overlay_layer (layer);
        }

        sub_layers.clear ();

        if (warning.area == null) {
            return;
        }


        foreach (var polygon in warning.area.polygons) {
            var color = Gdk.RGBA ();
            color.parse ("red");
            color.alpha = 0.3f;

            var layer = new Shumate.PathLayer (map.viewport) {
                closed = true,
                fill = true,
                fill_color = color
            };

            foreach (var coord in polygon) {
                var location = new Shumate.Coordinate.full (coord.latitude, coord.longitude);
                layer.add_node (location);
            }
            map.add_overlay_layer (layer);
            sub_layers.add (layer);
        }
    }
}
