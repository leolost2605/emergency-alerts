/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.MultiPolygonLayer : Shumate.Layer {
    public MultiPolygon area { get; construct; }
    public Gdk.RGBA stroke_color { get; set; }
    public Gdk.RGBA fill_color { get; set; }

    private Gsk.Stroke stroke;

    public MultiPolygonLayer (Shumate.Viewport viewport, MultiPolygon area) {
        Object (viewport: viewport, area: area);
    }

    construct {
        stroke = new Gsk.Stroke (1);

        viewport.notify.connect (queue_draw);
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        var path_builder = new Gsk.PathBuilder ();

        foreach (var polygon in area) {
            double x, y;

            for (int i = 0; i < polygon.size; i++) {
                var point = polygon[i];
                viewport.location_to_widget_coords (this, point.latitude, point.longitude, out x, out y);

                if (i == 0) {
                    path_builder.move_to ((float) x, (float) y);
                } else {
                    path_builder.line_to ((float) x, (float) y);
                }
            }

            path_builder.close ();
        }

        var path = path_builder.to_path ();
        snapshot.append_fill (path, WINDING, fill_color);
        snapshot.append_stroke (path, stroke, stroke_color);
    }
}
