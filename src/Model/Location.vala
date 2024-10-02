public class Ema.Location : Object {
    public string id { get; construct; }
    public string name { get; construct; }
    public ListStore warnings { get; construct; }

    public Location.from_string (string str) {
        var split = str.split ("=");

        string id, name;
        if (split.length == 2) {
            id = split[0];
            name = split[1];
        } else {
            id = "invalid id";
            name =  "Unknown Location";
            critical ("Unknown location found: %s", str);
        }

        Object (id: id, name: name);
    }

    public Location (string id, string name) {
        Object (id: id, name: name);
    }

    construct {
        warnings = new ListStore (typeof (Warning));
    }

    public void update_warnings (Warning[] updated_warnings) {
        warnings.splice (0, warnings.get_n_items (), updated_warnings);
    }

    public string to_string () {
        return "%s=%s".printf (id, name);
    }
}
