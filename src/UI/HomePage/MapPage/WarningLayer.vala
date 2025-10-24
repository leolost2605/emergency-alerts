/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.WarningLayer : Shumate.Layer {
    public Warning warning { get; construct; }

    private Gsk.Stroke stroke;

    private Gsk.Path? last_path;

    public WarningLayer (Shumate.Viewport viewport, Warning warning) {
        Object (viewport: viewport, warning: warning);
    }

    construct {
        stroke = new Gsk.Stroke (1);

        viewport.notify.connect (queue_draw);

        set_cursor_from_name ("default");
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        var path_builder = new Gsk.PathBuilder ();

        foreach (var polygon in warning.area) {
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

        last_path = path_builder.to_path ();

        var color = Utils.severity_to_color (warning.severity);
        snapshot.append_stroke (last_path, stroke, color);
        color.alpha = 0.3f;
        snapshot.append_fill (last_path, WINDING, color);
    }

    public override bool contains (double x, double y) {
        if (last_path == null) {
            return false;
        }

        return last_path.in_fill ({ (float) x, (float) y }, WINDING);
    }
}
