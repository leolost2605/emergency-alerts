public class EmA.Warning : Object {
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
        var notification = new Notification (_("New warning for %s").printf (location.name));
        notification.set_body (title);
        GLib.Application.get_default ().send_notification (id, notification);

        notify.connect ((pspec) => {
            if (pspec.name == "onset" || pspec.name == "expires") {
                notify_property ("time-formatted");
            }
        });
    }
}
