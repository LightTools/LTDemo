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
                'Object {0} is not found.',
                new List<String>{ objectName }
            ));
            return this;
        }

        public DatabaseException relationshipNotFound(String objectName) {
            this.setMessage(String.format(
                'Relationship {0} is not found.',
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

        public DatabaseException objectNotQueryable(String objectName) {
            this.setMessage(String.format(
                'Object {0} is not queryable.',
                new List<String>{ objectName }
            ));
            return this;
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
        private final String KEY_FILTER = 'filter';
        private final String KEY_FUNCTIONS = 'functions';
        private final String KEY_GROUPING = 'grouping';
        private final String KEY_SORT = 'sort';
        private final String KEY_OFFSET = 'offset';
        private final String KEY_LIMIT = 'limit';
        private final String KEY_OPTIONS = 'options';
        private final String KEY_CRUD = 'crud';
        private final String KEY_FLS = 'fls';
        private final String KEY_SHARING = 'sharing';
        private final String KEY_CHILDS = 'childs';

        private final String TEMPLATE_SELECT = 'SELECT {0} FROM {1}';
        private final String TEMPLATE_WHERE = 'WHERE {0}';
        private final String TEMPLATE_GROUPBY = 'GROUP BY {0}';
        private final String TEMPLATE_ORDERBY = 'ORDER BY {0}';
        private final String TEMPLATE_OFFSET = 'OFFSET {0}';
        private final String TEMPLATE_LIMIT = 'LIMIT {0}';
        private final String TEMPLATE_OPTIONS = '{0}';
        private final String TEMPLATE_CHILD = '({0})';

        private final String SEPARATOR_FIELDS = ', ';
        private final String SEPARATOR_CHILDS = '), (';

        private final String FIELD_ID = 'Id';

        // class variables

        private String queryObject;
        private DescribeSObjectResult parentDescribe;

        // class private properties

        private Boolean isChild {
            private get {
                return Utils.isNotNull(this.parentDescribe);
            }
        }

        private Boolean enforceCRUD {
            private get {
                if (Utils.isNull(this.enforceCRUD)) {
                    // get CRUD state from config
                    this.enforceCRUD = (
                        this.containsKey(this.KEY_CRUD) ?
                        Boolean.valueOf(this.get(this.KEY_CRUD)) :
                        true
                    );
                }
                return this.enforceCRUD;
            }
            private set;
        }

        private Boolean enforceFLS {
            private get {
                if (Utils.isNull(this.enforceFLS)) {
                    // get FLS state from config
                    this.enforceFLS = (
                        this.containsKey(this.KEY_FLS) ?
                        Boolean.valueOf(this.get(this.KEY_FLS)) :
                        true
                    );
                }
                return this.enforceFLS;
            }
            private set;
        }

        // class public properties

        public Boolean enforceSharing {
            private get {
                if (Utils.isNull(this.enforceSharing)) {
                    // get Sharing state from config
                    this.enforceSharing = (
                        this.containsKey(this.KEY_SHARING) ?
                        Boolean.valueOf(this.get(this.KEY_SHARING)) :
                        true
                    );
                }
                return this.enforceSharing;
            }
            private set;
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
                this.TEMPLATE_SELECT,
                new List<String> {
                    this.getQueryFields(queryObjectDescribe),
                    this.queryObject
                }
            );
            // add filters to the query
            resultQuery += this.getQueryFilter();
            // add grouping to the query
            resultQuery += this.getQueryGrouping();
            // add sort options to the query
            resultQuery += this.getQuerySort();
            // add limit to the query
            resultQuery += this.getQueryLimit();
            // add offset to the query
            resultQuery += this.getQueryOffset();
            // add options to the query
            resultQuery += this.getQueryOptions();
            // debug query string
            Utils.debug(DatabaseCtrl.class.getName(), resultQuery);
            // return query
            return resultQuery;
        }

        // class private methods

        private DescribeSObjectResult getObjectDescribe() {
            DescribeSObjectResult result;
            // get object name from config
            String configObject = String.valueOf(this.get(this.KEY_OBJECT));
            // validation for child queries
            if (this.isChild) {
                for (ChildRelationship child : this.parentDescribe.getChildRelationships()) {
                    String relationshipName = child.getRelationshipName();
                    if (String.isNotBlank(relationshipName) &&
                            relationshipName.equalsIgnoreCase(configObject)) {
                        // return related object describe
                        result = Utils.getDescribe(child.getChildSObject());
                        // store query object (child relationship)
                        this.queryObject = configObject;
                        break;
                    }
                }
                // show exception if relationship was not found
                if (Utils.isNull(result)) {
                    throw new DatabaseException().relationshipNotFound(configObject);
                }
            } else {
                // validation for parent queries
                if (Utils.getGlobalDescribe().containsKey(configObject)) {
                    // return original object describe
                    result = Utils.getDescribe(configObject);
                    // store query object (original object)
                    this.queryObject = result.getName();
                } else {
                    throw new DatabaseException().objectNotFound(configObject);
                }
            }
            // validate permission rights for the object
            if (!result.isQueryable()) {
                throw new DatabaseException().objectNotQueryable(result.getName());
            } else if (this.enforceCRUD && !result.isAccessible()) {
                throw new DatabaseException().objectNotAccessible(result.getName());
            }
            return result;
        }

        private String getQueryFields(DescribeSObjectResult objectDescribe) {
            // create a new list of fields
            List<String> queryFields = new List<String>();
            // parse config fields
            for (Object configField : (List<Object>)this.get(this.KEY_FIELDS)) {
                String currentConfigField = String.valueOf(configField).trim();
                // FLS validation
                if (!this.enforceFLS || Utils.isAccessible(currentConfigField, objectDescribe)) {
                    // add field to query
                    queryFields.add(currentConfigField);
                }
            }
            // get child queries
            String queryChilds = this.getQueryChilds(objectDescribe);
            // validate query fields
            if (queryFields.isEmpty()) {
                queryFields.add(this.FIELD_ID); // just add Id field for the query, because I don't want to throw exception for this case
            }
            // create result
            return String.join(queryFields, this.SEPARATOR_FIELDS) + (
                !queryFields.isEmpty() && String.isNotBlank(queryChilds) ?
                // add child queries to the main query as fields
                this.SEPARATOR_FIELDS + queryChilds :
                Utils.EMPTY_STRING
            );
        }

        private String getQueryChilds(DescribeSObjectResult objectDescribe) {
            String result = Utils.EMPTY_STRING;
            if (this.containsKey(this.KEY_CHILDS)) {
                // parse childs
                List<String> queryChilds = new List<String>();
                for (Object configChild : (List<Object>)this.get(this.KEY_CHILDS)) {
                    // add child query
                    queryChilds.add(new QueryConfig(configChild, objectDescribe).getQuery());
                }
                if (!queryChilds.isEmpty()) {
                    // set result
                    result = String.format(
                        this.TEMPLATE_CHILD,
                        new List<String> {
                            String.join(queryChilds, this.SEPARATOR_CHILDS)
                        }
                    );
                }
            }
            return result;
        }

        private String getQueryFilter() {
            return this.createQueryPart(
                this.KEY_FILTER,
                this.TEMPLATE_WHERE
            );
        }

        private String getQueryGrouping() {
            return this.createQueryPart(
                this.KEY_GROUPING,
                this.TEMPLATE_GROUPBY
            );
        }

        private String getQuerySort() {
            return this.createQueryPart(
                this.KEY_SORT,
                this.TEMPLATE_ORDERBY
            );
        }

        private String getQueryOffset() {
            return this.createQueryPart(
                this.KEY_OFFSET,
                this.TEMPLATE_OFFSET
            );
        }

        private String getQueryLimit() {
            return this.createQueryPart(
                this.KEY_LIMIT,
                this.TEMPLATE_LIMIT
            );
        }

        private String getQueryOptions() {
            return this.createQueryPart(
                this.KEY_OPTIONS,
                this.TEMPLATE_OPTIONS
            );
        }

        private String createQueryPart(String key, String template) {
            // create empty result
            String result = Utils.EMPTY_STRING;
            // validate the key
            if (this.containsKey(key)) {
                // get config part by the key
                String configPart = String.valueOf(this.get(key));
                // validate the part
                if (String.isNotBlank(configPart)) {
                    // create result
                    result = Utils.WHITESPACE + String.format(
                        template,
                        new List<String> {
                            configPart
                        }
                    );
                }
            }
            return result;
        }

    }

    /** 
      * @description Class to call Database methods without sharing.
      * @author Sergey Chepurnenko
    */
    private without sharing class DatabaseWithoutSharing {

        /**
          * @description Database.query() method without sharing.
          * @return List - records from a database.
        */
        public List<sObject> callQuery(String queryString) {
            return Database.query(queryString);
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
            // create query wrapper
            QueryConfig queryConfigWrapper = new QueryConfig(config);
            // create result
            result = JSON.serialize(
                // check sharing config
                queryConfigWrapper.enforceSharing ?
                // query with sharing
                Database.query(queryConfigWrapper.getQuery()) :
                // query without sharing
                new DatabaseWithoutSharing().callQuery(queryConfigWrapper.getQuery())
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
    	return result;
    }

}