public without sharing class RelatedListGrandchildren_LWC {

    public class RecordWrapper {
        @AuraEnabled public SObject record;
        @AuraEnabled public String  displayName;

        public RecordWrapper(SObject record, Object name) {
            this.record  = record;
            displayName = String.valueOf(name);
            if (String.isBlank(displayName)) {displayName = 'Name Unknown';}
        }
    }

    @AuraEnabled
    public static RecordWrapper[] grandchildren(String object_name, String grandchild_to_child_lookup, String child_to_parent_lookup, String parent_id, String object_relation_to_record, String fields_csv, String name_replacement, String filter, String extra_soql) {
        try {
            RecordWrapper[] wrappers = new RecordWrapper[]{};
            String name_field = String.isBlank(name_replacement) ? 'Name' : name_replacement;

            String ancestor_relationship = object_relation_to_record == null ? lookup_field_as_relation(grandchild_to_child_lookup) + '.' + child_to_parent_lookup : object_relation_to_record;

            String query = 'SELECT ' + fields_string_with_id_and_name(fields_csv, name_field) +
                            ' FROM ' + object_name +
                           ' WHERE ' + ancestor_relationship + ' = \'' + parent_id + '\'';

            if (String.isNotBlank(filter))     {query += ' AND (' + filter.removeStartIgnoreCase('WHERE') + ')';}
            if (String.isNotBlank(extra_soql)) {query += ' ' + extra_soql;}

            SObject[] records = Database.query(query);

            for (SObject record : records) {
                wrappers.add(new RecordWrapper(record, Utilities.related_field(record, name_field)));
            }

            return wrappers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
        private static String fields_string_with_id_and_name(String fields_csv, String name_field) {
            Set<String> fields = new Set<String>{'Id', name_field};
            fields.addAll(fields_csv.deleteWhitespace().split(','));

            return String.join(new List<String>(fields), ', ');
        }
        private static String lookup_field_as_relation(String field) {
            if (field.endsWith('Id')) {
                field = field.removeEnd('Id');
            }
            else if (field.endsWith('__c')) {
                field = field.removeEnd('c');
                field += 'r';
            }
            return field;
        }
}