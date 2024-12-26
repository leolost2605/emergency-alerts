public class EmA.LocationBox : Gtk.Box {
    public signal void show_details (Warning warning);

    public Location location { get; construct; }

    public LocationBox (Location location) {
        Object (location: location);
    }

    construct {
        var label = new Gtk.Label ("<b>" + Markup.escape_text (location.name) + "</b>") {
            ellipsize = MIDDLE,
            xalign = 0,
            use_markup = true,
            hexpand = true
        };

        var menu = new Menu ();
        menu.append (_("Remove"), Action.print_detailed_name ("win.remove-location", location.id));

        var edit_popover = new Gtk.PopoverMenu.from_model (menu);

        var edit_button = new Gtk.MenuButton () {
            icon_name = "edit-symbolic",
            popover = edit_popover
        };

        var header_box = new Gtk.Box (HORIZONTAL, 6);
        header_box.append (label);
        header_box.append (edit_button);

        var list_box = new Gtk.ListBox () {
            show_separators = true,
            hexpand = true,
            activate_on_single_click = true,
            valign = START
        };
        list_box.add_css_class ("boxed-list");
        list_box.add_css_class (Granite.STYLE_CLASS_RICH_LIST);

        var placeholder = new Gtk.Label (_("No warnings for %s.").printf (location.name)) {
            margin_top = 12,
            margin_bottom = 12
        };

        list_box.set_placeholder (placeholder);

        orientation = VERTICAL;
        spacing = 3;
        margin_end = 12;
        margin_start = 12;
        append (header_box);
        append (list_box);

        list_box.bind_model (location.warnings, create_widget_func);

        list_box.row_activated.connect ((row) => {
            show_details ((Warning) location.warnings.get_item (row.get_index ()));
        });
    }

    private Gtk.Widget create_widget_func (Object obj) {
        var warning = (Warning) obj;

        var title_label = new Gtk.Label (warning.title) {
            wrap = true,
            xalign = 0
        };

        var description_label = new Gtk.Label (null) {
            wrap = true,
            xalign = 0
        };
        description_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

        warning.bind_property ("time-formatted", description_label, "label", SYNC_CREATE);
        warning.notify["time-formatted"].connect (() => description_label.visible = warning.time_formatted != null);
        description_label.visible = warning.time_formatted != null;

        var box = new Gtk.Box (VERTICAL, 3);
        box.append (title_label);
        box.append (description_label);

        return box;
    }
}
