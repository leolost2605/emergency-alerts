public class Ema.Warning : Object {
    public string id { get; construct; }

    public string title { get; set; }

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

    public DateTime onset { get; set; }
    public DateTime expires { get; set; }

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

    public Warning (string id, string title) {
        Object (
            id: id,
            title: title
        );
    }
}
