/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.LocationBox : Gtk.Box {
    public Location location { get; construct; }

    private Gtk.Stack stack;

    public LocationBox (Location location) {
        Object (location: location);
    }

    construct {
        var menu = new Menu ();
        menu.append (_("Remove"), Action.print_detailed_name ("win.remove-location", location.id));

        var edit_popover = new Gtk.PopoverMenu.from_model (menu);

        var label = new Gtk.Label ("<b>" + Markup.escape_text (location.name) + "</b>") {
            ellipsize = MIDDLE,
            xalign = 0,
            use_markup = true,
            hexpand = true
        };

        var header_button = new Gtk.MenuButton () {
            child = label,
            popover = edit_popover,
            halign = START
        };
        header_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        var placeholder = new Gtk.Label (_("No warnings for %s.").printf (location.name)) {
            margin_top = 12,
            margin_bottom = 12
        };

        var list_box = new Gtk.ListBox () {
            hexpand = true,
            activate_on_single_click = true,
            valign = START,
            selection_mode = NONE
        };
        list_box.add_css_class ("content");
        list_box.add_css_class ("boxed-list");
        list_box.add_css_class (Granite.STYLE_CLASS_RICH_LIST);

        stack = new Gtk.Stack ();
        stack.add_named (placeholder, "placeholder");
        stack.add_named (list_box, "list");

        orientation = VERTICAL;
        spacing = 3;
        append (header_button);
        append (stack);

        location.items_changed.connect (on_items_changed);
        on_items_changed ();

        list_box.bind_model (location, create_widget_func);
    }

    private Gtk.Widget create_widget_func (Object obj) {
        var warning = (Warning) obj;

        var icon = new Gtk.Image () {
            icon_size = LARGE
        };
        warning.bind_property ("icon", icon, "gicon", SYNC_CREATE);

        var title_label = new Gtk.Label (warning.title) {
            ellipsize = END,
            xalign = 0,
            single_line_mode = true
        };

        var description_label = new Gtk.Label (null) {
            ellipsize = END,
            xalign = 0,
            single_line_mode = true
        };
        description_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

        warning.bind_property ("description", description_label, "label", SYNC_CREATE);
        warning.notify["description"].connect (() => description_label.visible = warning.description != null);
        description_label.visible = warning.description != null;

        var grid = new Gtk.Grid () {
            margin_top = 3,
            margin_bottom = 3,
            margin_start = 3,
            margin_end = 3,
            row_spacing = 3,
            column_spacing = 9
        };
        grid.attach (icon, 0, 0, 1, 2);
        grid.attach (title_label, 1, 0);
        grid.attach (description_label, 1, 1);

        return new Gtk.ListBoxRow () {
            child = grid,
            action_name = Window.ACTION_PREFIX + Window.ACTION_SHOW_WARNING,
            action_target = warning.id
        };
    }

    private void on_items_changed () {
        if (location.get_n_items () == 0) {
            stack.set_visible_child_name ("placeholder");
        } else {
            stack.set_visible_child_name ("list");
        }
    }
}
