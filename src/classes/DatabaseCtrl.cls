/** 
  * @description This class is a controller for database component and holds methods to work with Salesforce database.
  * @author Sergey Chepurnenko
*/
public with sharing class DatabaseCtrl {

    // inner classes

    /** 
      * @description This class is an implementation for custom exceptions inside Database class.
      * @author Sergey Chepurnenko
    */
    private class DatabaseException extends Exception {

        public DatabaseException objectNotFound(String objectName) {
            this.setMessage(String.format(
                'Object {0} was not found.',
                new List<String>{ objectName }
            ));
            return this;
        }

        public DatabaseException relationshipNotFound(String objectName) {
            this.setMessage(String.format(
                'Relationship {0} was not found.',
                new List<String>{ objectName }
            ));
            return this;
        }

        public DatabaseException objectNotAccessible(String objectName) {
            this.setMessage(String.format(
                'Object {0} is not accessible.',
                new List<String>{ objectName }
            ));
            return this;
        }

    }

    /** 
      * @description Represent of object field for query.
      * @author Sergey Chepurnenko
    */
    private class QueryField {

        // class variables

        private String field;        
        private DescribeSObjectResult objectDescribe;

        // class constructors

        /**
          * @description Constructor for the class.
          * @param String field - name of field.
          * @param DescribeSObjectResult objectDescribe - describe of sObject.
        */
        public QueryField(String field, DescribeSObjectResult objectDescribe) {
            this.field = field;
            this.objectDescribe = objectDescribe;
        }

        // class public methods

        /**
          * @description Method to check access for a field.
          * @return Boolean - access state, true/false.
        */
        public Boolean isAccessible() {
            // by default result will be false
            Boolean result = false;
            // get fields map from describe
            Map<String, sObjectField> objectFields = this.objectDescribe.fields.getMap();
            // validate field access
            if (this.field.contains('.')) {
                // in case of referecne, get first field from chain
                String objectReference = this.field.substringBefore('.').replace('__r', '__c');
                if (objectFields.containsKey(objectReference)) {
                    // get reference field describe
                    DescribeFieldResult objectReferenceDescribe = objectFields.get(objectReference).getDescribe();
                    // if this reference field is Reference and is accessible, we can check access for other fields in the chain
                    if (objectReferenceDescribe.getType() == DisplayType.Reference &&
                           objectReferenceDescribe.isAccessible()) {
                        // get the other fields from the chain
                        String objectReferenceFields = this.field.substringAfter('.');
                        // check access for all references
                        for (sObjectType objectReferenceType : objectReferenceDescribe.getReferenceTo()) {
                            result = new QueryField(
                                objectReferenceFields,
                                objectReferenceType.getDescribe()
                            ).isAccessible();
                            // in case of false we don't need to check other references
                            if (result == false) {
                                break;
                            }
                        }
                    }
                }
            } else if (objectFields.containsKey(this.field)) {
                // for normal field just check access rights
                result = objectFields.get(this.field).getDescribe().isAccessible();
            }
            // return access state
            return result;
        }

    }

    /** 
      * @description This class is a wrapper for query config.
      * @author Sergey Chepurnenko
    */
    private class QueryConfig extends Wrapper {

        // class constants

        private final String KEY_OBJECT = 'object';
        private final String KEY_FIELDS = 'fields';
        private final String KEY_FILTERS = 'filters';
        private final String KEY_SORT_OPTIONS = 'sort';
        private final String KEY_OFFSET = 'offset';
        private final String KEY_LIMIT = 'limit';
        private final String KEY_CHILDS = 'childs';

        private final String SOQL_SELECT_TEMPLATE = 'SELECT {0} FROM {1}';
        private final String SOQL_WHERE_TEMPLATE = 'WHERE {0}';
        private final String SOQL_ORDERBY_TEMPLATE = 'ORDER BY {0}';
        private final String SOQL_OFFSET_TEMPLATE = 'OFFSET {0}';
        private final String SOQL_LIMIT_TEMPLATE = 'LIMIT {0}';

        // class variables

        private String queryObject;
        private DescribeSObjectResult parentDescribe;

        // class properties

        private Boolean isChild {
            get {
                return this.parentDescribe != null;
            }
        }

        // class constructors

        /**
          * @description Constructor for child queries.
          * @param Object source - instance of Map.
          * @param DescribeSObjectResult parentDescribe - describe of parent object.
        */
        public QueryConfig(Object config, DescribeSObjectResult parentDescribe) {
            super(config);
            // store parent object describe
            this.parentDescribe = parentDescribe;
        }

        /**
          * @description Constructor with param.
          * @param String source - serialized javascript object.
        */
        public QueryConfig(String config) {
            super(config);
        }

        // class public methods

        /**
          * @description Method to get dynamic query for Database.query() method.
          * @return String - query string.
        */
        public String getQuery() {
            // get object describe for query
            DescribeSObjectResult queryObjectDescribe = this.getObjectDescribe();
            // create result query
            String resultQuery = String.format(
                this.SOQL_SELECT_TEMPLATE,
                new List<String> {
                    this.getQueryFields(queryObjectDescribe),
                    this.queryObject
                }
            );
            // add filters to the query
            resultQuery += this.getQueryFilters();
            // add sort options to the query
            resultQuery += this.getQuerySortOptions();
            // add limit to the query
            resultQuery += this.getQueryLimit();
            // add offset to the query
            resultQuery += this.getQueryOffset();
            // TODO: remove debug
            System.debug(resultQuery);
            // return query
            return resultQuery;
        }

        // class private methods

        private DescribeSObjectResult getObjectDescribe() {
            DescribeSObjectResult result;
            // get global describe for objects
            Map<String, sObjectType> objectsDescribe = Schema.getGlobalDescribe();
            // get object name from config
            String configObject = String.valueOf(this.get(this.KEY_OBJECT));
            // validation for child queries
            if (this.isChild) {
                for (ChildRelationship child : this.parentDescribe.getChildRelationships()) {
                    String relationshipName = child.getRelationshipName();
                    if (String.isNotBlank(relationshipName) &&
                            relationshipName.equalsIgnoreCase(configObject)) {
                        // return related object describe
                        result = child.getChildSObject().getDescribe();
                        // store query object (child relationship)
                        this.queryObject = configObject;
                        break;
                    }
                }
                // show exception if relationship was not found
                if (result == null) {
                    throw new DatabaseException().relationshipNotFound(configObject);
                }
            } else {
                // validation for parent queries
                if (objectsDescribe.containsKey(configObject)) {
                    // return original object describe
                    result = objectsDescribe.get(configObject).getDescribe();
                    // store query object (original object)
                    this.queryObject = result.getName();
                } else {
                    throw new DatabaseException().objectNotFound(configObject);
                }
            }
            // validate permission rights for the object
            if (!result.isAccessible()) {
                throw new DatabaseException().objectNotAccessible(result.getName());
            } else if (!result.isQueryable()) {
                throw new DatabaseException().objectNotAccessible(result.getName());
            }
            return result;
        }

        private String getQueryFields(DescribeSObjectResult objectDescribe) {
            // get fields map from describe
            Map<String, sObjectField> objectFields = objectDescribe.fields.getMap();
            // create a new list of fields
            List<String> queryFields = new List<String>();
            // parse config fields
            for (Object configField : (List<Object>)this.get(this.KEY_FIELDS)) {
                String currentConfigField = String.valueOf(configField).trim();
                QueryField currentQueryField = new QueryField(currentConfigField, objectDescribe);
                // FLS validation
                if (currentQueryField.isAccessible()) {
                    // add field to query
                    queryFields.add(currentConfigField);
                }
            }
            // get child queries
            String queryChilds = this.getQueryChilds(objectDescribe);
            // validate query fields
            if (queryFields.isEmpty()) {
                queryFields.add('Id'); // just add Id field for the query, because I don't want to throw exception for this case
            }
            // create result
            return String.join(queryFields, ', ') +
                    // add child queries to the main query as fields
                    (!queryFields.isEmpty() &&
                        String.isNotBlank(queryChilds) ?
                            ', ' + queryChilds : '');

        }

        private String getQueryChilds(DescribeSObjectResult objectDescribe) {
            String result = '';
            if (this.containsKey(this.KEY_CHILDS)) {
                // parse childs
                List<String> queryChilds = new List<String>();
                for (Object configChild : (List<Object>)this.get(this.KEY_CHILDS)) {
                    // add child query
                    queryChilds.add(new QueryConfig(configChild, objectDescribe).getQuery());
                }
                if (!queryChilds.isEmpty()) {
                    // set result
                    result = '(' + String.join(queryChilds, '), (') + ')';
                }
            }
            return result;
        }

        private String getQueryFilters() {
            String result = '';
            if (this.containsKey(this.KEY_FILTERS)) {
                List<Object> configFilters = (List<Object>)this.get(this.KEY_FILTERS);
                if (!configFilters.isEmpty()) {
                    result = ' ' + String.format(
                        this.SOQL_WHERE_TEMPLATE,
                        new List<String> {
                            String.join(configFilters, ' ').trim()
                        }
                    );
                }
            }
            return result;
        }

        private String getQuerySortOptions() {
            String result = '';
            if (this.containsKey(this.KEY_SORT_OPTIONS)) {
                List<Object> configSortOptions = (List<Object>)this.get(this.KEY_SORT_OPTIONS);
                if (!configSortOptions.isEmpty()) {
                    result = ' ' + String.format(
                        this.SOQL_ORDERBY_TEMPLATE,
                        new List<String> {
                            String.join(configSortOptions, ' ').trim()
                        }
                    );
                }
            }
            return result;
        }

        private String getQueryOffset() {
            String result = '';
            if (!this.isChild &&
                    this.containsKey(this.KEY_OFFSET)) {
                result = ' ' + String.format(
                    this.SOQL_OFFSET_TEMPLATE,
                    new List<String> {
                        String.valueOf(this.get(this.KEY_OFFSET))
                    }
                );
            }
            return result;
        }

        private String getQueryLimit() {
            String result = '';
            if (this.containsKey(this.KEY_LIMIT)) {
                result = ' ' + String.format(
                    this.SOQL_LIMIT_TEMPLATE,
                    new List<String> {
                        String.valueOf(this.get(this.KEY_LIMIT))
                    }
                );
            }
            return result;
        }
    }

    // class methods

    /**
      * @description Method to get records from database using SOQL query.
      * @param String config - serialized javascript object. This object should contain object name, object fields and query conditions for SOQL.
      * @return String - serialized javascript object with SOQL results.
    */
    @AuraEnabled
    public static String query(String config) {
        String result;
        try {
            // create result
            result = JSON.serialize(Database.query(
                new QueryConfig(config).getQuery()
            ));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
    	return result;
    }

}