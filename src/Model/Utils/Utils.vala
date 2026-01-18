/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

namespace EmA.Utils {
    private static Soup.Session session;
    private static Gdk.RGBA[] severity_colors;
    private static Xdp.Portal portal;

    public static void init () {
        session = new Soup.Session () {
            user_agent = "Emergency Alerts App" // Required at least for US weather.gov API
        };

        severity_colors = new Gdk.RGBA[Warning.Severity.UNKNOWN + 1];
        severity_colors[Warning.Severity.EXTREME] = Gdk.RGBA ();
        severity_colors[Warning.Severity.EXTREME].parse ("purple");
        severity_colors[Warning.Severity.SEVERE] = Gdk.RGBA ();
        severity_colors[Warning.Severity.SEVERE].parse ("red");
        severity_colors[Warning.Severity.MODERATE] = Gdk.RGBA ();
        severity_colors[Warning.Severity.MODERATE].parse ("orange");
        severity_colors[Warning.Severity.MINOR] = Gdk.RGBA ();
        severity_colors[Warning.Severity.MINOR].parse ("orange");
        severity_colors[Warning.Severity.UNKNOWN] = Gdk.RGBA ();
        severity_colors[Warning.Severity.UNKNOWN].parse ("yellow");

        portal = new Xdp.Portal ();
    }

    public static Soup.Session get_session () {
        return session;
    }

    public static Xdp.Portal get_portal () {
        return portal;
    }

    public static async Json.Node get_json (string uri) throws Error {
        var message = new Soup.Message ("GET", uri);

        var input_stream = yield session.send_async (message, Priority.DEFAULT, null);

        var parser = new Json.Parser ();
        yield parser.load_from_stream_async (input_stream);

        if (parser.get_root () == null) {
            throw new IOError.FAILED ("Failed to parse server response");
        }

        return parser.get_root ();
    }

    /**
     * Checks whether a file was already cached for uri and returns it.
     * If the file was not cached, it will be downloaded and cached.
     *
     * @param uri The URI of the file to cache
     */
    public static async File get_file (string uri) {
        var esacped_uri = Uri.escape_string (uri);
        var path = Path.build_filename (Environment.get_user_cache_dir (), esacped_uri);
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
            var list = (Gee.List<Object>) parsed;
            var result = new MultiPolygon ();
            foreach (var obj in list) {
                result.merge (merge_to_multipolygon (obj));
            }
            return result;
        }

        throw new IOError.INVALID_ARGUMENT ("Could not extract Area from object of type %s".printf (parsed.get_type ().name ()));
    }

    public Gdk.RGBA severity_to_color (Warning.Severity severity) {
        if (severity < 0 || severity >= severity_colors.length) {
            return severity_colors[Warning.Severity.UNKNOWN];
        }
        return severity_colors[severity];
    }

    public async void sleep (uint milliseconds) requires (milliseconds > 0) {
        Timeout.add (milliseconds, () => {
            sleep.callback ();
            return Source.REMOVE;
        });
        yield;
    }
}
