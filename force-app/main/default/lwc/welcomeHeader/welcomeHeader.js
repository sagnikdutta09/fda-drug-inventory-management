import { LightningElement, wire } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import PROFILE_FIELD from '@salesforce/schema/User.Profile.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';

export default class WelcomeHeader extends LightningElement {
    title='Welcome to the FDA Drug Inventory & Distribution System';
    // username='Sagnik Dutta'

    get greeting(){
        const hours = new Date().getHours();
        let timeOfDay='';
        if(hours<12){
            timeOfDay='Good Morning'
        }
        else if(hours<18){
            timeOfDay='Good Afternoon'
        }
        else {
            timeOfDay='Good Evening'
        }
        
        return timeOfDay
    }
    currentTime = new Date();
    connectedCallback(){
        this.timer= setInterval(()=>{
            this.currentTime= new Date();
        },1000);
    }

    get fullTime(){
        const hours = this.currentTime.getHours();
        const minutes = this.currentTime.getMinutes();
        const seconds = this.currentTime.getSeconds();

        return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
    }

    get fullDate(){
        const date= this.currentTime;
        const day = date.toLocaleDateString(
            'en-US',
            {
                weekday: 'long'
            }
        ).toUpperCase();

        const month = date.toLocaleDateString(
            'en-US',
            {
                month: 'long'
            }
        );

        const dayNum = date.getDate();
        const year=date.getFullYear();
        return `${day}, ${dayNum} ${month}, ${year}`
    }

    @wire(
        getRecord,{
            recordId: USER_ID,
            fields: [NAME_FIELD, PROFILE_FIELD, EMAIL_FIELD]
        }
    ) user;

    isUser(){
        return this.user && this.user.data;
    }

    get userDetails(){
        if(this.isUser()){
            return{
                name: getFieldValue(this.user.data, NAME_FIELD),
                profile : getFieldValue(this.user.data, PROFILE_FIELD),
                email: getFieldValue(this.user.data, EMAIL_FIELD),
            };
        }
        return{
            name:'',
            profile:'',
            email:''
        };
    }
}