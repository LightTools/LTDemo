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
      * @description This class is an abstract wrapper for other DML configs.
      * @author Sergey Chepurnenko
    */
    private abstract class DMLConfig extends Wrapper {

        // class constants

        private final String KEY_CRUD = 'crud';
        private final String KEY_FLS = 'fls';
        private final String KEY_SHARING = 'sharing';

        // class private properties

        private Boolean enforceCRUD {
            private get {
                if (Utils.isNull(this.enforceCRUD)) {
                    // get CRUD state from config
                    this.enforceCRUD = (
                        this.containsKey(this.KEY_CRUD) ?
                        this.getBoolean(this.KEY_CRUD) :
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
                        this.getBoolean(this.KEY_FLS) :
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
                        this.getBoolean(this.KEY_SHARING) :
                        true
                    );
                }
                return this.enforceSharing;
            }
            private set;
        }

        // class constructors

        /**
          * @description Constructor with param.
          * @param Object source - instance of Map.
        */
        public DMLConfig(Object config) {
            super(config);
        }

        /**
          * @description Constructor with param.
          * @param String source - serialized javascript object.
        */
        public DMLConfig(String config) {
            super(config);
        }

    }

    /** 
      * @description This class is a wrapper for query config.
      * @author Sergey Chepurnenko
    */
    private class QueryConfig extends DMLConfig {

        // class constants

        private final String KEY_OBJECT = 'object';
        private final String KEY_ENTITIES = 'entities';
        private final String KEY_FIELDS = 'fields';
        private final String KEY_GROUP = 'group';
        private final String KEY_FILTER = 'filter';
        private final String KEY_FUNCTIONS = 'functions';
        private final String KEY_GROUPING = 'grouping';
        private final String KEY_SORT = 'sort';
        private final String KEY_OFFSET = 'offset';
        private final String KEY_LIMIT = 'limit';
        private final String KEY_OPTIONS = 'options';
        private final String KEY_CHILDS = 'childs';

        private final String TEMPLATE_SELECT = 'SELECT {0} FROM {1}';
        private final String TEMPLATE_FIND = 'FIND {0}{1}{2} IN {3} FIELDS RETURNING';
        private final String TEMPLATE_WHERE = 'WHERE {0}';
        private final String TEMPLATE_GROUPBY = 'GROUP BY {0}';
        private final String TEMPLATE_ORDERBY = 'ORDER BY {0}';
        private final String TEMPLATE_OFFSET = 'OFFSET {0}';
        private final String TEMPLATE_LIMIT = 'LIMIT {0}';
        private final String TEMPLATE_OPTIONS = '{0}';
        private final String TEMPLATE_CHILD = '({0})';
        private final String TEMPLATE_ENTITY = '({0})';

        private final String SEPARATOR_FIELDS = ', ';
        private final String SEPARATOR_OBJECTS = ', ';
        private final String SEPARATOR_CHILDS = '), (';
        private final String SEPARATOR_QUOTES = '\'';

        private final String FIELD_ID = 'Id';

        // class variables

        private String queryObject;
        private Schema.DescribeSObjectResult parentDescribe;

        // class properties

        private Boolean isChild {
            private get {
                return Utils.isNotNull(this.parentDescribe);
            }
        }

        // class constructors

        /**
          * @description Constructor for child queries.
          * @param Object source - instance of Map.
          * @param Schema.DescribeSObjectResult parentDescribe - describe of parent object.
        */
        public QueryConfig(Object config, Schema.DescribeSObjectResult parentDescribe) {
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
        public String getSOQLQuery() {
            // get object describe for query
            Schema.DescribeSObjectResult queryObjectDescribe = this.getObjectDescribe();
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

        /**
          * @description Method to get dynamic query for Search.query() method.
          * @return String - query string.
        */
        public String getSOSLQuery() {
            // create result query
            String resultQuery = String.format(
                this.TEMPLATE_FIND,
                new List<String> {
                    // search filter
                    this.SEPARATOR_QUOTES,
                    this.createQueryPart(
                        this.KEY_FILTER,
                        this.TEMPLATE_OPTIONS
                    ).trim(),
                    this.SEPARATOR_QUOTES,
                    // search group
                    this.createQueryPart(
                        this.KEY_GROUP,
                        this.TEMPLATE_OPTIONS
                    )
                }
            );
            // add search entities to the query
            resultQuery += this.getSearchEntities();
            // add options to the query
            resultQuery += this.getQueryOptions();
            // debug query string
            Utils.debug(DatabaseCtrl.class.getName(), resultQuery);
            // return query
            return resultQuery;
        }

        // class private methods

        private Schema.DescribeSObjectResult getObjectDescribe() {
            Schema.DescribeSObjectResult result;
            // get object name from config
            String configObject = this.getString(this.KEY_OBJECT);
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

        private String getQueryFields(Schema.DescribeSObjectResult objectDescribe) {
            // create a new list of fields
            List<String> queryFields = new List<String>();
            if (this.containsKey(this.KEY_FIELDS)) {
                // get functions from config
                Wrapper configFunctions = this.getWrapper(this.KEY_FUNCTIONS);
                // parse config fields
                for (Object configField : this.getList(this.KEY_FIELDS)) {
                    String currentConfigField = String.valueOf(configField).trim();
                    // FLS validation
                    if (!this.enforceFLS || Utils.isAccessible(currentConfigField, objectDescribe)) {
                        // get function for current field
                        if (configFunctions.containsKey(currentConfigField)) {
                            // wrap field
                            currentConfigField = String.format(
                                configFunctions.getString(currentConfigField),
                                new List<String> {
                                    String.escapeSingleQuotes(currentConfigField)
                                }
                            );
                        }
                        // add field to query
                        queryFields.add(currentConfigField);
                    }
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

        private String getQueryChilds(Schema.DescribeSObjectResult objectDescribe) {
            String result = Utils.EMPTY_STRING;
            if (this.containsKey(this.KEY_CHILDS)) {
                // parse childs
                List<String> queryChilds = new List<String>();
                for (Object configChild : this.getList(this.KEY_CHILDS)) {
                    // add child query
                    queryChilds.add(new QueryConfig(configChild, objectDescribe).getSOQLQuery());
                }
                if (!queryChilds.isEmpty()) {
                    // create result
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
                String configPart = this.getString(key);
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

        private String getSearchEntities() {
            // create a new list of entities
            List<String> searchEntities = new List<String>();
            if (this.containsKey(this.KEY_ENTITIES)) {
                for (Object configEntity : this.getList(this.KEY_ENTITIES)) {
                    if (Utils.isNotNull(configEntity)) {
                        searchEntities.add(this.createSearchEntity(
                            new Wrapper(configEntity)
                        ));
                    }
                }
            }
            // create result
            return Utils.WHITESPACE + String.join(searchEntities, this.SEPARATOR_OBJECTS);
        }

        private String createSearchEntity(Wrapper config) {
            Schema.DescribeSObjectResult objectDescribe;
            // get object name from config
            String configObject = config.getString(this.KEY_OBJECT);
            // validate entity object
            if (Utils.getGlobalDescribe().containsKey(configObject)) {
                objectDescribe = Utils.getDescribe(configObject);
            } else {
                throw new DatabaseException().objectNotFound(configObject);
            }
            // validate permission rights for the object
            if (!objectDescribe.isQueryable()) {
                throw new DatabaseException().objectNotQueryable(objectDescribe.getName());
            } else if (this.enforceCRUD && !objectDescribe.isAccessible()) {
                throw new DatabaseException().objectNotAccessible(objectDescribe.getName());
            }
            // validate entity fields
            List<String> entityFields = new List<String>();
            if (config.containsKey(this.KEY_FIELDS)) {
                // get functions from config
                Wrapper configFunctions = config.getWrapper(this.KEY_FUNCTIONS);
                // parse config fields
                for (Object configField : config.getList(this.KEY_FIELDS)) {
                    String currentConfigField = String.valueOf(configField).trim();
                    // FLS validation
                    if (!this.enforceFLS || Utils.isAccessible(currentConfigField, objectDescribe)) {
                        // get function for current field
                        if (configFunctions.containsKey(currentConfigField)) {
                            // wrap field
                            currentConfigField = String.format(
                                configFunctions.getString(currentConfigField),
                                new List<String> {
                                    String.escapeSingleQuotes(currentConfigField)
                                }
                            );
                        }
                        // add current field to 
                        entityFields.add(currentConfigField);
                    }
                }
            }
            // create result
            return objectDescribe.getName() + (
                !entityFields.isEmpty() ? String.format(
                    this.TEMPLATE_ENTITY,
                    new List<String> {
                        // add entity fields and options to result
                        String.join(entityFields, SEPARATOR_FIELDS) + this.createQueryPart(
                            this.KEY_OPTIONS,
                            this.TEMPLATE_OPTIONS
                        )
                    }
                ) : Utils.EMPTY_STRING
            );
        }
    }

    /** 
      * @description Describe config parser and wrapper.
      * @author Sergey Chepurnenko
    */
    private class DescribeConfig extends Wrapper {

        // class constants

        private final String KEY_NAME = 'name';       
        private final String KEY_LOCAL_NAME = 'localName';
        private final String KEY_LABEL = 'label';
        private final String KEY_LABEL_PLURAL = 'labelPlural';
        private final String KEY_CHILD_RELATIONSHIPS = 'childRelationships';
        private final String KEY_FIELDS = 'fields';
        private final String KEY_TYPE = 'type';
        private final String KEY_LENGTH = 'length';
        private final String KEY_DIGITS = 'digits';
        private final String KEY_SCALE = 'scale';
        private final String KEY_CALCULATED_FORMULA = 'calculatedFormula';
        private final String KEY_CONTROLLER = 'controller';
        private final String KEY_DEFAULT_VALUE = 'defaultValue';
        private final String KEY_DEFAULT_VALUE_FORMULA = 'defaultValueFormula';
        private final String KEY_INLINE_HELP_TEXT = 'inlineHelpText';
        private final String KEY_RELATIONSHIP_NAME = 'relationshipName';
        private final String KEY_REFERENCE_TO = 'referenceTo';
        private final String KEY_PICKLIST_VALUES = 'picklistValues';
        private final String KEY_IS_AUTONUMBER = 'isAutoNumber';
        private final String KEY_IS_CALCULATED = 'isCalculated';
        private final String KEY_IS_CASE_SENSITIVE = 'isCaseSensitive';
        private final String KEY_IS_FILTERABLE = 'isFilterable';
        private final String KEY_IS_GROUPABLE = 'isGroupable';
        private final String KEY_IS_NAME_FIELD = 'isNameField';
        private final String KEY_IS_NILLABLE = 'isNillable';
        private final String KEY_IS_SORTABLE = 'isSortable';
        private final String KEY_IS_UNIQUE = 'isUnique';
        private final String KEY_IS_SEARCH_PREFILTERABLE = 'isSearchPrefilterable';
        private final String KEY_IS_DEPENDENT_PICKLIST = 'isDependentPicklist';
        private final String KEY_IS_RESTRICTED_PICKLIST = 'isRestrictedPicklist';
        private final String KEY_IS_CUSTOM = 'isCustom';
        private final String KEY_IS_CUSTOM_SETTING = 'isCustomSetting';
        private final String KEY_IS_QUERYABLE = 'isQueryable';
        private final String KEY_IS_ACCESSIBLE = 'isAccessible';
        private final String KEY_IS_CREATEABLE = 'isCreateable';
        private final String KEY_IS_UPDATEABLE = 'isUpdateable';
        private final String KEY_IS_DELETABLE = 'isDeletable';

        // class constructors

        /**
          * @description Constructor with param.
          * @param String source - serialized javascript object.
        */
        public DescribeConfig(String config) {
            // if config is defined
            if (String.isNotBlank(config)) {
                // create describe for defined objects
                for (Object configObject : (List<Object>)JSON.deserializeUntyped(config)) {
                    this.createDescribeConfig(String.valueOf(configObject));
                }
            }
        }

        // class private methods

        private void createDescribeConfig(String objectName) {
            // if object exists
            if (Utils.getGlobalDescribe().containsKey(objectName)) {
                // get describe by object name
                Schema.DescribeSObjectResult objectDescribe = Utils.getDescribe(objectName);
                // create describe config for the object
                this.set(objectName, new Map<String, Object> {
                    this.KEY_NAME => objectDescribe.getName(),
                    this.KEY_LOCAL_NAME => objectDescribe.getLocalName(),
                    this.KEY_LABEL => objectDescribe.getLabel(),  
                    this.KEY_LABEL_PLURAL => objectDescribe.getLabelPlural(),
                    this.KEY_CHILD_RELATIONSHIPS => objectDescribe.getChildRelationships(),
                    this.KEY_FIELDS => this.getFieldsDescribeConfig(objectDescribe),
                    this.KEY_IS_CUSTOM => objectDescribe.isCustom(),
                    this.KEY_IS_CUSTOM_SETTING => objectDescribe.isCustomSetting(),
                    this.KEY_IS_QUERYABLE => objectDescribe.isQueryable(),
                    this.KEY_IS_ACCESSIBLE => objectDescribe.isAccessible(),
                    this.KEY_IS_CREATEABLE => objectDescribe.isCreateable(),
                    this.KEY_IS_UPDATEABLE => objectDescribe.isUpdateable(),
                    this.KEY_IS_DELETABLE => objectDescribe.isDeletable()
                });
            } else {
                throw new DatabaseException().objectNotFound(objectName);
            }
        }

        private Map<String, Object> getFieldsDescribeConfig(Schema.DescribeSObjectResult objectDescribe) {
            // create empty result
            Map<String, Object> result = new Map<String, Object>();
            // create config for each field
            for (Schema.SObjectField field : objectDescribe.fields.getMap().values()) {
                // get field describe
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                // create field config and add the config to result
                result.put(fieldDescribe.getName(), new Map<String, Object> {
                    this.KEY_NAME => fieldDescribe.getName(),
                    this.KEY_LOCAL_NAME => fieldDescribe.getLocalName(),
                    this.KEY_LABEL => fieldDescribe.getLabel(),  
                    this.KEY_TYPE => fieldDescribe.getType(),
                    this.KEY_LENGTH => fieldDescribe.getLength(),
                    this.KEY_DIGITS => fieldDescribe.getDigits(),
                    this.KEY_SCALE => fieldDescribe.getScale(),
                    this.KEY_CALCULATED_FORMULA => fieldDescribe.getCalculatedFormula(),
                    this.KEY_CONTROLLER => fieldDescribe.getController(),
                    this.KEY_DEFAULT_VALUE => fieldDescribe.getDefaultValue(),
                    this.KEY_DEFAULT_VALUE_FORMULA => fieldDescribe.getDefaultValueFormula(),
                    this.KEY_INLINE_HELP_TEXT => fieldDescribe.getInlineHelpText(),
                    this.KEY_RELATIONSHIP_NAME => fieldDescribe.getRelationshipName(),
                    this.KEY_REFERENCE_TO => this.getFieldReferences(fieldDescribe),
                    this.KEY_PICKLIST_VALUES => fieldDescribe.getPicklistValues(),
                    this.KEY_IS_AUTONUMBER => fieldDescribe.isAutoNumber(),
                    this.KEY_IS_CALCULATED => fieldDescribe.isCalculated(),
                    this.KEY_IS_CASE_SENSITIVE => fieldDescribe.isCaseSensitive(),
                    this.KEY_IS_FILTERABLE => fieldDescribe.isFilterable(),
                    this.KEY_IS_GROUPABLE => fieldDescribe.isGroupable(),
                    this.KEY_IS_NAME_FIELD => fieldDescribe.isNameField(),
                    this.KEY_IS_NILLABLE => fieldDescribe.isNillable(),
                    this.KEY_IS_SORTABLE => fieldDescribe.isSortable(),
                    this.KEY_IS_UNIQUE => fieldDescribe.isUnique(),
                    this.KEY_IS_SEARCH_PREFILTERABLE => fieldDescribe.isSearchPrefilterable(),
                    this.KEY_IS_DEPENDENT_PICKLIST => fieldDescribe.isDependentPicklist(),
                    this.KEY_IS_RESTRICTED_PICKLIST => fieldDescribe.isRestrictedPicklist(),
                    this.KEY_IS_CUSTOM => fieldDescribe.isCustom(),
                    this.KEY_IS_ACCESSIBLE => fieldDescribe.isAccessible(),
                    this.KEY_IS_CREATEABLE => fieldDescribe.isCreateable(),
                    this.KEY_IS_UPDATEABLE => fieldDescribe.isUpdateable()
                });
            }
            return result;
        }

        private List<String> getFieldReferences(Schema.DescribeFieldResult fieldDescribe) {
            List<String> result = new List<String>();
            // get all references and convert values to strings
            // because SObjectType class in not supported in JSON
            for (Schema.SObjectType objectType : fieldDescribe.getReferenceTo()) {
                result.add(String.valueOf(objectType));
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
          * @return Object - result from a database.
        */
        public Object callQuery(String queryString) {
            return Database.query(queryString);
        }

        /**
          * @description Search.query() method without sharing.
          * @return Object - result from a database.
        */
        public Object callSearch(String queryString) {
            return Search.query(queryString);
        }

    } 

    // class methods

    /**
      * @description Method to get SObject describe.
      * @param String config - serialized javascript object. This object should contain object names.
      * @return String - serialized javascript object with describe results.
    */
    @AuraEnabled
    public static String describe(String config) {
        String result;
        try {
            // create result
            result = new DescribeConfig(config).toJSON();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
        return result;
    }

    /**
      * @description Method to build SOQL query string.
      * @param String config - serialized javascript object. This object should contain object name, object fields and query conditions for SOQL.
      * @return String - serialized javascript object with SOQL results.
    */
    @AuraEnabled
    public static String buildSOQL(String config) {
        String result;
        try {
            // create result
            result = new QueryConfig(config).getSOQLQuery();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
        return result;
    }

    /**
      * @description Method to build SOSL query string.
      * @param String config - serialized javascript object. This object should contain object name, object fields and query conditions for SOQL.
      * @return String - serialized javascript object with SOQL results.
    */
    @AuraEnabled
    public static String buildSOSL(String config) {
        String result;
        try {
            // create result
            result = new QueryConfig(config).getSOSLQuery();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
        return result;
    }

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
                Database.query(queryConfigWrapper.getSOQLQuery()) :
                // query without sharing
                new DatabaseWithoutSharing().callQuery(queryConfigWrapper.getSOQLQuery())
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
    	return result;
    }

    /**
      * @description Method to search records in database using SOSL query.
      * @param String config - serialized javascript object.
      * @return String - serialized javascript object with SOSL results.
    */
    @AuraEnabled
    public static String search(String config) {
        String result;
        try {
            // create query wrapper
            QueryConfig queryConfigWrapper = new QueryConfig(config);
            // create result
            result = JSON.serialize(
                // check sharing config
                queryConfigWrapper.enforceSharing ?
                // query with sharing
                Search.query(queryConfigWrapper.getSOSLQuery()) :
                // query without sharing
                new DatabaseWithoutSharing().callSearch(queryConfigWrapper.getSOSLQuery())
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
        return result;
    }

}