$(document).ready(function(){
    $("button").click(function(){
      alert("Background color = " + $("p").css("background-color"));
    });
});

function my_calc() {

    var num1 = +prompt("Enter the first number");
    var num2 = +prompt("Enter the second number");

    var sum = num1+num2;

    document.getElementById("demo").innerHTML = "The value of z is: " + sum;
}

function Car(type, model, color){
    this.type = type;
    this.model = model;
    this.color = color;

    this.print_info = function(){
        return this.type + " " + this.model + " " + this.color;
    };
}

function show_you(){
    var cars = new Array();
    
    cars[0] = new Car("Kia", "Forte", "Silver");
    cars[1] = new Car("Ford","Focus", "White");
    cars[2] = new Car("Chevy", "Bronco", "Blue");   
}

function test() {
    let day = new Date().getDay();
    let myDay;

    switch(day){
        case 0: 
            myDay = "Sunday"
            break;
        case 1: 
            myDay = "Monday";
            break;
        case 2: 
            myDay = "Tuesday";
            break;
        case 3: 
            myDay = "Wednesday";
            break;
        case 4: 
            myDay = "Thursday";
            break;
        case 5: 
            myDay = "Friday";
            break;
        case 6: 
            myDay = "Saturday";
        default:
            myDay = "Invalid";
    }

    document.getElementById("de1").innerHTML = myDay;
}

function Army(faction, style, ) {
    this.faction = faction;
    this.style = style;
}

function display() {

    let text = "";
    
    document.getElementById("de1").innerHTML = text;

}

