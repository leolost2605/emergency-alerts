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

    public async void register_remote_icon (string name, File remote_file) {
        if (name in icons) {
            return;
        }

        icons[name] = null;

        var path = Path.build_filename ("/var/tmp", remote_file.get_basename ());
        var local_file = File.new_for_path (path);

        if (!local_file.query_exists (null)) {
            try {
                yield remote_file.copy_async (local_file, FileCopyFlags.OVERWRITE, GLib.Priority.DEFAULT, null, null);
            } catch (Error e) {
                if (!(e is IOError.CANCELLED)) {
                    warning ("Trying to get icon: Failed to copy file: %s", e.message);
                }
                return;
            }
        }

        icons[name] = new FileIcon (local_file);

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
