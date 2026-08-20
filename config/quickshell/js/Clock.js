function getFormattedTime() {
    let newDate = new Date();
    let hours = newDate.getHours();
    let minutes = newDate.getMinutes(); 

    hours = hours > 12 ? (hours - 12) : hours;
    hours = hours < 10 ? ("0" + hours) : hours;
    hours = hours == "00" ? ("12") : hours;
    
    minutes = minutes < 10 ? ("0" + minutes) : minutes;

    let time = (hours + ":" + minutes);
    return time;
}
