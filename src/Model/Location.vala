public class Location : Object {
    public string id { get; construct; }
    public string name { get; construct; }

    public Location (string id, string name) {
        Object (id: id, name: name);
    }
}
