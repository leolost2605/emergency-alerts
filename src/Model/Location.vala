public class EmA.Location : Object {
    public string provider_id { get; construct; }
    public string id { get; construct; }
    public string name { get; construct; }
    public ListStore warnings { get; construct; }

    public Location.from_string (string str) {
        var split = str.split ("=");

        string id, name, provider_id;
        if (split.length == 3) {
            provider_id = split[0];
            id = split[1];
            name = split[2];
        } else {
            provider_id = "unknown";
            id = "invalid id";
            name =  "Unknown Location";
            critical ("Unknown location found: %s", str);
        }

        Object (provider_id: provider_id, id: id, name: name);
    }

    public Location (string provider_id, string id, string name) {
        Object (provider_id: provider_id, id: id, name: name);
    }

    construct {
        warnings = new ListStore (typeof (Warning));
    }

    public void update_warnings (Warning[] updated_warnings) {
        warnings.splice (0, warnings.get_n_items (), updated_warnings);
    }

    public string to_string () {
        return "%s=%s=%s".printf (provider_id, id, name);
    }
}
