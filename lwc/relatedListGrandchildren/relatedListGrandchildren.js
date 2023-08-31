import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import grandchildren from '@salesforce/apex/RelatedListGrandchildren_LWC.grandchildren';

export default class RelatedListGrandchildren extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api recordId;

    @api title;
    @api iconName;
    @api objectName;
    @api grandChildToChildLookup;
    @api childToParentLookup;
    @api objectRelationToRecord;
    @api fieldsCSV;
    @api nameReplacement;
    @api filter;
    @api extraSOQL;
    @api compact   = false;
    @api editable  = false;
    @api enableNew = false;
    @api newDefaultFieldsString;

    initialRecordDisplayCount = 3;
    initialWrappers;
    restOfWrappers;

    showAll = false;

    get showViewAll() { return !this.showAll && this.restOfWrappers && this.restOfWrappers.length > 0; }

    get density() { return this.compact  ? 'compact' : 'auto'; }
    get mode()    { return this.editable ? 'view'    : 'readonly'; }

    get fields() {return this.fieldsCSV ? this.fieldsCSV.replace(/\s+/g, '').split(',') : [];}

    connectedCallback() {
        grandchildren({ object_name: this.objectName,
                        grandchild_to_child_lookup: this.grandChildToChildLookup,
                        child_to_parent_lookup: this.childToParentLookup,
                        parent_id: this.recordId,
                        object_relation_to_record: this.objectRelationToRecord,
                        fields_csv: this.fieldsCSV,
                        name_replacement: this.nameReplacement,
                        filter: this.filter,
                        extra_soql: this.extraSOQL })
            .then(records => {
                this.restOfWrappers = records;
                this.initialWrappers = this.restOfWrappers.splice(0, this.initialRecordDisplayCount);
            })
    }

    viewAll() { this.showAll = true; }


    navigateToRecordViewPage(event) {
        event.preventDefault();
        event.stopPropagation();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                actionName: 'view'
            }
        });
    }

    navigateToNewObjectPage(event) {
        event.preventDefault();
        event.stopPropagation();

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: this.objectName,
                actionName: 'new'
            },
            state: {
                defaultFieldValues: this.newDefaultFieldsString?.replaceAll('THIS-RECORD-ID', this.recordId),
                nooverride: '1'
            }
        });
    }


}
