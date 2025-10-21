/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.LocationRow : Adw.Bin {
    private Gtk.Label name_label;
    private Gtk.Label country_label;

    construct {
        name_label = new Gtk.Label (null) {
            halign = START
        };

        country_label = new Gtk.Label (null) {
            halign = START
        };
        country_label.add_css_class ("dimmed");
        country_label.add_css_class ("caption");

        var box = new Gtk.Box (VERTICAL, 0);
        box.append (name_label);
        box.append (country_label);

        child = box;
    }

    public void bind (Location location) {
        name_label.label = location.name;
        country_label.label = location.country;
    }
}
