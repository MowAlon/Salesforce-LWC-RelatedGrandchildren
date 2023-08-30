public abstract class Utilities {

    public static String random_string(Integer count) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String random_string = '';
        while (random_string.length() < count) {
            Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            random_string += chars.substring(index, index + 1);
        }
        return random_string;
    }

    public static String[] picklist_values(String object_name, String field_name) {
        Map<String, String> labels_by_api_name = picklist_labels_by_api_name(object_name, field_name);
        return new List<String>(labels_by_api_name.keySet());
    }
        public static String first_picklist_value(String object_name, String field_name) {return picklist_values(object_name, field_name)[0];}

    public static String[] picklist_labels(String object_name, String field_name) {
        Map<String, String> labels_by_api_name = picklist_labels_by_api_name(object_name, field_name);
        return new List<String>(labels_by_api_name.values());
    }

    public static Map<String, String> picklist_labels_by_api_name(String object_name, String field_name) {
        Map<String, String> labels_by_api_name = new Map<String, String>{};
        String[] types  = new String[]{object_name};
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {labels_by_api_name.put(entry.getValue(), entry.getLabel());}
            }
        }
        return labels_by_api_name;
    }

    public static Schema.DescribeFieldResult field_info(String object_name, String field_name) {
        return field_map(object_name).get(field_name).getDescribe();
    }
    public static Map<String,Schema.SObjectField> field_map(String object_name) {
        return ((SObject)Type.forName('', object_name).newInstance()).getSObjectType().getDescribe().fields.getMap();
    }

    public static Schema.SOAPType field_soap_type(String object_name, String field_name) {return field_info(object_name, field_name).getSOAPType();}

    public static Object field_value_from_string(String object_name, String field_name, Object value) {
        if (value instanceOf String) {
            switch on field_soap_type(object_name, field_name) {
                when Boolean         {return Boolean.valueOf(value);}
                when Date            {return Date.valueOf((String)value);}
                when DateTime        {return Datetime.newInstance(date_from_datetime_string((String)value), time_from_datetime_string((String)value));}
                when Double, Integer {return Decimal.valueOf((String)value);}
                when Time            {return time_from_time_string((String)value);}
                when else            {return value;}
            }
        } else {return value;}
    }
        public static Date date_from_datetime_string(String datetime_string) {
            // Return an Apex Date from something like 1979-02-20T22:20:00.000Z
            return Date.valueOf(datetime_string.split('T')[0]);
        }
        public static Time time_from_datetime_string(String datetime_string) {
            return time_from_time_string(time_string_from_datetime_string(datetime_string));
        }
            public static String time_string_from_datetime_string(String datetime_string) {
            return datetime_string.split('T')[1].removeEnd('Z');
            }
        public static Time time_from_time_string(String time_string) {
            // Returns an Apex Time from something like 1979-02-20T22:20:00.000Z
            String[] parts        = time_string.split(':');
            String[] second_parts = parts[2].split('\\.');
            return Time.newInstance(Integer.valueOf(parts[0]), Integer.valueOf(parts[1]), Integer.valueOf(second_parts[0]), Integer.valueOf(second_parts[1]));
        }

    public static String child_relationship_name(String parent_sobject, String child_object, String lookup_field_to_parent) {
        for(Schema.ChildRelationship relationship : ((SObject)Type.forName('', parent_sobject).newInstance()).getSObjectType().getDescribe().getChildRelationships()) {
            if(String.valueOf(relationship.getChildSObject()) == child_object && String.valueOf(relationship.getField()) == lookup_field_to_parent){
                return relationship.getRelationshipName();
            }
        }

        return null;
    }

   public static Object related_field(sObject an_sobject, String target_field) {
      // This is a recursive method that returns a related field from a generic sObject... like the Name of the Manager of the Owner of a record.
      // If any sObject along the way is null, it returns null.
      // an_sobject is any sObject with or without related sObjects
      // target_field is the SOQL-formatted reference to a field, as it would be reference from an_sobject...
      //    For example, if you have an Opportunity and want its Account's Owner's Manager's Name,
      //    an_sobject is the Opportunity record and "Account.Owner.Manager.Name" is the target_field

      if (an_sobject != null) {
         Integer characters_left_of_dot = target_field.indexOf('.');
         Boolean has_related_sobject    = characters_left_of_dot != -1;

         if (has_related_sobject) {
            String next_related_sobject = target_field.left(characters_left_of_dot);
            return related_field(an_sobject.getSObject(next_related_sobject), target_field.substring(characters_left_of_dot + 1));
         } else {
            return an_sobject.get(target_field);
         }
      } else {return null;}
   }

}