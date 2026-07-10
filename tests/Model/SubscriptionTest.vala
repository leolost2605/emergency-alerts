/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard (leo.kargl@proton.me)
 */

public class EmA.SubscriptionTest : TestCase {
    construct {
        add_test ("Test basic filtering", test_basic_filtering);
        // TODO: Test add and remove
        // TODO: Test changing coordinate
    }

    private void test_basic_filtering () {
        var warnings = new ListStore (typeof (Warning));
        var coord = new Coordinate (10, 5);
        var location = new FixedLocation (coord, "My Location", "My country", "de");

        var subscription = new Subscription (warnings, location);

        assert_cmpuint (0, EQ, subscription.warnings.get_n_items ());

        Coordinate[] coordinates = {
            new Coordinate (-10, -10),
            new Coordinate (-10, 5),
            new Coordinate (5, -10),
            new Coordinate (5, 5)
        };

        Polygon[] polygons = {
            new Polygon.from_coordinates (coordinates),
        };

        var multi_polygon = new MultiPolygon.from_polygons (polygons);

        var warning_no_contains = new Warning ("my id", multi_polygon);

        warnings.append (warning_no_contains);

        assert_cmpuint (0, EQ, subscription.warnings.get_n_items ());

        coordinates = {
            new Coordinate (0, 0),
            new Coordinate (0, 10),
            new Coordinate (10, 10),
            new Coordinate (10, 0)
        };

        polygons = {
            new Polygon.from_coordinates (coordinates),
        };

        multi_polygon = new MultiPolygon.from_polygons (polygons);

        var warning_contains = new Warning ("my warning that affects the location", multi_polygon);

        warnings.append (warning_contains);

        assert_cmpuint (1, EQ, subscription.warnings.get_n_items ());

        var subscription_warning = (Warning) subscription.warnings.get_item (0);

        assert_cmpstr ("my warning that affects the location", EQ, subscription_warning.id);

        assert_finalize_object (ref subscription);
        assert_finalize_object (ref location);
        assert_finalize_object (ref warnings);

        warning_contains = null;

        assert_finalize_object (ref subscription_warning);
    }
}
