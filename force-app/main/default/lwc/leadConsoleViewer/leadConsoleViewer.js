import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getLeadData from '@salesforce/apex/LeadConsoleController.getLeadDetails';
import checkExistingTask from '@salesforce/apex/LeadConsoleController.checkExistingTask';
import createFollowUpTask from '@salesforce/apex/LeadConsoleController.createFollowUpTask';

const COLOUMNS = [
    {
    label: 'Name',
    fieldName: 'leadUrl',
    type: 'url',
    typeAttributes: {
        label: { fieldName: 'Name' },
        target: '_self'
    }
},
    {label:"Annual Revenue" , fieldName:"AnnualRevenue", type:"currency"},
    {label:"Company" , fieldName:"Company", type:"text"},
    {label:"Rating" , fieldName:"Rating", type:"text"},
    {label:"Industry" , fieldName:"Industry", type:"text"},
    {label:"Status" , fieldName:"Status", type:"text"},
    {label:"Lead Source" , fieldName:"LeadSource", type:"text"},
    {label:"LastModifiedDate" , fieldName:"LastModifiedDate", type:"date"},
    {
    type: 'button',
    label: 'Create Task',
    typeAttributes: {
        label: 'Create Follow-Up Task',
        name: 'create_task',
        variant: 'brand-outline'
    }
}
];
export default class LeadConsoleViewer extends LightningElement {

    @api recordId;
    @track tableData = [];
    masterData = [];
    wiredLeadsResult;
    COLUMNS = COLOUMNS;
    showData = false;
    cardTitle = 'Lead Console View';
    selectedRatingValue;
    selectedStatusValue;

    statusOptions = [
        {label:"Open - Not Contacted",value:"Open - Not Contacted"},
        {label:"Working - Contacted",value:"Working - Contacted"},
        {label:"Closed - Converted",value:"Closed - Converted"},
        {label:"Closed - Not Converted",value:"Closed - Not Converted"}

    ];


    @wire(getLeadData)
    wiredLeads(result) {
        this.wiredLeadsResult = result;

        if (result.data) {
            this.tableData = result.data.map(lead => ({
                ...lead,
                leadUrl: `/lightning/r/Lead/${lead.Id}/view`
            }));

            this.masterData = [...this.tableData];
            this.showData = true;
        } else if (result.error) {
            console.log('Error: ' + JSON.stringify(result.error));
        }
    }

    handleRatingFilterValue(event){
        this.selectedRatingValue = event.detail.value;
        //call filteredData
        this.filteredData();
    }

    handleStatusChange(event){
        this.selectedStatusValue = event.detail.value;
        // call filteredData
        this.filteredData();
    }

    filteredData(){
        const rating = (this.selectedRatingValue || '').trim().toLowerCase();
        const status = this.selectedStatusValue || '';
        this.tableData = this.masterData.filter(lead =>{
        const ratingMatch =
            !rating ||
            (lead.Rating && lead.Rating.toLowerCase() === rating);

        const statusMatch =
            !status ||
            lead.Status === status;

        return ratingMatch && statusMatch;
    });
    }

    handleResetData(){
        this.selectedRatingValue = '';
        this.selectedStatusValue = '';
        this.tableData = this.masterData;
    }

    handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    if (actionName === 'create_task') {
        const leadId = row.Id;
        checkExistingTask({leadId : leadId})
        .then((result =>{
            if(result){
                this.showErrorToast('A follow-up task already exists for this Lead.');
                return;
            }
            else{
                // call Apex here
                createFollowUpTask({leadId : leadId})
                .then((result =>{
                    console.log('Successfully created');
                    this.showSuccessToast('Follow-up task created successfully.');
                })).catch(error =>{
                    console.log('Error in creattion : ' +error);
                    this.showErrorToast('Something Went Wrong! Please Contact your Administrator.');
                });
            }
        })).catch((error =>{
            console.log('Error in row action : ' +JSON.stringify(error));
            this.showErrorToast('Something Went Wrong! Please Contact your Administrator.');
        }))
        
        }
    }

    handleRefreshData(){
        this.selectedRatingValue = '';
        this.selectedStatusValue = '';
        refreshApex(this.wiredLeadsResult);
    }

    showSuccessToast(message) {
    const event = new ShowToastEvent({
        title: 'Success',
        message: message,
        variant: 'success'
    });
    this.dispatchEvent(event);
}

showErrorToast(message) {
    const event = new ShowToastEvent({
        title: 'Error',
        message: message,
        variant: 'error'
    });
    this.dispatchEvent(event);
}
}