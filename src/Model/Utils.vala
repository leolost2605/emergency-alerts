namespace Utils {
    /**
     * Checks whether a file was already cached for uri and returns it.
     * If the file was not cached, it will be downloaded and cached.
     *
     * @param uri The URI of the file to cache
     */
    public static async File get_cached_file (string uri) {
        var esacped_uri = Uri.escape_string (uri);
        var path = Path.build_filename ("/var/tmp", esacped_uri);
        var local_file = File.new_for_path (path);

        if (!local_file.query_exists (null)) {
            var remote_file = File.new_for_uri (uri);

            try {
                yield remote_file.copy_async (local_file, FileCopyFlags.OVERWRITE, GLib.Priority.DEFAULT, null, null);
            } catch (Error e) {
                warning ("Trying to cache file: Failed to copy file: %s", e.message);
            }
        }

        return local_file;
    }
}
