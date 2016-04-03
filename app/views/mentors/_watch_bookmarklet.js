var nextPersonId = 0;
function inputNextPerson() {
	person = people[nextPersonId];
	if (!person) { 
		console.log("Done");
		alert("Your data has been entered. You can now proceed with the search by clicking 'Search Now.'");
		return;
	}
	inputPerson(person);
	nextPersonId++;
}

function inputPerson(person) {
	$("#ClearButton").click()
	console.log("Adding another person: " + JSON.stringify(person));
	$("#FirstName").val(person.firstname);
	$("#LastName").val(person.lastname);
	$("#MiddleName").val(person.middle_initial);	
	if(!person.middle_initial && person.firstname.split(" ").length > 1) {
		var newfirst = person.firstname.split(" ")[0];
		var newmiddle = person.firstname.split(" ")[1][0];
		$("#FirstName").val(newfirst);
		$("#MiddleName").val(newmiddle);
	}
	$("#DateOfBirthPicker").val(person.watch_birthdate);
	$("#Gender").val(person.sex[0]);
	$("#OtherLastName1").val(person.aliases.split(" ")[1]);
	$("#OtherFirstName1").val(person.aliases.split(" ")[0]);
	
	$("#AddSearch").click();
	setTimeout(handleErrorsOrSubmit, 250);
}

function handleErrorsOrSubmit() {
	if($("#FieldsError > :visible").length > 0 ) {
		$("#bulk-error").html("There were errors. Try fixing the format for this person's record:");
		$("#bulk-entry").val(JSON.stringify(person, null, '\t'));
		$( "#bulk-dialog" ).dialog({
			resizable: false,
			height:400,
			width: 400,
			modal: true,
			buttons: {
				"Go": function() {
					inputPerson(JSON.parse($("#bulk-entry").val()));
					$( this ).dialog( "close" );
				},
				Cancel: function() {
					$( this ).dialog( "close" );
				}
			}
		});
	}
	else {
		$("#AddSearch").click();
		setTimeout(inputNextPerson, 500);
	}
}	

function initBulkEntry(){
	people = JSON.parse($("#bulk-entry").val());
	inputNextPerson();
}

if($("#bulk-dialog").length == 0) {	
	$("<div id='bulk-dialog'><div id='bulk-error'>Enter bulk query in proper format:</div><textarea id='bulk-entry' style='width: 100%; font-family: Courier, sans-serif; font-size: 10px;' rows='10'></textarea></div>").appendTo($("body"));
}

$( "#bulk-dialog" ).dialog({
	resizable: false,
	height:400,
	width: 400,
	modal: true,
	buttons: {
		"Go": function() {
			initBulkEntry();
			$( this ).dialog( "close" );
		},
		Cancel: function() {
			$( this ).dialog( "close" );
		}
	}
});

