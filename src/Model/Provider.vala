public abstract class EmA.Provider : Object {
    public abstract async void refresh_location (Location location);
    public abstract async ListModel list_all_locations ();
}
