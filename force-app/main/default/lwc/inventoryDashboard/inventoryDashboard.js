import { LightningElement, wire } from 'lwc';
import getDashboardData from '@salesforce/apex/InventoryDashboardController.getDashboardData'

export default class InventoryDashboard extends LightningElement {
    overviewMetrics = [];
    inventoryMetrics = [];
    patientPrescMetrics = [];
    dispensingMetrics = [];
    batchClinicMetrics = [];

    @wire(getDashboardData)
    wiredDashboard({ data, error }) {

        if (data) {
            this.inventoryMetrics=[
                    {label: 'TOTAL INVENTORY', value: data.totalInventory},
                    {label: 'LOW STOCK', value: data.lowStock},
                    {label: 'FROZEN STOCK', value: data.frozenInventory}
            ];
            this.patientPrescMetrics = [
                    {label:'TOTAL PATIENTS', value: data.totalPatients},
                    {label:'ACTIVE PATIENTS', value: data.activePatients},
                    {label:'ACTIVE PRESCRIPTIONS', value: data.activePresc}
            ];
            this.dispensingMetrics=[
                    {label: 'TOTAL DISPENSED', value: data.totalDispense},
                    {label: 'DISPENSED THIS MONTH', value: data.dispensedThisMonth}
            ];
            this.batchClinicMetrics=[
                    { label: 'TOTAL BATCHES', value: data.totalBatches },
                    { label: 'ACTIVE BATCHES', value: data.activeBatches},
                    { label: 'ACTIVE CLINICS', value: data.activeClinics}
            ]
            this.overviewMetrics=[
                ...this.inventoryMetrics,
                ...this.patientPrescMetrics,
                ...this.dispensingMetrics,
                ...this.batchClinicMetrics
            ];
        }

        if (error) {
            console.error(error);
        }
    }
}