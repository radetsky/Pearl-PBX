function pearlpbx_show(pearlpbx_item) { 
	$('#pearl-pbx-main-container').html($(pearlpbx_item).html());
} 

function pearlpbx_show_report (reportname) { 
	$('#pearlpbx-report-body').html($(reportname).html());
	$('.input-date').datepicker();
	return false; 
}

function stored_sessions_submit() {
  var dateFrom; 
	var timeFrom; 
	var dateTo; 
	var timeTo; 
	var phone; 
	var parsed; 

  dateFrom = $('#dateFrom').val(); 
	dateTo = $('#dateTo').val();
	timeFrom = $('#timeFrom').val();
	timeTo = $('#timeTo').val();

	parsed = pearlpbx_parse_period (dateFrom, dateTo, timeFrom, timeTo); 
	if (parsed == false ) { 
		return false;
	} 

	phone = $('#phone').val(); 
	parsed = pearlpbx_parse_phone ( phone ); 
	if (parsed == false ) { 
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

function pearlpbx_parse_phone ( phone ) { 
	if (phone == '') { 
		alert ("Введите ПОЛНЫЙ номер телефона для поиска!"); 
		return false; 
	}

  if (phone.length < 3 ) { 
		alert ("Введите номер телефона, где количество цифр >= 3 !"); 
		return false; 
	}

	return true; 

}

function pearlpbx_parse_period (dateFrom, dateTo, timeFrom, timeTo) { 

	if (dateFrom == '') {
		alert("Введите корректную дату начала!"); 
		return false;
	}

	if (dateTo == '') { 
		alert("Введите корректную дату окончания!");
		return false; 
	}
	
  if (timeFrom == '') { 
		alert("Введите время начала поиска!");
		return false; 
	}
	
	if (timeTo == '') { 
		alert("Введите время окончания поиска!");
		return false; 
	}
  
	return true;

}

function turnOnPBXPlayer (cdr_start, cdr_src, cdr_dst ) { 

 //alert (cdr_start + ' ' + cdr_src + ' ' + cdr_dst ); 
 $('#param_cdr_start').text(cdr_start);
 $('#param_cdr_src').text(cdr_src);
 $('#param_cdr_dst').text(cdr_dst);  

 $.get("recordings.pl",
    { "list-recordings": 1,
			start: cdr_start,
			src: cdr_src, 
			dst: cdr_dst 
    },function(data)
    {

      $('#recordings_table').html(data);
		  PBXPlayerSetMedia('/','wav'); 	

    }, "html");

 return false; 
}

function PBXPlayerSetMedia (url, type) { 

$("#jquery_jplayer_1").jPlayer({
        ready: function () {
          $(this).jPlayer("setMedia", {
						type: url,
          });
        },
        swfPath: "/jPlayer",
        supplied: type,
      });

 return false; 
}
