public with sharing class Utils {

    // class constants

    private static final Boolean DEBUG_ENABLED = true; // turn off in release version
    private static final String DEBUG_SEPARATOR = ' -> ';

    public static final String WHITESPACE = ' ';
    public static final String EMPTY_STRING = '';

    // class variables

    private static DescribeCache describeCache = new DescribeCache();

    // inner classes

    /** 
      * @description Enhanced Exception class.
      * @author Sergey Chepurnenko
    */
    public virtual class CustomException extends Exception {

        // class constants

        private final String KEY_CODE = 'statusCode';
        private final String KEY_MESSAGE = 'message';

        // class methods

        /**
          * @description Method to set exception's message with code.
          * @param String code - specific exception's code.
          * @param String message - exception's message.
        */
        public void setMessage(String code, String message) {
            // call method from super class
            super.setMessage(
                // wrap code and message to JSON
                new Wrapper().set(this.KEY_CODE, code)
                             .set(this.KEY_MESSAGE, message)
                             .toJSON()
            );
        }
    }

    /** 
      * @description Describe Cache feature.
      * @author Sergey Chepurnenko
    */
    private class DescribeCache {

        // class private properties

        private Map<String, Schema.DescribeSObjectResult> objectsDescribe {
            private get {
                if (Utils.isNull(this.objectsDescribe)) {
                    this.objectsDescribe = new Map<String, Schema.DescribeSObjectResult>();
                }
                return this.objectsDescribe;  
            }
            private set;
        }

        private Map<String, Map<String, Schema.DescribeFieldResult>> fieldsDescribe {
            private get {
                if (Utils.isNull(this.fieldsDescribe)) {
                    this.fieldsDescribe = new Map<String, Map<String, Schema.DescribeFieldResult>>();
                }
                return this.fieldsDescribe;  
            }
            private set;
        }

        // class public properties

        /**
          * @description Global Describe info. 
        */
        public Map<String, Schema.SObjectType> globalDescribe {
            public get {
                if (Utils.isNull(this.globalDescribe)) {
                    this.globalDescribe = Schema.getGlobalDescribe();
                }
                return this.globalDescribe;  
            }
            private set;
        }

        /**
          * @description Method to get sObject's describe result.
          * @param String objectName - sObject's name.
          * @return Schema.DescribeSObjectResult - describe of sObject.
        */
        public Schema.DescribeSObjectResult getObjectDescribe(String objectName) {
            // if sObject exists
            if (!this.objectsDescribe.containsKey(objectName) &&
                    this.globalDescribe.containsKey(objectName)) {
                // add sObject describe to cache
                this.objectsDescribe.put(
                    objectName,
                    this.globalDescribe.get(objectName).getDescribe()
                );  
            }
            // return result
            return this.objectsDescribe.get(objectName);
        }

        /**
          * @description Method to get sObject's Field describe result.
          * @param String fieldName - name of sObject's field name.
          * @param String objectName - sObject's name.
          * @return Schema.DescribeFieldResult - describe of sObject.
        */
        public Schema.DescribeFieldResult getFieldDescribe(String fieldName, String objectName) {
            // create empty result
            Schema.DescribeFieldResult result;
            // get object describe
            Schema.DescribeSObjectResult objectDescribe = this.getObjectDescribe(objectName);
            // validate describe result
            if (Utils.isNotNull(objectDescribe)) {
                // get object fields from describe
                Map<String, Schema.SObjectField> objectFields = objectDescribe.fields.getMap();
                // initialize current fields cache
                Map<String, Schema.DescribeFieldResult> objectFieldsCache = this.fieldsDescribe.get(objectName);
                // if cache is empty (this should happen only for first time)
                if (Utils.isNull(objectFieldsCache)) {
                    // create a new cache
                    objectFieldsCache = new Map<String, Schema.DescribeFieldResult>();
                    // add all fields from object to cache
                    for (Schema.SObjectField objectField : objectDescribe.fields.getMap().values()) {
                        // get current field describe
                        Schema.DescribeFieldResult objectFieldDescribe = objectField.getDescribe();
                        // add field name and describe to cache
                        objectFieldsCache.put(objectFieldDescribe.getName(), objectFieldDescribe);
                        // in case of reference field
                        if (objectFieldDescribe.getType() == Schema.DisplayType.Reference) {
                            // add reference name and describe to cache
                            objectFieldsCache.put(objectFieldDescribe.getRelationshipName(), objectFieldDescribe);
                        }
                    }
                    // update fields cache for oobject
                    this.fieldsDescribe.put(objectName, objectFieldsCache);
                }
                // set result
                result = objectFieldsCache.get(fieldName);
            }
            // return result
            return result;
        }

    }

    /** 
      * @description Represent of sObject field.
      * @author Sergey Chepurnenko
    */
    private class Field {

        // class constants

        private final String SEPARATOR_REFERENCE = '.';

        // class variables

        private Schema.DescribeFieldResult describe;

        // class constructors

        /**
          * @description Constructor for the class.
          * @param String field - name of field.
          * @param Schema.DescribeSObjectResult objectDescribe - describe of sObject.
        */
        public Field(String fieldName, Schema.DescribeSObjectResult objectDescribe) {
            // validate params
            if (String.isNotBlank(fieldName) &&
                    Utils.isNotNull(objectDescribe)) {
                // check field type
                if (fieldName.contains(this.SEPARATOR_REFERENCE)) {
                    // in case of referecne, get first field from chain
                    String objectReference = fieldName.substringBefore(this.SEPARATOR_REFERENCE).replace('__r', '__c');
                    // get reference field describe
                    Schema.DescribeFieldResult objectReferenceDescribe = Utils.describeCache.getFieldDescribe(
                        objectReference,
                        objectDescribe.getName()
                    );
                    // if this reference field is Reference and is accessible
                    if (Utils.isNotNull(objectReferenceDescribe) &&
                            objectReferenceDescribe.isAccessible()) {
                        // get the other fields from the chain
                        String objectReferenceFields = fieldName.substringAfter(this.SEPARATOR_REFERENCE);
                        // get describe for the first reference
                        this.describe = new Field(
                            objectReferenceFields,
                            Utils.getDescribe(objectReferenceDescribe.getReferenceTo()[0])
                        ).getFieldDescribe();
                    }
                } else {
                    // for normal field just get describe from cache
                    this.describe = Utils.describeCache.getFieldDescribe(
                        fieldName,
                        objectDescribe.getName()
                    );
                }
            }
        }

        // class public methods

        /**
          * @description Method to get describe for a field.
          * @return Schema.DescribeFieldResult - field describe.
        */
        public Schema.DescribeFieldResult getFieldDescribe() {
            return this.describe;
        }

    }

    // class public methods

    // --------------------------------------------------------------------------------------------------------------------------------------
    // Generic
    // --------------------------------------------------------------------------------------------------------------------------------------

    public static void debug(String sender, Object log) {
        if (Utils.DEBUG_ENABLED) {
            System.debug((
                String.isNotBlank(sender) ?
                sender + Utils.DEBUG_SEPARATOR :
                Utils.EMPTY_STRING
            ) + log);
        }
    }

    public static void debug(Object log) {
        Utils.debug(null, log);
    }

    public static Boolean isNull(Object source) {
        return source == null;
    }

    public static Boolean isNotNull(Object source) {
        return !Utils.isNull(source);
    }

    // --------------------------------------------------------------------------------------------------------------------------------------
    // Describe
    // --------------------------------------------------------------------------------------------------------------------------------------

    public static Map<String, Schema.SObjectType> getGlobalDescribe() {
        return Utils.describeCache.globalDescribe;
    }

    public static Schema.DescribeSObjectResult getDescribe(String objectName) {
        return Utils.describeCache.getObjectDescribe(objectName);
    }

    public static Schema.DescribeSObjectResult getDescribe(Schema.SObjectType objectType) {
        return Utils.getDescribe(String.valueOf(objectType));
    }

    public static Schema.DescribeFieldResult getDescribe(String fieldName, Schema.DescribeSObjectResult objectDescribe) {
        return new Field(
            fieldName,
            objectDescribe
        ).getFieldDescribe();
    }

    public static Schema.DescribeFieldResult getDescribe(String fieldName, String objectName) {
        return Utils.getDescribe(
            fieldName,
            Utils.getDescribe(objectName)
        );
    }

    public static Schema.DescribeFieldResult getDescribe(String fieldName, Schema.SObjectType objectType) {
        return Utils.getDescribe(
            fieldName,
            String.valueOf(objectType)
        );
    }

    // --------------------------------------------------------------------------------------------------------------------------------------
    // CRUD & FLS
    // --------------------------------------------------------------------------------------------------------------------------------------

    public static Boolean isAccessible(String fieldName, Schema.DescribeSObjectResult objectDescribe) {
        // get field describe
        Schema.DescribeFieldResult fieldDescribe = Utils.getDescribe(fieldName, objectDescribe);
        // create result
        return (
            Utils.isNotNull(fieldDescribe) ?
            fieldDescribe.isAccessible() :
            false
        );
    }

    public static Boolean isAccessible(String fieldName, String objectName) {
        return Utils.isAccessible(
            fieldName,
            Utils.getDescribe(objectName)
        );
    }

    public static Boolean isCreateable(String fieldName, Schema.DescribeSObjectResult objectDescribe) {
        // get field describe
        Schema.DescribeFieldResult fieldDescribe = Utils.getDescribe(fieldName, objectDescribe);
        // create result
        return (
            Utils.isNotNull(fieldDescribe) ?
            fieldDescribe.isCreateable() :
            false
        );
    }

    public static Boolean isCreateable(String fieldName, String objectName) {
        return Utils.isCreateable(
            fieldName,
            Utils.getDescribe(objectName)
        );
    }

    public static Boolean isUpdateable(String fieldName, Schema.DescribeSObjectResult objectDescribe) {
        // get field describe
        Schema.DescribeFieldResult fieldDescribe = Utils.getDescribe(fieldName, objectDescribe);
        // create result
        return (
            Utils.isNotNull(fieldDescribe) ?
            fieldDescribe.isUpdateable() :
            false
        );
    }

    public static Boolean isUpdateable(String fieldName, String objectName) {
        return Utils.isUpdateable(
            fieldName,
            Utils.getDescribe(objectName)
        );
    }

}