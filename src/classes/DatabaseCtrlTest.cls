@isTest
private class DatabaseCtrlTest {

    // test constants

    static final String TEST_OBJECT_NAME = 'Account';
    static final String TEST_WRONG_OBJECT_NAME = 'WrongObjectName';

    static final Wrapper TEST_CONFIG_QUERY = new Wrapper(new Map<String, Object> {
        'object' => TEST_OBJECT_NAME,
        'fields' => new List<Object> {
            'CreatedDate'
        },
        'functions' => new Map<String, Object> {
            'CreatedDate' => 'FORMAT({0})'
        },
        'filter' => 'Name = \'' + DatabaseCtrlTest.class.getName() + '\'',
        'sort' => 'Name',
        'offset' => 0,
        'limit' => 1,
        'childs' => new List<Object> {
            new Map<String, Object> {
                'object' => 'Contacts'
            }
        }
    });

    static final Wrapper TEST_CONFIG_SEARCH = new Wrapper(new Map<String, Object> {
        'filter' => DatabaseCtrl.class.getName(),
        'group' => 'All',
        'entities' => new List<Object> {
            new Map<String, Object> {
                'object' => TEST_OBJECT_NAME,
                'fields' => new List<Object> {
                    'CreatedDate'
                },
                'functions' => new Map<String, Object> {
                    'CreatedDate' => 'FORMAT({0})'
                }
            }
        }
    });

    static final Wrapper TEST_CONFIG_SAVE = new Wrapper(new Map<String, Object> {
        'records' => new List<Object> {
            new Map<String, Object> {
                'sObjectType' => TEST_OBJECT_NAME,
                'Name' => DatabaseCtrlTest.class.getName()
            }
        }
    });

    // test methods

    @isTest static void describeTest() {
        // create test data
        String describeResultFail;
        // start test
        Test.startTest();
        // get describe
        Wrapper describeResult = new Wrapper(DatabaseCtrl.describe(JSON.serialize(new List<Object> { TEST_OBJECT_NAME })));
        // test errors handling
        try {
            describeResultFail = DatabaseCtrl.describe(JSON.serialize(new List<Object> { TEST_WRONG_OBJECT_NAME }));
        } catch (AuraHandledException e) {
            // describeResultFail is null
        }
        // end test
        Test.stopTest();
        // check describeResult size
        System.assertEquals(false, describeResult.isEmpty());
        // check if describeResult has object describe
        System.assertEquals(true, describeResult.containsKey(TEST_OBJECT_NAME));
        // check if describe for object is not empty
        System.assertNotEquals(true, new Wrapper(describeResult.get(TEST_OBJECT_NAME)).isEmpty());
        // check if describeResultFail is blank
        System.assertEquals(null, describeResultFail);
    }

    @isTest static void buildSOQLTest() {
        // create test data
        String resultFailForTest;
        // start test
        Test.startTest();
        // get result
        String resultForTest = DatabaseCtrl.buildSOQL(TEST_CONFIG_QUERY.toJSON());
        // test errors handling
        try {
            resultFailForTest = DatabaseCtrl.buildSOQL(TEST_CONFIG_QUERY.set('object', TEST_WRONG_OBJECT_NAME).toJSON());
        } catch (AuraHandledException e) {
            // resultFailForTest is null
        }
        // end test
        Test.stopTest();
        // validate result
        System.assertNotEquals(null, resultForTest);
        // check fail result
        System.assertEquals(null, resultFailForTest);
    }

    @isTest static void queryTest() {
        // create test data
        String resultFailForTest;
        insert new Account(Name = DatabaseCtrlTest.class.getName());
        // start test
        Test.startTest();
        // get result with sharing
        String resultForTest = DatabaseCtrl.query(TEST_CONFIG_QUERY.toJSON());
        // get result without sharing
        String resultForTestWS = DatabaseCtrl.query(TEST_CONFIG_QUERY.set('sharing', false).toJSON());   
        // test errors handling with wrong relation
        try {
            resultFailForTest = DatabaseCtrl.query(TEST_CONFIG_QUERY.set('childs', new List<Object> {
                new Map<String, Object> {
                    'object' => TEST_WRONG_OBJECT_NAME
                }
            }).toJSON());
        } catch (AuraHandledException e) {
            // resultFailForTest is null
        }     
        // test errors handling with wrong object name
        try {
            resultFailForTest = DatabaseCtrl.query(TEST_CONFIG_QUERY.set('object', TEST_WRONG_OBJECT_NAME).toJSON());
        } catch (AuraHandledException e) {
            // resultFailForTest is null
        }
        // end test
        Test.stopTest();
        // validate result with sharing
        System.assertNotEquals(null, resultForTest);
        // validate result without sharing
        System.assertNotEquals(null, resultForTestWS);
        // check result with sharing size
        System.assertEquals(false, ((List<Object>)JSON.deserializeUntyped(resultForTest)).isEmpty());
        // check result without sharing size
        System.assertEquals(false, ((List<Object>)JSON.deserializeUntyped(resultForTestWS)).isEmpty());
        // check fail result
        System.assertEquals(null, resultFailForTest);
    }

