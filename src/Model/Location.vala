public class Ema.Location : Object {
    public string id { get; construct; }
    public string name { get; construct; }
    public ListStore warnings { get; construct; }

    private GenericSet<string> warning_ids;

    public Location (string id, string name) {
        Object (id: id, name: name);
    }

    construct {
        warnings = new ListStore (typeof (Warning));
        warning_ids = new GenericSet<string> (str_hash, str_equal);
    }

    public void append (Warning warning) {
        if (warning.id in warning_ids) {
            return;
        }

        warning_ids.add (warning.id);
        warnings.append (warning);
    }
}
