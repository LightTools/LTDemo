@isTest
private class UtilsTest {

    // test constants

    static final String TEST_KEY_EXCEPTION_CODE = 'statusCode';
    static final String TEST_KEY_EXCEPTION_MESSAGE = 'message';

    static final String TEST_EXCEPTION_CODE = 'Code';
    static final String TEST_EXCEPTION_MESSAGE = 'Message';

    static final String TEST_FIELD = 'Name';
    static final String TEST_FIELD_REFERENCE = 'CreatedBy.Name';

    // test methods

    @isTest static void customExceptionTest() {
        // start test
        Test.startTest();
        try {
            // create exception for test
            Utils.CustomException exceptionForTest = new Utils.CustomException();
            // set exception content
            exceptionForTest.setMessage(TEST_EXCEPTION_CODE, TEST_EXCEPTION_MESSAGE);
            // throw exception
            throw exceptionForTest;
        } catch (Utils.CustomException e) {
            // debug exception content
            Utils.debug(e.getMessage());
            // parse exception content
            Wrapper exceptionContent = new Wrapper(e.getMessage());
            // test exception code
            System.assertEquals(TEST_EXCEPTION_CODE, exceptionContent.getString(TEST_KEY_EXCEPTION_CODE));
            // test exception message
            System.assertEquals(TEST_EXCEPTION_MESSAGE, exceptionContent.getString(TEST_KEY_EXCEPTION_MESSAGE));
        }
        // end test
        Test.stopTest();
    }

    @isTest static void describeCacheTest() {
        // start test
        Test.startTest();
        // test global describe
        System.assertNotEquals(null, Utils.getGlobalDescribe());
        // test object describe
        System.assertNotEquals(null, Utils.getDescribe(ApexClass.sObjectType));
        // test field describe
        System.assertNotEquals(null, Utils.getDescribe(TEST_FIELD, ApexClass.sObjectType));
        // test reference field describe
        System.assertNotEquals(null, Utils.getDescribe(TEST_FIELD_REFERENCE, ApexClass.sObjectType));
        // end test
        Test.stopTest();
    }

    @isTest static void flsTest() {
        // start test
        Test.startTest();
        // test isAccessible
        System.assertEquals(true, Utils.isAccessible(TEST_FIELD, String.valueOf(ApexClass.sObjectType)));
        // test isCreateable
        System.assertEquals(true, Utils.isCreateable(TEST_FIELD, String.valueOf(ApexClass.sObjectType)));
        // test isUpdateable
        System.assertEquals(true, Utils.isUpdateable(TEST_FIELD, String.valueOf(ApexClass.sObjectType)));
        // end test
        Test.stopTest();
    }

}