/** 
  * @description Universal wrapper class based on Map.
  * @author Sergey Chepurnenko
*/
public virtual class Wrapper {

    // class variables

    private Map<String, Object> params; // Map to store wrapper values

    // class constructors

    /**
      * @description Default constructor without param.
    */
    public Wrapper() {
        // create empty map to store wrapper values
        this.params = new Map<String, Object>();
    }

    /**
      * @description Constructor with param.
      * @param Object source - instance of Map.
    */
    public Wrapper(Object source) {
        this.params = (Map<String, Object>)source;
    }

    /**
      * @description Constructor with param.
      * @param String source - serialized javascript object.
    */
    public Wrapper(String source) {
        this.params = (Map<String, Object>)JSON.deserializeUntyped(source);
    }

    // class methods

    /**
      * @description Method to get the map's keys.
      * @return Set - set of the map's keys.
    */
    public Set<String> keys() {
        return this.params.keySet();
    }

    /**
      * @description Method to get the map's values.
      * @return List - list of the map's values.
    */
    public List<Object> values() {
        return this.params.values();
    }

    /**
      * @description Method to check if key exists in the map.
      * @param String key - map key to check.
      * @return Boolean - if key exists in the map - true, otherwise false.
    */
    public Boolean containsKey(String key) {
        return this.params.containsKey(key);
    }

    /**
      * @description Method to get a value from the map.
      * @param String key - map key.
      * @return Object - value from the map.
    */
    public Object get(String key) {
        return this.params.get(key);
    }

    /**
      * @description Method to store a value in the map.
      * @param String key - map key.
      * @param Object value - value of any type.
    */
    public void set(String key, Object value) {
        this.params.put(key, value);
    }

    /**
      * @description Method to add external map to the map.
      * @param Map source - external map.
    */
    public void setParams(Map<String, Object> source) {
        this.params.putAll(source);
    }

    /**
      * @description Method to convert the map to JSON.
      * @return String - JSON.
    */
    public String toJSON() {
        return JSON.serialize(this.params);
    }
}