public class EmA.WarningPage : Adw.NavigationPage {
    public Warning warning { get; construct; }
    public Gtk.SizeGroup header_bar_size_group { get; construct; }

    private Granite.HeaderLabel header_label;

    public WarningPage (Warning warning, Gtk.SizeGroup header_bar_size_group) {
        Object (warning: warning, header_bar_size_group: header_bar_size_group);
    }

    construct {
        var header_bar = new Adw.HeaderBar () {
            show_title = false
        };
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

        header_bar_size_group.add_widget (header_bar);

#if ADWAITA
        var banner = new Adw.Banner ("") {
            revealed = true
        };
        warning.bind_property ("event-kind", banner, "title", SYNC_CREATE);
#else
        var banner_label = new Gtk.Label (null);
        warning.bind_property ("event-kind", banner_label, "label", SYNC_CREATE);

        var banner = new Gtk.InfoBar () {
            revealed = true,
            message_type = WARNING
        };
        banner.add_child (banner_label);
        banner.add_css_class (Granite.STYLE_CLASS_FRAME);
#endif

        header_label = new Granite.HeaderLabel (warning.title);

        update_title ();
        warning.notify["onset"].connect (update_title);
        warning.notify["expires"].connect (update_title);

        var description = new Gtk.Label (null) {
            wrap = true,
            halign = START,
            xalign = 0
        };
        warning.bind_property ("description", description, "label", SYNC_CREATE);

        var content_box = new Gtk.Box (VERTICAL, 12) {
            margin_start = 12,
            margin_end = 12,
        };
        content_box.append (header_label);
        content_box.append (description);

        var content_clamp = new Adw.Clamp () {
            child = content_box,
            maximum_size = 700,
            tightening_threshold = 500
        };

        var instruction = new FactsRow (_("Instructions:"), warning, "instruction");
        var areas = new FactsRow (_("Affected Regions:"), warning, "areas");
        var sender = new FactsRow (_("Published by:"), warning, "sender");
        var more_info = new FactsRow (_("More Information:"), warning, "web");

        var facts_list = new Gtk.ListBox () {
            margin_start = 12,
            margin_end = 12,
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

        var facts_clamp = new Adw.Clamp () {
            child = facts_list,
            maximum_size = 700,
            tightening_threshold = 500
        };

        warning.notify.connect_after (() => facts_list.visible = facts_list.get_row_at_index (0).visible);
        facts_list.visible = facts_list.get_row_at_index (0).visible;

        var box = new Gtk.Box (VERTICAL, 12) {
            margin_bottom = 12,
            margin_top = 6
        };
        box.append (banner);
        box.append (content_clamp);
        box.append (new Gtk.Separator (HORIZONTAL));
        box.append (facts_clamp);

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
                wrap = true,
                use_markup = true,
            };
            content_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
            content_label.add_css_class ("negative-margin");

            var box = new Gtk.Box (VERTICAL, 0);
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
