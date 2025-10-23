/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Warning : Object {
    private static HashTable<string, unowned Warning> warnings_by_id = new HashTable<string, unowned Warning> (str_hash, str_equal);

    public static Warning? get_by_id (string id) {
        return warnings_by_id[id];
    }

    public string id { get; construct; }
    public MultiPolygon area { get; construct; }
    public string title { get; construct set; }

    public string description { get; set; }

    public Icon? icon { get; set; }

    public string sender { get; set; }
    public string web { get; set; }

    public string event_kind { get; set; }
    public string severity { get; set; }

    public DateTime? onset { get; set; }
    public DateTime? expires { get; set; }

    public string? time_formatted {
        owned get {
            if (onset == null && expires == null) {
                return null;
            }

            var format = Granite.DateTime.get_default_date_format (false, true, true) + " " + Granite.DateTime.get_default_time_format (false, false);

            if (expires == null) {
                return _("Since %s").printf (onset.format (format));
            }

            if (onset == null) {
                return _("Until %s").printf (expires.format (format));
            }

            return onset.format (format) + " - " + expires.format (format);
        }
    }

    public string instruction { get; set; }

    public string areas { get; set; }

    public Warning (string id, MultiPolygon area, string title) {
        Object (id: id, area: area, title: title);
    }

    construct {
        notify.connect (on_notify);

        warnings_by_id[id] = this;
    }

    ~Warning () {
        warnings_by_id.remove (id);
    }

    private void on_notify (ParamSpec pspec) {
        if (pspec.name == "onset" || pspec.name == "expires") {
            notify_property ("time-formatted");
        }
    }
}
