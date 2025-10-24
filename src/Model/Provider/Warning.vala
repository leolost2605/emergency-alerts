/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

/**
 * The class representing an alert.
 * The only properties that are required to be the same across the lifetime of this are its id and area.
 * Everything else can change.
 */
public class EmA.Warning : Object {
    public enum Category {
        GEO,
        MET,
        SAFETY,
        SECURITY,
        RESCUE,
        FIRE,
        HEALTH,
        ENVIRONMENT,
        TRANSPORT,
        INFRASTRUCTURE,
        CBRNE,
        OTHER
    }

    public enum ResponseType {
        SHELTER,
        EVACUATE,
        PREPARE,
        EXECUTE,
        AVOID,
        MONITOR,
        ASSESS,
        ALL_CLEAR,
        NONE
    }

    public enum Urgency {
        IMMEDIATE,
        EXPECTED,
        FUTURE,
        PAST,
        UNKNOWN
    }

    public enum Severity {
        EXTREME,
        SEVERE,
        MODERATE,
        MINOR,
        UNKNOWN
    }

    public enum Certainty {
        OBSERVED,
        LIKELY,
        POSSIBLE,
        UNLIKELY,
        UNKNOWN
    }

    private static HashTable<string, unowned Warning> warnings_by_id = new HashTable<string, unowned Warning> (str_hash, str_equal);

    public static Warning? get_by_id (string id) {
        if (warnings_by_id == null) {
            // We haven't constructed any warnings yet
            return null;
        }

        return warnings_by_id[id];
    }

    // Required fields at construction time that won't change

    public string id { get; construct; }
    public MultiPolygon area { get; construct; }

    // Required fields

    /**
     * Globally unique identifier of the sender of this warning.
     */
    public string sender_id { get; set; }
    public DateTime sent { get; set; }

    // Info fields

    public string event { get; set; }

    public Gee.Collection<Category> categories { get; set; }
    public Gee.Collection<ResponseType> response_types { get; set; }
    public Urgency urgency { get; set; }
    public Severity severity { get; set; }
    public Certainty certainty { get; set; }

    public DateTime effective { get; set; }

    public DateTime? onset { get; set; }
    public DateTime? end { get; set; }

    public DateTime? expires { get; set; }

    public string? sender_name { get; set; }

    public string title { get; set; }
    public string description { get; set; }

    public string? instruction { get; set; }
    public string? web { get; set; }

    // Additional fields

    public Icon? icon { get; set; }

    public string? time_formatted {
        owned get {
            if (onset == null && end == null) {
                return null;
            }

            var format = Granite.DateTime.get_default_date_format (false, true, true) + " " + Granite.DateTime.get_default_time_format (false, false);

            if (end == null) {
                return _("Since %s").printf (onset.format (format));
            }

            if (onset == null) {
                return _("Until %s").printf (end.format (format));
            }

            return onset.format (format) + " - " + end.format (format);
        }
    }

    public string areas { get; set; }

    public Warning (string id, MultiPolygon area) {
        Object (id: id, area: area);
    }

    construct {
        notify.connect (on_notify);

        warnings_by_id[id] = this;
    }

    ~Warning () {
        warnings_by_id.remove (id);
    }

    private void on_notify (ParamSpec pspec) {
        if (pspec.name == "onset" || pspec.name == "end") {
            notify_property ("time-formatted");
        }
    }
}
