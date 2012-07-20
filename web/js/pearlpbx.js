function pearlpbx_sip_update_user(){ 
	var sip_id = $('#input_sip_edit_id').val();
	var comment = $('#input_sip_edit_comment').val(); 
	var terminal = $('select#input_sip_edit_terminal option:selected').val();
	var macaddr = $('#input_sip_edit_macaddr').val();
	var secret = $('#input_sip_edit_secret').html(); 
 
 // Submit 
	$.get("/sip.pl",
		{ a: "setuser",
		  id: sip_id,
		  comment: comment, 
		  terminal: terminal,
		  macaddr: macaddr,
		  secret: secret,
		},function(data) 
		{
			if (data == "OK") { 
				$('#pearlpbx-sip-connections-list').load('/sip.pl?a=list&b=internal');
				$('#pearlpbx_sip_edit_user').modal('hide');
				return false; 
			}
			if (data == "ERROR") { 
				alert("Сервер вернул ошибку!");
				return false;
			}
			alert("Server returns unrecognized answer. Please contact system administrator.");
			alert(data);
		}, "html"); 
}
function pearlpbx_sip_load_id(sip_id) { 
	$.getJSON("/sip.pl",
	{
		a: "getuser",
		id: sip_id,
	}, function (json) { 
		$('#input_sip_edit_id').val(json.id);
		$('#input_sip_edit_comment').val(json.comment);
		$('#input_sip_edit_extension').html(json.extension);
		$('#input_sip_edit_secret').html(json.secret);
		$('#input_sip_edit_macaddr').val(json.mac_addr_tel);
		$('#input_sip_edit_terminal').val(json.teletype);
	});
}
function pearlpbx_sip_add_user(){ 
	var comment = $('#input_sip_add_comment').val(); 
	var extension = $('select#input_sip_add_extension option:selected').val();
	var terminal = $('select#input_sip_add_terminal option:selected').val();
	var macaddr = $('#input_sip_add_macaddr').val();
	var secret = $('#input_sip_add_secret').html(); 

	// FIXME: validate 

	// Submit 
	$.get("/sip.pl",
		{ a: "adduser",
		  comment: comment, 
		  extension: extension,
		  terminal: terminal,
		  macaddr: macaddr,
		  secret: secret,
		},function(data) 
		{
			if (data == "OK") { 
				$('#pearlpbx-sip-connections-list').load('/sip.pl?a=list&b=internal');
				$('#add_sip_user').modal('hide');
				return false; 
			}
			if (data == "ERROR") { 
				alert("Сервер вернул ошибку!");
				return false;
			}
			alert("Server returns unrecognized answer. Please contact system administrator.");
			alert(data);
		}, "html"); 

}
function pearlpbx_sip_add_advanced_mode() { 
	alert('Профессиональный режим добавления пользователей SIP будет доступен в следующей версии!');
}

function pearlpbx_sip_edit_advanced_mode() { 
	alert('Профессиональный режим редактирования пользователей SIP будет доступен в следующей версии!');
}

function pearlpbx_change_secret_add_form() { 
	$('#input_sip_add_secret').load('/sip.pl?a=newsecret');
	return false; 
}
function pearlpbx_change_secret_edit_form() { 
	$('#input_sip_edit_secret').load('/sip.pl?a=newsecret');
	return false; 
}


function pearlpbx_today() { 
	var now = new Date();
	var mday = now.getDate(); 
	if (mday < 10 ) { 
		mday = "0"+mday;
	}
	var month = now.getMonth()+1; 
	if (month < 10) { 
		month = "0"+month;
	}

	var prettyDate =  now.getFullYear() + '-' + month + '-' + mday;
	$('.input-date').val(prettyDate);
	$('.input-date').datepicker();
}

function pearlpbx_sip_add_trunk() {
	alert ("called sip_add_trunk()"); 

} 

function pearlpbx_sip_edit_id(sip_id) { 
	alert("called sip_edit_id ( "+sip_id+" )"); 
}

function pearlpbx_fill_sip_form() { 
	$('.pearlpbx_internal_free_list').load('/sip.pl?a=list&b=internal-free');
	pearlpbx_change_secret_add_form();
}

function pearlpbx_show_sip_internal_users () { 
	$('#pearlpbx-sip-connections-list').load('/sip.pl?a=list&b=internal');
	$('#pearlpbx-sip-add-internal-button').css('display','block');
	$('#pearlpbx-sip-add-external-button').css('display','none'); 
}
function pearlpbx_show_sip_external_trunks () { 
	$('#pearlpbx-sip-connections-list').load('/sip.pl?a=list&b=external');
	$('#pearlpbx-sip-add-external-button').css('display','block');
	$('#pearlpbx-sip-add-internal-button').css('display','none');
} 
function pearlpbx_show(pearlpbx_item) {
    $('.pearlpbx-report-body').html(''); 
	$('#pearl-pbx-main-container').html($(pearlpbx_item).html());
	pearlpbx_today();
} 

function pearlpbx_show_report (reportname) { 
	$('.pearlpbx-report-body').html($(reportname).html());
	pearlpbx_today();
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
		alert ("Введите хотя 3 цифры номер телефона для поиска!"); 
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

function pearlpbx_parse_internal_phone ( phone ) { 
	if (phone == '') { 
		alert ("Введите 3 цифры номер телефона для поиска!"); 
		return false; 
	}

  if (phone.length != 3 ) { 
		alert ("Введите номер телефона, где количество цифр = 3 !"); 
		return false; 
	}

	return true; 

}


