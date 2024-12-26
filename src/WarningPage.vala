public class EmA.WarningPage : Adw.NavigationPage {
    public Warning warning { get; construct; }

    private Granite.HeaderLabel header_label;

    public WarningPage (Warning warning) {
        Object (warning: warning);
    }

    construct {
        var header_bar = new Adw.HeaderBar () {
            show_title = false
        };
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

        header_label = new Granite.HeaderLabel (warning.title);

        update_title ();
        warning.notify["onset"].connect (update_title);
        warning.notify["expires"].connect (update_title);

        var banner_label = new Gtk.Label (null);
        warning.bind_property ("event-kind", banner_label, "label", SYNC_CREATE);

        var banner = new Gtk.InfoBar () {
            revealed = true,
            message_type = WARNING
        };
        banner.add_child (banner_label);
        banner.add_css_class (Granite.STYLE_CLASS_FRAME);

        var description = new Gtk.Label (null) {
            wrap = true
        };
        warning.bind_property ("description", description, "label", SYNC_CREATE);

        var instruction = new FactsRow (_("Instructions:"), warning, "instruction");
        var areas = new FactsRow (_("Affected Regions:"), warning, "areas");
        var sender = new FactsRow (_("Published by:"), warning, "sender");
        var more_info = new FactsRow (_("More Information:"), warning, "web");

        var facts_list = new Gtk.ListBox () {
            show_separators = true,
            hexpand = true,
            activate_on_single_click = false,
            valign = START,
            selection_mode = NONE
        };
        facts_list.add_css_class ("boxed-list");
        facts_list.add_css_class (Granite.STYLE_CLASS_RICH_LIST);
        facts_list.append (instruction);
        facts_list.append (areas);
        facts_list.append (sender);
        facts_list.append (more_info);

        warning.notify.connect_after (() => facts_list.visible = facts_list.get_row_at_index (0).visible);
        facts_list.visible = facts_list.get_row_at_index (0).visible;

        var box = new Gtk.Box (VERTICAL, 6) {
            margin_start = 12,
            margin_end = 12,
            margin_bottom = 12,
            margin_top = 6
        };
        box.append (header_label);
        box.append (banner);
        box.append (description);
        box.append (facts_list);

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = box,
            hexpand = true,
            vexpand = true
        };

        var top_box = new Gtk.Box (VERTICAL, 0);
        top_box.append (header_bar);
        top_box.append (scrolled_window);

        child = top_box;
        title = warning.title;
    }

    private void update_title () {
        if (warning.onset == null || warning.expires == null) {
            header_label.secondary_text = null;
            return;
        }

        var format = Granite.DateTime.get_default_date_format (false, true, true) + " " + Granite.DateTime.get_default_time_format (false, false);
        var onset_formatted = warning.onset.format (format);
        var expires_formatted = warning.expires.format (format);
        header_label.secondary_text = onset_formatted + " - " + expires_formatted;
    }

    private class FactsRow : Gtk.ListBoxRow {
        public string title { get; construct; }
        public Warning warning { get; construct; }
        public string property { get; construct; }

        public FactsRow (string title, Warning warning, string property) {
            Object (
                title: title,
                warning: warning,
                property: property
            );
        }

        construct {
            var header_label = new Gtk.Label ("<b>" + title + "</b>") {
                use_markup = true,
                xalign = 0,
                wrap = true
            };

            var content_label = new Gtk.Label (null) {
                xalign = 0,
                wrap = true
            };
            content_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

            var box = new Gtk.Box (VERTICAL, 3);
            box.append (header_label);
            box.append (content_label);

            warning.bind_property (property, content_label, "label", SYNC_CREATE);
            warning.notify[property].connect (update_visible);
            update_visible ();

            child = box;
        }

        private void update_visible () {
            string? prop;
            warning.get (property, out prop);
            visible = prop != null;
        }
    }
}
