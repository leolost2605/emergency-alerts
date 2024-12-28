/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

namespace Utils {
    /**
     * Checks whether a file was already cached for uri and returns it.
     * If the file was not cached, it will be downloaded and cached.
     *
     * @param uri The URI of the file to cache
     * @param use_remote If false we wait for the file to be downloaded,
     * if true we return the remote file and download in the background
     */
    public static async File get_file (string uri, bool use_remote) {
        var esacped_uri = Uri.escape_string (uri);
        var path = Path.build_filename ("/var/tmp", esacped_uri);
        var local_file = File.new_for_path (path);

        if (!local_file.query_exists (null)) {
            var remote_file = File.new_for_uri (uri);

            if (use_remote) {
                copy_or_warn.begin (remote_file, local_file);
                return remote_file;
            } else {
                yield copy_or_warn (remote_file, local_file);
            }
        }

        return local_file;
    }

    private static async void copy_or_warn (File source, File destination) {
        try {
            yield source.copy_async (destination, FileCopyFlags.OVERWRITE, GLib.Priority.DEFAULT, null, null);
        } catch (Error e) {
            warning ("Failed to copy file: %s", e.message);
        }
    }
}
