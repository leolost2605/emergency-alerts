public class EmA.IconCache : Object {
    private static IconCache? _instance = null;
    public static IconCache get_instance () {
        if (_instance == null) {
            _instance = new IconCache ();
        }

        return _instance;
    }

    public signal void icon_loaded (string name);

    private HashTable<string, FileIcon?> icons = new HashTable<string, FileIcon> (str_hash, str_equal);

    public async void register_remote_icon (string name, string uri) {
        if (name in icons) {
            return;
        }

        // Prevent multiple registers for the same icon while we're loading it
        icons[name] = null;

        var file = yield Utils.get_cached_file (uri);

        icons[name] = new FileIcon (file);

        icon_loaded (name);
    }

    public unowned Icon? get_icon (string? name) {
        if (name == null) {
            return null;
        }

        if (name in icons) {
            return icons[name];
        }

        return null;
    }
}