    @isTest static void buildSOSLTest() {
        // create test data
        String resultFailForTest;
        // start test
        Test.startTest();
        // get result
        String resultForTest = DatabaseCtrl.buildSOSL(TEST_CONFIG_SEARCH.toJSON());
        // test errors handling
        try {
            resultFailForTest = DatabaseCtrl.buildSOSL(TEST_CONFIG_SEARCH.set('entities', new List<Object> {
                new Map<String, Object> {
                    'object' => TEST_WRONG_OBJECT_NAME
                }
            }).toJSON());
        } catch (AuraHandledException e) {
            // resultFailForTest is null
        }
        // end test
        Test.stopTest();
        // validate result
        System.assertNotEquals(null, resultForTest);
        // check fail result
        System.assertEquals(null, resultFailForTest);
    }

    @isTest static void searchTest() {
        // create test data
        String resultFailForTest;
        // start test
        Test.startTest();
        // get result with sharing
        String resultForTest = DatabaseCtrl.search(TEST_CONFIG_SEARCH.toJSON());
        // get result without sharing
        String resultForTestWS = DatabaseCtrl.search(TEST_CONFIG_SEARCH.set('sharing', false).toJSON());
        // test errors handling
        try {
            resultFailForTest = DatabaseCtrl.search(TEST_CONFIG_SEARCH.set('entities', new List<Object> {
                new Map<String, Object> {
                    'object' => TEST_WRONG_OBJECT_NAME
                }
            }).toJSON());
        } catch (AuraHandledException e) {
            // resultFailForTest is null
        }
        // end test
        Test.stopTest();
        // validate result with sharing
        System.assertNotEquals(null, resultForTest);
        // validate result without sharing
        System.assertNotEquals(null, resultForTestWS);
        // check result size
        System.assertEquals(false, ((List<Object>)JSON.deserializeUntyped(resultForTest)).isEmpty());
        // check fail result
        System.assertEquals(null, resultFailForTest);
    }

    @isTest static void saveTest() {
        // create test data
        String resultFailForTest;
        // start test
        Test.startTest();
        // get result with sharing
        String resultForTest = DatabaseCtrl.save(TEST_CONFIG_SAVE.toJSON());
        // get result without sharing
        String resultForTestWS = DatabaseCtrl.save(TEST_CONFIG_SAVE.set('sharing', false).toJSON());
        // test errors handling with wrong object name
        try {
            resultFailForTest = DatabaseCtrl.save(TEST_CONFIG_SAVE.set('records', new List<Object> {
                new Map<String, Object> {
                    'sObjectType' => TEST_WRONG_OBJECT_NAME
                }
            }).toJSON());
        } catch (AuraHandledException e) {
            // resultFailForTest is null
        }
        // test errors handling without object name
        try {
            resultFailForTest = DatabaseCtrl.save(TEST_CONFIG_SAVE.set('records', new List<Object> {
                new Map<String, Object> {
                    'sObjectType' => null
                }
            }).toJSON());
        } catch (AuraHandledException e) {
            // resultFailForTest is null
        }
        // end test
        Test.stopTest();
        // validate result with sharing
        System.assertNotEquals(null, resultForTest);
        // validate result without sharing
        System.assertNotEquals(null, resultForTestWS);
        // check result size
        System.assertEquals(false, ((List<Object>)JSON.deserializeUntyped(resultForTest)).isEmpty());
        // check fail result
        System.assertEquals(null, resultFailForTest);
        // check records in database
        System.assertNotEquals(0, [SELECT COUNT() FROM Account WHERE Name = :DatabaseCtrlTest.class.getName()]);
    }

    @isTest static void removeTest() {
        // create test data
        Boolean resultFailForTest = true;
        Account recordForTest = new Account(Name = DatabaseCtrlTest.class.getName());
        Database.insert(recordForTest);
        Wrapper removeConfigForTest = new Wrapper().setParams(new Map<String, Object>{
            'items' => new List<Object> { recordForTest.Id }
        });
        Account recordForTestWS = new Account(Name = DatabaseCtrlTest.class.getName());
        Database.insert(recordForTestWS);
        Wrapper removeConfigWSForTest = new Wrapper().setParams(new Map<String, Object>{
            'items' => new List<Object> { recordForTestWS.Id },
            'sharing' => false
        });
        // start test
        Test.startTest();
        // remove record with sharing
        Boolean resultForTest = DatabaseCtrl.remove(removeConfigForTest.toJSON());
        // remove record without sharing
        Boolean resultForTestWS = DatabaseCtrl.remove(removeConfigWSForTest.toJSON());
        // test errors handling
        try {
            DatabaseCtrl.remove(removeConfigForTest.toJSON());
        } catch (DMLException e) {
            resultFailForTest = false;
        }
        // end test
        Test.stopTest();
        // validate result with sharing
        System.assertEquals(true, resultForTest);
        // validate result without sharing
        System.assertEquals(true, resultForTestWS);
        // check fail result
        System.assertEquals(false, resultFailForTest);
        // check records in database
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id IN :new Set<Id>{ recordForTest.Id, recordForTestWS.Id }]);
    }

}