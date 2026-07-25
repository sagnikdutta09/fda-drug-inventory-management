import { LightningElement } from 'lwc';

export default class WelcomeHeader extends LightningElement {
    currentDate='';
    currentTime='';
    timer;
    connectedCallback(){
        this.updateDateTime();
        this.timer=setInterval(()=>{
            this.updateDateTime();
        },1000);
    }

disconnectedCallback(){
    clearInterval(this.timer);
}

updateDateTime() {
    const now = new Date();
    this.currentDate = now.toLocaleDateString('en-IN', {
            weekday: 'long',
            day: 'numeric',
            month: 'long',
            year: 'numeric'
        });

        this.currentTime = now.toLocaleTimeString('en-IN');
    }
}