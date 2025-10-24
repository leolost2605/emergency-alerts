/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.WarningChooserDialog : Adw.Dialog {
    public ListModel warnings { get; construct; }

    public WarningChooserDialog (ListModel warnings) {
        Object (warnings: warnings);
    }

    construct {
        var list_box = new Gtk.ListBox () {
            show_separators = true,
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12,
            selection_mode = NONE,
            activate_on_single_click = true
        };
        list_box.add_css_class ("boxed-list");
        list_box.bind_model (warnings, widget_create_func);
        list_box.row_activated.connect (on_row_activated);

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = list_box,
            propagate_natural_height = true,
        };

        var toolbar_view = new Adw.ToolbarView () {
            content = scrolled_window
        };
        toolbar_view.add_top_bar (new Adw.HeaderBar ());

        child = toolbar_view;
        title = _("Choose an Alert…");
        content_width = 400;
    }

    private Gtk.Widget widget_create_func (Object obj) {
        var warning = (Warning) obj;

        return new WarningRow (warning);
    }

    private void on_row_activated (Gtk.ListBoxRow row) {
        var warning = (Warning) warnings.get_item (row.get_index ());
        activate_action_variant (Window.ACTION_PREFIX + Window.ACTION_SHOW_WARNING, warning.id);
        close ();
    }
}
