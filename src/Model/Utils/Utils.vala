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

    public async Polygon polygon_from_geo_json (Json.Object geometry_object) throws Error {
        if (!geometry_object.has_member ("type") || !geometry_object.has_member ("coordinates")) {
            throw new IOError.FAILED ("Invalid GeoJSON geometry object");
        }

        if (geometry_object.get_string_member ("type") != "Polygon") {
            throw new IOError.FAILED ("Only Polygon geometries are supported");
        }

        var linear_rings = geometry_object.get_array_member ("coordinates");
        if (linear_rings == null || linear_rings.get_length () == 0) {
            throw new IOError.FAILED ("Invalid GeoJSON Polygon");
        }

        var polygon = new Polygon ();

        var border_ring = linear_rings.get_array_element (0);
        border_ring.foreach_element ((array, index, node) => {
            var coord_array = node.get_array ();

            var longitude = coord_array.get_double_element (0);
            var latitude = coord_array.get_double_element (1);

            polygon.add_point (new Coordinate (latitude, longitude));
        });

        // We ignore holes since if an alert applies to an area surrounding an area it
        // probably applies to the surrounded area as well

        //  var holes = new Gee.ArrayList<Gee.List<Coordinate>> ();

        //  for (int i = 1; i < linear_rings.get_length (); i++) {
        //      var hole_ring = linear_rings.get_array_element (i);
        //      var hole = new Gee.ArrayList<Coordinate> ();

        //      hole_ring.foreach_element ((array, index, node) => {
        //          var coord_array = node.get_array ();

        //          var longitude = coord_array.get_double_element (0);
        //          var latitude = coord_array.get_double_element (1);

        //          hole.add (new Coordinate (latitude, longitude));
        //      });

        //      holes.add (hole);
        //  }

        return polygon;
    }
}
