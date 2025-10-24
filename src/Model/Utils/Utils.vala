/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

namespace EmA.Utils {
    private static Soup.Session session;

    public static void init () {
        session = new Soup.Session ();
    }

    public static Soup.Session get_session () {
        return session;
    }

    /**
     * Checks whether a file was already cached for uri and returns it.
     * If the file was not cached, it will be downloaded and cached.
     *
     * @param uri The URI of the file to cache
     * @param use_remote If false we wait for the file to be downloaded,
     * if true we return the remote file and download in the background
     */
    public static async File get_file (string uri) {
        var esacped_uri = Uri.escape_string (uri);
        var path = Path.build_filename ("/var/tmp", esacped_uri);
        var local_file = File.new_for_path (path);

        if (!local_file.query_exists (null)) {
            var message = new Soup.Message ("GET", uri);

            InputStream input_stream;
            try {
                input_stream = yield session.send_async (message, Priority.DEFAULT, null);
            } catch (Error e) {
                warning ("Failed to get data: %s", e.message);
                return local_file;
            }

            IOStream file_io_stream;
            try {
                file_io_stream = yield local_file.replace_readwrite_async (null, false, NONE);
            } catch (Error e) {
                warning ("Failed to create local file: %s", e.message);
                return local_file;
            }

            try {
                yield file_io_stream.output_stream.splice_async (input_stream, CLOSE_TARGET | CLOSE_SOURCE);
            } catch (Error e) {
                warning ("Failed to write to local file: %s", e.message);
            }
        }

        return local_file;
    }

    /**
     * This method parses the GeoJSON and tries to merge all geometries it finds into a single MultiPolygon.
     */
    public async MultiPolygon parse_and_merge_to_multipolygon (Json.Object object) throws Error {
        var parsed = yield GeoJSON.parse_object (object);
        return merge_to_multipolygon (parsed);
    }

    /**
     * This method tries to extract as many geometries as possible from a parsed GeoJSON object
     * and merges them into a single MultiPolygon.
     */
    public MultiPolygon merge_to_multipolygon (Object parsed) throws Error {
        if (parsed is MultiPolygon) {
            return (MultiPolygon) parsed;
        }

        if (parsed is Polygon) {
            return new MultiPolygon.from_polygons ({ (Polygon) parsed });
        }

        if (parsed is GeoJSON.Feature) {
            var feature = (GeoJSON.Feature) parsed;
            return merge_to_multipolygon (feature.geometry);
        }

        if (parsed is Gee.List) {
            var feature_collection = (Gee.List<GeoJSON.Feature>) parsed;
            var result = new MultiPolygon ();
            foreach (var feature in feature_collection) {
                result.merge (merge_to_multipolygon (feature.geometry));
            }
            return result;
        }

        throw new IOError.INVALID_ARGUMENT ("Could not extract Area from object of type %s".printf (parsed.get_type ().name ()));
    }
}
