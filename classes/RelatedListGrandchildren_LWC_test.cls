@isTest
public class RelatedListGrandchildren_LWC_test {

    @isTest static void test_standard_objects() {
        Account account1 = TestData.account(false);
        Account account2 = TestData.account(false);
        insert new Account[]{account1, account2};

        Contact contact1 = new Contact(AccountId = account1.Id, FirstName = 'First1', LastName = 'Last1');
        Contact contact2 = new Contact(AccountId = account1.Id, FirstName = 'First2', LastName = 'Last2');
        Contact contact3 = new Contact(AccountId = account2.Id, FirstName = 'First3', LastName = 'Last3');
        Contact contact4 = new Contact(AccountId = account2.Id, FirstName = 'Bad'   , LastName = 'Last4');
        Contact[] contacts = new Contact[]{contact1, contact2, contact3, contact4};
        insert contacts;
        Map<Id, Contact> contacts_by_id = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, AccountId FROM Contact WHERE Id IN :contacts]);

        String object_name                = 'Contact';
        String grandchild_to_child_lookup = 'AccountId';
        String child_to_parent_lookup     = 'OwnerId';
        String parent_id                  = UserInfo.getUserId();
        String object_relation_to_record  = null;
        String fields_csv                 = 'FirstName, LastName';
        String name_replacement           = null;
        String filter                     = 'FirstName LIKE \'%First%\'';
        String extra_soql                 = null;

        RelatedListGrandchildren_LWC.RecordWrapper[] wrappers = RelatedListGrandchildren_LWC.grandchildren(object_name, grandchild_to_child_lookup, child_to_parent_lookup, parent_id, object_relation_to_record, fields_csv, name_replacement, filter, extra_soql);

        System.assertEquals(3, wrappers.size());
        for (RelatedListGrandchildren_LWC.RecordWrapper wrapper : wrappers) {
            System.assertNotEquals(null, wrapper.record.Id);
            System.assertEquals(contacts_by_id.get(wrapper.record.Id).Name, wrapper.displayName);
            System.assert(((String)wrapper.record.get('FirstName')).startsWith('First'));
            System.assert(((String)wrapper.record.get('LastName')).startsWith('Last'));
        }
    }

    // @isTest static void test_custom_objects_and_deep_relationship() {
    //     /* This is an intentionally complicated scenario... imagine a schema like this one with each line representing a level of ancestral/lookup relationship.
    //         We want to display a list of records related to a User through two extra layers of relationship AND we want to use the grandchild object's record's names to replace the great grandchild name in the list

    //         User (where you want to display the component showing a list of grandchild records)
    //         Account (the "child" level)
    //         Grandchild
    //         Great Grandchild
    //     */
    
    //     Account account1 = TestData.account(false);
    //     Account account2 = TestData.account(false);
    //     insert new Account[]{account1, account2};

    //     Grandchild__c grandchild_1 = new Grandchild__c(Account__c = account1.Id);
    //     Grandchild__c grandchild_2 = new Grandchild__c(Account__c = account2.Id);
    //     insert new Grandchild__c[]{grandchild_1, grandchild_2};
    //     Map<Id, Grandchild__c> grandchildren_by_id = new Map<Id, Grandchild__c>([SELECT Id, Name FROM Grandchild__c]);

    //     Great_Grandchild__c great_gc_1 = new Great_Grandchild__c(Grandchild__c = grandchild_1.Id);
    //     Great_Grandchild__c great_gc_2 = new Great_Grandchild__c(Grandchild__c = grandchild_2.Id);
    //     Great_Grandchild__c great_gc_3 = new Great_Grandchild__c(Grandchild__c = grandchild_1.Id);
    //     Great_Grandchild__c great_gc_4 = new Great_Grandchild__c(Grandchild__c = grandchild_2.Id);
    //     Great_Grandchild__c[] great_grandchildren = new Great_Grandchild__c[]{great_gc_1, great_gc_2, great_gc_3, great_gc_4};
    //     insert great_grandchildren;

    //     String object_name                = 'Great_Grandchild__c';
    //     String grandchild_to_child_lookup = null;
    //     String child_to_parent_lookup     = null;
    //     String parent_id                  = UserInfo.getUserId();
    //     String object_relation_to_record  = 'Grandchild__r.Account__r.OwnerId';
    //     String fields_csv                 = 'Grandchild__c';
    //     String name_replacement           = 'Grandchild__r.Name';
    //     String filter                     = null;
    //     String extra_soql                 = null;

    //     RelatedListGrandchildren_LWC.RecordWrapper[] wrappers = RelatedListGrandchildren_LWC.grandchildren(object_name, grandchild_to_child_lookup, child_to_parent_lookup, parent_id, object_relation_to_record, fields_csv, name_replacement, filter, extra_soql);

    //     System.assertEquals(4, wrappers.size());
    //     for (RelatedListGrandchildren_LWC.RecordWrapper wrapper : wrappers) {
    //         System.assertNotEquals(null, wrapper.record.Id);
    //         System.assertEquals(grandchildren_by_id.get((Id)wrapper.record.get('Grandchild__c')).Name, wrapper.displayName);
    //     }
    // }

}