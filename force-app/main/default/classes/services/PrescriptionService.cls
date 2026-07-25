public with sharing class PrescriptionService {
    public static void dateValidation(List<Prescription__c> newPrescriptions){
        for(Prescription__c p: newPrescriptions){
            if(p.Expiry_Date__c<Date.today()){ //Validate expiry date.
                p.Expiry_Date__c.addError('Expiry Date cannot be in the past.');
            }
        }
    }
    
    public static void defaultPrescriptionValue(List<Prescription__c> newPrescriptions){
        for(Prescription__c p: newPrescriptions){
            if(p.Prescription_Date__c==null){ //Default prescription date to Today.
                p.Prescription_Date__c=Date.today();
            }
            p.Refills_Used__c=0;
        }
    }
    
    public static void validatePrescriptionQuantity(List<Prescription__c> newPrescriptions){
        for(Prescription__c p : newPrescriptions){ //Validate prescription quantity.
            if(p.Prescribed_Quantity__c != null && p.Prescribed_Quantity__c < 0){
                p.Prescribed_Quantity__c.addError('Prescribed quantity cannot be negative.');
            }

            if(p.Prescribed_Quantity__c != null && p.Prescribed_Quantity__c > 1000){
                p.Prescribed_Quantity__c.addError('Prescribed quantity cannot exceed 1000 units.');
            }
        }
    }
    public static void validateRefills(List<Prescription__c> newPrescriptions){
        for(Prescription__c p : newPrescriptions){  //Validate refill used and allowed.
            
            if(p.Refills_Allowed__c != null && p.Refills_Allowed__c < 0){
                p.Refills_Allowed__c.addError('Refills Allowed cannot be negative.');
            }
        }
    }
    
    public static void validatePatientStatus(List<Prescription__c> newPrescriptions){
        Set<Id> patientIds = new Set<Id>();
        for(Prescription__c p: newPrescriptions){ //Validating required patient field to check the present status of patient.
            if(p.Patient__c!=null){
                patientIds.add(p.Patient__c);
            }
        }
        if(patientIds.isEmpty()){
            return;
        }
        Map<Id, Patient__c> patientMap = new Map<Id, Patient__c>([SELECT Name, Status__c FROM Patient__c WHERE Id IN :patientIds]);
        
        for(Prescription__c p: newPrescriptions){
            Patient__c presPatient = patientMap.get(p.Patient__c);
            if(presPatient==null){
                continue;
            }
            String patientName = presPatient.Name!=null?presPatient.Name:'<Invalid Name>';
            String patientState = presPatient.Status__c;
            
            if(patientState!='Active'){
                p.Patient__c.addError('Prescription cannot be created for '+patientState.toLowerCase()+' patient: '+patientName);
            }
        }
    }
    
    public static void validateDoctorLicense(List<Prescription__c> newPrescriptions){
        Set<Id> doctorSet = new Set<Id>();
        for(Prescription__c prsc: newPrescriptions){
            if(prsc.Doctor__c!=null){
                doctorSet.add(prsc.Doctor__c);
            }
        }
        if(doctorSet.isEmpty()){
            return;
        }
        Map<Id, Doctor__c> doctorMap = new Map<Id, Doctor__c>([SELECT	Licensed__c, 
        Name FROM Doctor__c 
        WHERE Id IN :doctorSet]);
        
        for(Prescription__c prsc: newPrescriptions){
            if(prsc.Doctor__c==null){
                continue;
            }
            Doctor__c dct = doctorMap.get(prsc.Doctor__c);
            if(dct!=null && !dct.Licensed__c){
                String dctName = dct.Name!=null?dct.Name:'<Invalid Name>';
                prsc.Doctor__c.addError('Doctor ' +dctName+ ' is not licensed to prescribe medication.');
            }
        }
    }
}