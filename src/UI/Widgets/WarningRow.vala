/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.WarningRow : Gtk.ListBoxRow {
    public Warning warning { get; construct; }

    public WarningRow (Warning warning) {
        Object (warning: warning);
    }

    construct {
        var icon = new Gtk.Image () {
            icon_size = LARGE
        };
        warning.bind_property ("icon", icon, "gicon", SYNC_CREATE);

        var title_label = new Gtk.Label (null) {
            ellipsize = END,
            xalign = 0,
            single_line_mode = true
        };
        warning.bind_property ("title", title_label, "label", SYNC_CREATE);

        var description_label = new Gtk.Label (null) {
            ellipsize = END,
            xalign = 0,
            single_line_mode = true
        };
        description_label.add_css_class ("dimmed");
        warning.bind_property ("description", description_label, "label", SYNC_CREATE);

        warning.notify["description"].connect (() => description_label.visible = warning.description != null);
        description_label.visible = warning.description != null;

        var grid = new Gtk.Grid () {
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6,
            row_spacing = 3,
            column_spacing = 9
        };
        grid.attach (icon, 0, 0, 1, 2);
        grid.attach (title_label, 1, 0);
        grid.attach (description_label, 1, 1);

        child = grid;
        height_request = 32;
    }
}
