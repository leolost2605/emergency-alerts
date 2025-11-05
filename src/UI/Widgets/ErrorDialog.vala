/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.ErrorDialog : Adw.Dialog {
    public string affected_locations { get; construct; }
    public string error_message { get; construct; }

    public ErrorDialog (string affected_locations, string error_message) {
        Object (affected_locations: affected_locations, error_message: error_message);
    }

    construct {
        var header_label = new Gtk.Label (_("An error occured while refreshing alerts for the following locations: %s").printf (affected_locations)) {
            wrap = true,
            wrap_mode = WORD_CHAR
        };
        header_label.add_css_class ("heading");

        var description_label = new Gtk.Label (error_message) {
            wrap = true,
            wrap_mode = WORD_CHAR
        };

        var box = new Gtk.Box (VERTICAL, 12) {
            margin_start = 12,
            margin_end = 12,
            margin_bottom = 12
        };
        box.append (header_label);
        box.append (description_label);

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = box,
            propagate_natural_height = true,
            hscrollbar_policy = NEVER
        };

        var toolbar_view = new Adw.ToolbarView () {
            content = scrolled_window
        };
        toolbar_view.add_top_bar (new Adw.HeaderBar ());

        child = toolbar_view;
        title = _("Error");
        content_width = 400;
    }
}
