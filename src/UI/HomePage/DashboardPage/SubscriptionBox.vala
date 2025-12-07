/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.SubscriptionBox : Gtk.Box {
    public Subscription subscription { get; construct; }

    private Gtk.Stack stack;

    public SubscriptionBox (Subscription subscription) {
        Object (subscription: subscription);
    }

    construct {
        var menu = new Menu ();
        menu.append (_("Remove"), Action.print_detailed_name ("win.remove-location", subscription.location.id));

        var edit_popover = new Gtk.PopoverMenu.from_model (menu);

        var label = new Gtk.Label (subscription.location.name) {
            ellipsize = END,
            xalign = 0
        };
        label.add_css_class ("heading");

        var country_label = new Gtk.Label (subscription.location.description) {
            ellipsize = END,
            xalign = 0
        };
        country_label.add_css_class ("dimmed");
        country_label.add_css_class ("caption");

        var header_box = new Gtk.Box (VERTICAL, 0);
        header_box.append (label);
        header_box.append (country_label);

        var header_button = new Gtk.MenuButton () {
            child = header_box,
            popover = edit_popover,
            halign = START
        };
        header_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        var placeholder = new Gtk.Label (_("No warnings for %s.").printf (subscription.location.name)) {
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
        list_box.bind_model (subscription.warnings, create_widget_func);

        stack = new Gtk.Stack ();
        stack.add_named (placeholder, "placeholder");
        stack.add_named (list_box, "list");

        orientation = VERTICAL;
        spacing = 3;
        append (header_button);
        append (stack);

        subscription.warnings.items_changed.connect (on_items_changed);
        on_items_changed ();
    }

    private Gtk.Widget create_widget_func (Object obj) {
        var warning = (Warning) obj;

        return new WarningRow (warning) {
            action_name = Window.ACTION_PREFIX + Window.ACTION_SHOW_WARNING,
            action_target = warning.id
        };
    }

    private void on_items_changed () {
        if (subscription.warnings.get_n_items () == 0) {
            stack.set_visible_child_name ("placeholder");
        } else {
            stack.set_visible_child_name ("list");
        }
    }
}
