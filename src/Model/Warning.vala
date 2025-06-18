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
    public Location location { get; construct; }

    public string title { get; construct set; }

    private string _description;
    public string description {
        get {
            return _description;
        }
        set {
            _description = value.replace ("<br/>", "\n");
        }
    }

    private string? _icon_name = null;
    public string? icon_name {
        get {
            return _icon_name;
        }
        set {
            _icon_name = value;
            notify_property ("icon");
        }
    }

    public Icon? icon {
        get {
            return IconCache.get_instance ().get_icon (icon_name);
        }
    }

    public string sender { get; set; }
    public string web { get; set; }

    public string event_kind { get; set; }
    public string severity { get; set; }

    public DateTime? onset { get; set; }
    public DateTime? expires { get; set; }

    public string? time_formatted {
        owned get {
            if (onset == null || expires == null) {
                return null;
            }

            var format = Granite.DateTime.get_default_date_format (false, true, true) + " " + Granite.DateTime.get_default_time_format (false, false);
            var onset_formatted = onset.format (format);
            var expires_formatted = expires.format (format);
            return onset_formatted + " - " + expires_formatted;
        }
    }

    private string _instruction;
    public string instruction {
        get {
            return _instruction;
        }
        set {
            _instruction = value.replace ("<br/>", "\n");
        }
    }

    public string areas { get; set; }

    public Warning (string id, Location location, string title) {
        Object (
            id: id,
            location: location,
            title: title
        );
    }

    construct {
        // Maybe don't send a notification if the window is already open. But we have to make sure it doesn't get missed
        // (e.g. if the user is on another workspace, the window is behind others, etc.).
        var notification = new Notification (_("New warning for %s").printf (location.name));
        notification.set_body (title);
        GLib.Application.get_default ().send_notification (id, notification);

        notify.connect (on_notify);

        IconCache.get_instance ().icon_loaded.connect (on_icon_loaded);

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

    private void on_icon_loaded (string name) {
        if (name == icon_name) {
            notify_property ("icon");
        }
    }
}
