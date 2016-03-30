var nextPersonId = 0;
function inputNextPerson() {
	person = people[nextPersonId];
	if (!person) { 
		console.log("Done");
		alert("Your data has been entered. You can now proceed with the search by clicking 'Search Now.'");
		return;
	}
	console.log("Adding another person: " + JSON.stringify(person));
	$("#FirstName").val(person.firstname);
	$("#LastName").val(person.lastname);
	$("#MiddleName").val(person.middle_initial);
	$("#DateOfBirthPicker").val(person.watch_birthdate);
	$("#Gender").val(person.sex[0]);
	$("#OtherLastName1").val(person.aliases.split[1]);
	$("#OtherFirstName1").val(person.aliases.split[0]);
	$("#AddSearch").click();
	nextPersonId++;
	setTimeout(inputNextPerson, 250);
}
people = JSON.parse(prompt('Enter names block in proper format:'));
inputNextPerson();