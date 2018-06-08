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
        if (Utils.isNotNull(source)) {
            this.params = (Map<String, Object>)source;
        } else {
            this();
        }
    }

    /**
      * @description Constructor with param.
      * @param String source - serialized javascript object.
    */
    public Wrapper(String source) {
        if (Utils.isNotNull(source)) {
            this.params = (Map<String, Object>)JSON.deserializeUntyped(source);
        } else {
            this();
        }
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
      * @description Method to get a String value from the map.
      * @param String key - map key.
      * @return String - value from the map.
    */
    public String getString(String key) {
        String result = String.valueOf(this.params.get(key));
        return (
            String.isNotBlank(result) ?
            String.escapeSingleQuotes(result) :
            result
        );
    }

    /**
      * @description Method to get a Boolean value from the map.
      * @param String key - map key.
      * @return Boolean - value from the map.
    */
    public Boolean getBoolean(String key) {
        return Boolean.valueOf(this.params.get(key));
    }

    /**
      * @description Method to get a Integer value from the map.
      * @param String key - map key.
      * @return Integer - value from the map.
    */
    public Integer getInteger(String key) {
        return Integer.valueOf(this.params.get(key));
    }

    /**
      * @description Method to get a Decimal value from the map.
      * @param String key - map key.
      * @return Decimal - value from the map.
    */
    public Decimal getDecimal(String key) {
        return Decimal.valueOf(this.getString(key));
    }

    /**
      * @description Method to get a List value from the map.
      * @param String key - map key.
      * @return List - value from the map.
    */
    public List<Object> getList(String key) {
        return (List<Object>)this.get(key);
    }

    /**
      * @description Method to get a Map value from the map.
      * @param String key - map key.
      * @return Map - value from the map.
    */
    public Map<String, Object> getMap(String key) {
        return (Map<String, Object>)this.get(key);
    }

    /**
      * @description Method to get a Wrapper value from the map.
      * @param String key - map key.
      * @return Wrapper - value from the map.
    */
    public Wrapper getWrapper(String key) {
        return new Wrapper(this.get(key));
    }

    /**
      * @description Method to store a value in the map.
      * @param String key - map key.
      * @param Object value - value of any type.
    */
    public Wrapper set(String key, Object value) {
        this.params.put(key, value);
        return this;
    }

    /**
      * @description Method to add external map to the map.
      * @param Map source - external map.
    */
    public Wrapper setParams(Map<String, Object> source) {
        this.params.putAll(source);
        return this;
    }

    /**
      * @description Method to check if the wrapper is an empty.
      * @return String - JSON.
    */
    public Boolean isEmpty() {
        return this.params.isEmpty();
    }

    /**
      * @description Method to convert the map to JSON.
      * @return String - JSON.
    */
    public String toJSON() {
        return JSON.serialize(this.params);
    }
}