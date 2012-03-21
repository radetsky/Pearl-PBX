function stored_sessions_submit() {
  var dateFrom; 
	var timeFrom; 
	var dateTo; 
	var timeTo; 
	var phone; 

  dateFrom = $('#dateFrom').val(); 
	if (dateFrom == '') {
		alert("Введите корректную дату начала!"); 
		return false;
	}

	dateTo = $('#dateTo').val();
	if (dateTo == '') { 
		alert("Введите корректную дату окончания!");
		return false; 
	}
	
	timeFrom = $('#timeFrom').val();
  if (timeFrom == '') { 
		alert("Введите время начала поиска!");
		return false; 
	}
	
	timeTo = $('#timeTo').val();
	if (timeTo == '') { 
		alert("Введите время окончания поиска!");
		return false; 
	}

	phone = $('#phone').val(); 
	if (phone == '') { 
		alert ("Введите ПОЛНЫЙ номер телефона для поиска!"); 
		return false; 
	}

  if (phone.length < 3 ) { 
		alert ("Введите номер телефона, где количество цифр >= 3 !"); 
		return false; 
	}

  $.get("stored_sessions.pl",
		{ dateFrom: dateFrom,
			timeFrom: timeFrom, 
			dateTo: dateTo,
			timeTo: timeTo,
			phone: phone,
		},function(data) 
		{

			$('#stored_sessions_result').html(data); 

		}, "html"); 

  return false; 
}

