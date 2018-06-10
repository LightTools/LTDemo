@isTest
private class WrapperTest {

    // test constants

    static final String TEST_KEY_STRING = 'string';
    static final String TEST_VALUE_STRING = 'Hello world!';

    static final String TEST_KEY_NULL = 'null';
    static final String TEST_VALUE_NULL = null;
    
    static final String TEST_KEY_BOOLEAN = 'boolean';
    static final Boolean TEST_VALUE_BOOLEAN = true;
    
    static final String TEST_KEY_INTEGER= 'integer';
    static final Integer TEST_VALUE_INTEGER= 0;
    
    static final String TEST_KEY_DECIMAL = 'decimal';
    static final Decimal TEST_VALUE_DECIMAL = 0.5;
    
    static final String TEST_KEY_LIST = 'list';
    static final List<Object> TEST_VALUE_LIST = new List<Object>();

    static final String TEST_KEY_MAP = 'map';
    static final Map<String, Object> TEST_VALUE_MAP = new Map<String, Object>();

    // test methods

    @isTest static void testConstructors() {
        // create data for test
        Map<String, Object> sourceForTest = new Map<String, Object> {
            TEST_KEY_STRING => TEST_VALUE_STRING
        };

        // start test
        Test.startTest();
        // create empty wrapper
        Wrapper wrapperEmpty = new Wrapper();
        // create empty wrapper from empty string for source
        Wrapper wrapperEmptyFromEmptyString = new Wrapper(Utils.EMPTY_STRING);
        // create wrapper from map
        Wrapper wrapperFromMap = new Wrapper(sourceForTest);
        // create wrapper from map
        Wrapper wrapperFromJSON = new Wrapper(JSON.serialize(sourceForTest));
        // end test
        Test.stopTest();

        // validate empty wrappers
        System.assertEquals(true, wrapperEmpty.isEmpty());
        System.assertEquals(true, wrapperEmptyFromEmptyString.isEmpty());

        // validate wrapper from map
        System.assertEquals(false, wrapperFromMap.isEmpty());
        System.assertEquals(TEST_VALUE_STRING, wrapperFromMap.get(TEST_KEY_STRING));

        // validate wrapper from JSON
        System.assertEquals(false, wrapperFromJSON.isEmpty());
        System.assertEquals(TEST_VALUE_STRING, wrapperFromJSON.get(TEST_KEY_STRING));
    }

    @isTest static void testMethods() {
        // create data for test
        Map<String, Object> paramsForTest = new Map<String, Object> {
            TEST_KEY_STRING => TEST_VALUE_STRING,
            TEST_KEY_NULL => TEST_VALUE_NULL,
            TEST_KEY_BOOLEAN => TEST_VALUE_BOOLEAN,
            TEST_KEY_INTEGER => TEST_VALUE_INTEGER,
            TEST_KEY_DECIMAL => TEST_VALUE_DECIMAL,
            TEST_KEY_LIST => TEST_VALUE_LIST,
            TEST_KEY_MAP => TEST_VALUE_MAP
        };

        // start test
        Test.startTest();
        // create empty wrapper
        Wrapper wrapperEmpty = new Wrapper();
        // set string key just to test set method
        wrapperEmpty.set(TEST_KEY_STRING, TEST_VALUE_STRING);
        // set params
        wrapperEmpty.setParams(paramsForTest);
        // end test
        Test.stopTest();

        // validate wrapper params
        System.assertEquals(false, wrapperEmpty.isEmpty());
        System.assertEquals(paramsForTest.keySet(), wrapperEmpty.keys());
        System.assertEquals(paramsForTest.values(), wrapperEmpty.values());

        // validate wrapper keys
        System.assertEquals(true, wrapperEmpty.containsKey(TEST_KEY_STRING));
        System.assertEquals(true, wrapperEmpty.containsKey(TEST_KEY_BOOLEAN));
        System.assertEquals(true, wrapperEmpty.containsKey(TEST_KEY_INTEGER));
        System.assertEquals(true, wrapperEmpty.containsKey(TEST_KEY_DECIMAL));
        System.assertEquals(true, wrapperEmpty.containsKey(TEST_KEY_LIST));
        System.assertEquals(true, wrapperEmpty.containsKey(TEST_KEY_MAP));

        // validate wrapper values
        System.assertEquals(TEST_VALUE_STRING, wrapperEmpty.getString(TEST_KEY_STRING));
        System.assertEquals(TEST_VALUE_NULL, wrapperEmpty.getString(TEST_KEY_NULL));
        System.assertEquals(TEST_VALUE_BOOLEAN, wrapperEmpty.getBoolean(TEST_KEY_BOOLEAN));
        System.assertEquals(TEST_VALUE_INTEGER, wrapperEmpty.getInteger(TEST_KEY_INTEGER));
        System.assertEquals(TEST_VALUE_DECIMAL, wrapperEmpty.getDecimal(TEST_KEY_DECIMAL));
        System.assertEquals(TEST_VALUE_LIST, wrapperEmpty.getList(TEST_KEY_LIST));
        System.assertEquals(TEST_VALUE_MAP, wrapperEmpty.getMap(TEST_KEY_MAP));

        // validate toJSON method
        System.assertEquals(JSON.serialize(TEST_VALUE_MAP), wrapperEmpty.getWrapper(TEST_KEY_MAP).toJSON());
    }

}