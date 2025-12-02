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

        build_simple_path (path_builder);

        last_path = path_builder.to_path ();

        if (!intersects_viewport (last_path)) {
            return;
        }

        if (viewport.zoom_level > 5) {
            // We are close enough so throw away the simple path and build the exact one
            build_exact_path (path_builder);
            last_path = path_builder.to_path ();
        }

        var color = Utils.severity_to_color (warning.severity);
        snapshot.append_stroke (last_path, stroke, color);
        color.alpha = 0.3f;
        snapshot.append_fill (last_path, WINDING, color);
    }

    private bool intersects_viewport (Gsk.Path path) {
        Graphene.Rect path_bounds;
        path.get_bounds (out path_bounds);

        Graphene.Rect viewport_bounds;
        compute_bounds (this, out viewport_bounds);

        return path_bounds.intersection (viewport_bounds, null);
    }

    private void build_simple_path (Gsk.PathBuilder path_builder) {
        // We are still far away or want a fast check for intersection, so
        // use the roughest approximation of the shape
        var bounding_rect = warning.area.get_bounding_rect ();
        add_polygon (path_builder, bounding_rect);
    }

    private void build_exact_path (Gsk.PathBuilder path_builder) {
        foreach (var polygon in warning.area) {
            add_polygon (path_builder, polygon);
        }
    }

    private void add_polygon (Gsk.PathBuilder path_builder, Polygon polygon) {
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

    public override bool contains (double x, double y) {
        if (last_path == null) {
            return false;
        }

        return last_path.in_fill ({ (float) x, (float) y }, WINDING);
    }
}
