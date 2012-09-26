function pearlpbx_save_permissions() { 
	var matrix = new String;  
	var regstr=/^X\d+.Y\d+/;
	var count = 0;  

	$('#pearlpbx_permissions_div').find('input[type=checkbox]').each(function() { 
		//alert("id="+$(this).attr('id')+ " " + regstr.test( $(this).attr('id') ));
		var id = $(this).attr('id');
		if (regstr.test( id ) == true ) {
			count = count + 1; 
			if ($(this).attr('checked') == 'checked') { 
				matrix = matrix +id+"=1,"; 
			} else { 
				matrix = matrix +id+"=0,"; 
			}
		} 

	});
	//alert("count="+count); 
	$.post("/route.pl",
	{
		a:"savepermissions",
		b: matrix,
	}, function (data) { 
		var result = data.split(":",2);
			if (result[0] == "OK") {
				alert("Права сохранены успешно!");
				return true;
			}
			if (result[0] == "ERROR") { 
				alert("Сервер вернул ошибку! : "+data);
				return false;
			}
		}, "html");
}

function pearlpbx_permissions_selectall() {
	var checked = $('#XYall').attr('checked');
	$('#pearlpbx_permissions_div').find('input[type=checkbox]').each(function() { 
			if (checked == 'checked') { 
				$(this).attr('checked','checked'); 
			} else {
				$(this).attr('checked',false);
			}
	}); 
}
function pearlpbx_permissions_set_y(yid) {
	var checked = $('#'+yid).attr('checked');
	$('#pearlpbx_permissions_div').find('input[type=checkbox]').each(function() { 
		if ($(this).attr('id').search(yid+'$') >= 0) {
			if (checked == 'checked') { 
				$(this).attr('checked','checked'); 
			} else {
				$(this).attr('checked',false);
			}
		}
	}); 
}
function pearlpbx_permissions_set_x(x) {
	var checked = $('#'+x).attr('checked');
	$('#pearlpbx_permissions_div').find('input[type=checkbox]').each(function() { 
		//alert("id:" + $(this).attr('id') + " search: " + $(this).attr('id').search(x)); 
		if ($(this).attr('id').search(x) >= 0 ) { 
			if (checked == 'checked') { 
				$(this).attr('checked','checked'); 
			} else {
				$(this).attr('checked',false);
			}
		}
	}); 
}

function pearlpbx_reload_permissions() { 
	$('#pearlpbx_permissions_div').empty();
	$.get("/route.pl", { 
		a: "loadpermissions",
	}, function (data) { 
		$('#pearlpbx_permissions_div').append(data);
	} );
	$.getJSON("/route.pl", {
		a: "loadpermissionsJSON",
	}, function (json) { 
		jQuery.each(json, function () {
			var id = "#X"+this['peer_id']+"_Y"+this['direction_id']; 
			if ( $(id).length>0 ) { 
				$(id).attr('checked','checked'); 
			}
		} );
	} ); 

}
function pearlpbx_check_routing() {
	var channel = $('select#check_routing_channel option:selected').val();
	var destination = $('#check_routing_destination').val(); 
	var trimmed =  destination.trim();
	if (trimmed == '') { 
		alert("Номер Б не может быть пустым!");
		return false;
	}

	$.get("/route.pl", {
		a: "checkroute",
		b: channel,
		c: destination,
	}, function (data) {
		$('#pearlpbx_check_routing_result_window').empty();
		$('#pearlpbx_check_routing_result_window').append(data);	
		$('#pearlpbx_check_routing_result').modal('show'); 
	});
	 
}
function pearlpbx_fill_check_routing_channel () { 
	$('select#check_routing_channel').empty();
	$('select#check_routing_channel').append('<optgroup>');	

	$.get("/sip.pl", {
		a: "list",
		b: "internalAsOption" 
	}, function (data) {
		$('select#check_routing_channel').append(data);
		$('select#check_routing_channel').append('</optgroup><optgroup>');
		$.get("/sip.pl", {
			a: "list",
			b: "externalAsOption" 
		}, function (data) {
			$('select#check_routing_channel').append(data);
			$('select#check_routing_channel').append('</optgroup>');
		});
	});

}
function pearlpbx_validate_routing ( dlist_id, route_step, route_type, route_dest, route_src) { 

	alert ("dlist_id: "+dlist_id + "\n" + "route_step: " + route_step + "\n" + 
		"route_type: "+route_type + "\n" + "route_dest: " + route_dest + "\n" +
		"route_src: "+route_src 

		);

	return true; 
}
function pearlpbx_direction_add_routing() { 
	var dlist_id = $('#input_direction_id').val();
	var route_step = $('select#input_direction_routing_step option:selected').val();
	var route_type = $('select#input_direction_routing_type option:selected').val();
	var route_dest = $('select#input_direction_routing_dest option:selected').val();
	var route_src  = $('select#input_direction_routing_source option:selected').val();

	var valid = pearlpbx_validate_routing(dlist_id, route_step, route_type, route_dest, route_src); 
	if (valid == false) { 
		return false; 
	}

	$.get("/route.pl", {
		a: "addrouting",
		dlist_id: dlist_id,
		route_step: route_step,
		route_type: route_type, 
		route_dest: route_dest, 
		route_src: route_src,
	}, function (data) { 
		var result = data.split(":",2);
			if (result[0] == "OK") {
				var dlist_id = $('#input_direction_id').val();
				pearlpbx_routing_load_by_direction_id (dlist_id);
				return true;
			}
			if (result[0] == "ERROR") { 
				alert("Сервер вернул ошибку! : "+data);
				return false;
			}
		}, "html");

	return true;
}
function pearlpbx_routing_load_by_direction_id (dlist_id) {
	var remicon = "<img src=/img/remove-icon.png width=16>";
	$('#pearlpbx_direction_route_list tbody').empty();
	$.getJSON("/route.pl",
	{
		a: "getrouting",
		b: dlist_id,
	},function (json) { 
		jQuery.each(json, function () {
			var remurl = '<td><a href="#" onClick="pearlpbx_routing_remove('+
			this['route_id']+')">'+remicon+'</a></td>';

			$('#pearlpbx_direction_route_list').append("<tr><td>"+this['route_step']+"</td><td>"
				+this['route_type']
				+"</td><td>"+this['destname']+"</td><td>"+this['sipname']+
				"</td>"+remurl+"</tr>");
		}); 		
	} );

}
function pearlpbx_routing_remove (id) {
	var confirmed = confirm ("Вы уверены, что хотите удалить данную запись из таблицы маршрутизации ?");
	if (confirmed == false ) { 
		return false;
	}
	$.get("/route.pl",
		{ a: "removeroute",
		  b: id, 
		},function(data) 
		{
			var result = data.split(":",2);
			if (result[0] == "OK") {
				var dlist_id = $('#input_direction_id').val();
				pearlpbx_routing_load_by_direction_id (dlist_id);
				return true;
			}
			if (result[0] == "ERROR") { 
				alert("Сервер вернул ошибку! : "+data);
				return false;
			}
		}, "html"); 

}
function pearlpbx_routing_type_change(){
	var newvalue = $('select#input_direction_routing_type option:selected').val();
	
	$('select#input_direction_routing_dest').empty();
	if ( newvalue == 'user') { 
		$('select#input_direction_routing_dest').load("/sip.pl?a=list&b=internalAsOptionIdValue");
	}
	if ( newvalue == 'context') { 
		$('select#input_direction_routing_dest').load("/route.pl?a=list&b=contextsAsOption");
	}
	if ( newvalue == 'lmask') { 
		$('select#input_direction_routing_dest').append("<option value='0'>Кто угодно</option>");
		return true;
	}
	if ( newvalue == 'trunk') { 
		$('select#input_direction_routing_dest').load("/sip.pl?a=list&b=externalAsOptionIdValue");
	}
	if ( newvalue == 'tgrp') { 
		$('select#input_direction_routing_dest').load("/route.pl?a=list&b=tgrpsAsOption");
	}

}
function pearlpbx_isalpha_plus_russian(str) { 
    if ( str.search(/[^0-9A-Za-zА-Яа-я ]/) != -1 ) {
    	return false;
    }
    return true; 
}

function pearlpbx_validate_russian_name (str) {
	var trimmed =  str.trim();
	if (trimmed == '') { 
		alert("Название не может быть пустым!");
		return false;
	}
	var valid = pearlpbx_isalpha_plus_russian(str); 
	if (valid == false) { 
		alert("Название может содержать только латинские, кириллические символы и не должно быть пустым или содержать только пробелы.");
		return false;
	}
	return true; 
}

function pearlpbx_empty_direction_edit_form() { 
	$('#pearlpbx_direction_edit_list tbody').empty();
	$('#input_direction_new_prefix').val('');
	$('#input_direction_id').val('');
	$('#input_direction_edit_name').val('');
	return false;
}

function pearlpbx_direction_remove (){
	var dlist_id = $('#input_direction_id').val();
	var confirmed = confirm("Вы уверены, что хотите удалить данное направление со всеми префиксами ?");
	if (confirmed == true) { 
		$.get("/route.pl",
		{ a: "removedirection",
		  b: dlist_id, 
		},function(data) 
		{
			var result = data.split(":",2);
			if (result[0] == "OK") {
				$('#pearlpbx_directions_list').load('/route.pl?a=list-directions-tab');
				$('#pearlpbx_direction_edit').modal('hide');
				return true;
			}
			if (result[0] == "ERROR") { 
				alert("Сервер вернул ошибку! : "+data);
				return false;
			}
		}, "html"); 
	}
	return false; 

}

function pearlpbx_direction_new() {
	var dlist_name = $('#input_direction_edit_name').val();
	var valid = pearlpbx_validate_russian_name(dlist_name);
	if (valid == false) { 
		return false; 
	}
	$.get("/route.pl",
		{ a: "adddirection",
		  b: dlist_name, 
		},function(data) 
		{
			var result = data.split(":",2);
			if (result[0] == "OK") {
				$('#input_direction_id').val(result[1]);
				$('#pearlpbx_directions_list').load('/route.pl?a=list-directions-tab');
				$('#pearlpbx_direction_edit').modal('hide');
				return true;
			}
			if (result[0] == "ERROR") { 
				alert("Сервер вернул ошибку! : "+result[1]);
				return false;
			}
		}, "html"); 

	return false;
}

function pearlpbx_direction_update (){
	var dlist_id = $('#input_direction_id').val();
	if (dlist_id == '') {
		return pearlpbx_direction_new();
	} else { 
		var dlist_name = $('#input_direction_edit_name').val();
		var valid = pearlpbx_validate_russian_name(dlist_name);
		if (valid == false) { 
			return false; 
		}		
		$.get("/route.pl",
			{ a: "setdirection",
			  b: dlist_id,
			  c: dlist_name, 
			},function(data) 
			{
				var result = data.split(":",2);
				if (result[0] == "OK") {
					$('#pearlpbx_directions_list').load('/route.pl?a=list-directions-tab');
					$('#pearlpbx_direction_edit').modal('hide');
					return true;
				}
				if (result[0] == "ERROR") { 
					alert("Сервер вернул ошибку! : "+result[1]);
					return false;
				}
			}, "html"); 
	}
	return false; 
}

function pearlpbx_route_direction_prefix_remove(dr_id) { 
	var confirmed = confirm ("Вы действительно уверены в том, что хотите удалить данный префикс ?");
	if (confirmed == true) { 
		$.get("/route.pl",
		{ a: "removeprefix",
		  b: dr_id, 
		},function(data) 
		{
			if (data == "OK") { 
				var dlist_name = $('#input_direction_edit_name').val();
				var dlist_id = $('#input_direction_id').val();
				pearlpbx_direction_load_by_id(dlist_id, dlist_name);
				return true;
			}
			if (data == "ERROR") { 
				alert("Сервер вернул ошибку!");
				return false;
			}
			alert("Server returns unrecognized answer. Please contact system administrator.");
			alert(data);
		}, "html"); 
	}
}

function pearlpbx_direction_add_prefix(){ 
	var new_prefix = $('#input_direction_new_prefix').val();
	var dlist_id = $('#input_direction_id').val();
	var prefix_prio = $('select#input_direction_new_prio option:selected').val();

	if (new_prefix == '') {
		alert("Префикс не должен быть пустым!");
		return false; 
	}
	// Submit 
	$.get("/route.pl",
		{ a: "addprefix",
		  b: dlist_id, 
		  c: new_prefix,
		  d: prefix_prio, 
		},function(data) 
		{
			if (data == "OK") { 
				var dlist_name = $('#input_direction_edit_name').val();
				pearlpbx_direction_load_by_id(dlist_id, dlist_name);
				return true;
			}
			if (data == "ERROR") { 
				alert("Сервер вернул ошибку!");
				return false;
			}
			if (data == "ALREADY") { 
				alert ("Данный префикс уже присутствует в этом направлении.");
				return false;
			}
			if (data == "ALREADY_ANOTHER") { 
				alert ("Данный префикс уже присутствует в другом направлении.");
				return false;
			}
			alert("Server returns unrecognized answer. Please contact system administrator.");
			alert(data);
		}, "html"); 

}
function pearlpbx_direction_load_by_id (dlist_id, dlist_name) { 
	var remicon = "<img src=/img/remove-icon.png width=16>";
	$('#pearlpbx_direction_edit_list tbody').empty();
	$('#pearlpbx_direction_route_list tbody').empty();
	
	$('#input_direction_new_prefix').val('');

	$('#input_direction_id').val(dlist_id);
	$('#input_direction_edit_name').val(dlist_name);
	$.getJSON("/route.pl",
	{
		a: "getdirection",
		b: dlist_id,
	},function (json) { 
		jQuery.each(json, function () {
			var remurl = '<td><a href="#" onClick="pearlpbx_route_direction_prefix_remove('+
			this['dr_id']+')">'+remicon+'</a></td>';

			$('#pearlpbx_direction_edit_list').append("<tr><td>"+this['dr_prefix']
				+"</td><td>"+this['dr_prio']+"</td>"+remurl+"</tr>");
		}); 		
	} );

	$.getJSON("/route.pl",
	{
		a: "getrouting",
		b: dlist_id,
	},function (json) { 
		jQuery.each(json, function () {
			var remurl = '<td><a href="#" onClick="pearlpbx_routing_remove('+
			this['route_id']+')">'+remicon+'</a></td>';

			$('#pearlpbx_direction_route_list').append("<tr><td>"+this['route_step']+"</td><td>"
				+this['route_type']
				+"</td><td>"+this['destname']+"</td><td>"+this['sipname']+
				"</td>"+remurl+"</tr>");
		}); 		
	} );
	

	$('select#input_direction_routing_source').empty();
	var x = '<optgroup><option value="Anybody">Для всех</option></optgroup>'; 
	$('select#input_direction_routing_source').append(x);
	$('select#input_direction_routing_source').append('<optgroup>');	

	$.get("/sip.pl", {
		a: "list",
		b: "internalAsOptionIdValue" 
	}, function (data) {
		$('select#input_direction_routing_source').append(data);
		$('select#input_direction_routing_source').append('</optgroup><optgroup>');
		$.get("/sip.pl", {
			a: "list",
			b: "externalAsOptionIdValue" 
		}, function (data) {
			$('select#input_direction_routing_source').append(data);
			$('select#input_direction_routing_source').append('</optgroup>');
		});
	});

	
}
function pearlpbx_queue_remove_operator(membername,qname) {
	var confirmed = confirm ("Вы действительно уверены в том, что хотите удалить оператора "+
		membername+" из группы "+qname+" ?");
	if (confirmed == true) { 
		$.get("/queues.pl",
		{ a: "removemember",
		  member: membername, 
		  queue: qname,
		},function(data) 
		{
			if (data == "OK") { 
				pearlpbx_queues_load_by_name(qname);
				return true;
			}
			if (data == "ERROR") { 
				alert("Сервер вернул ошибку!");
				return false;
			}
			alert("Server returns unrecognized answer. Please contact system administrator.");
			alert(data);
		}, "html"); 
	}
}
function pearlpbx_queue_remove() {
	var qname = $('#input_queue_edit_name').val();
	if ( qname == '') { 
		alert("Невозможно удалить группу, у которой нет имени."); 
		return false;
	}
	$('#pearlpbx_remove_queue_confirm_name').val(qname);
	$('#pearlpbx_remove_queue_confirm_dialog').modal('show');
}

function pearlpbx_queue_remove_сonfirmed() {
	$('#pearlpbx_remove_queue_confirm_dialog').modal('hide');
	$('#pearlpbx_queues_edit').modal('hide');
	var qname = $('#pearlpbx_remove_queue_confirm_name').val(); 
// Submit 
	$.get("/queues.pl",
		{ a: "delqueue",
		  queue: qname,
		},function(data) 
		{
			if (data == "OK") { 
				pearlpbx_show_queues();
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

function pearlpbx_queue_add_member() { 
	var oldname = $('#input_queue_hidden_oldname').val();
	var qname = $('#input_queue_edit_name').val();
	var confirmed = false;

	if ( (oldname == '') && ( qname == '' )) 
	{ 
		alert("Для добавления операторов в группу, сначала назовите её.");
		return false;
	}
	if ( ( oldname == '') && ( qname != '')) { 
		confirmed = confirm ("Группа "+qname+" будет сохранена перед тем как будет произведена операция добавления оператора. Вы согласны ?");
		if (confirmed == true) {
			pearlpbx_queue_update();
		} else { 
			return false;
		}
	}
	if ( ( oldname != qname ) ) { 
		confirmed = confirm ("Группа "+qname+" будет сохранена перед тем как будет произведена операция добавления оператора. Вы согласны ?");
		if (confirmed == true) {
			pearlpbx_queue_update();
		} else { 
			return false;
		}
	}


	var operator = $('select#input_queue_edit_members option:selected').val();
	// Submit 
	$.get("/queues.pl",
		{ a: "addmember",
		  newmember: operator, 
		  queue: qname,
		},function(data) 
		{
			if (data == "OK") { 
				pearlpbx_queues_load_by_name(qname);
				return true;
			}
			if (data == "ERROR") { 
				alert("Сервер вернул ошибку!");
				return false;
			}
			if (data == "ALREADY") { 
				alert ("Данный оператор уже присутствует в группе.");
				return false;
			}
			alert("Server returns unrecognized answer. Please contact system administrator.");
			alert(data);
		}, "html"); 
}

function pearlpbx_fill_operators_select () {
	$.get("/sip.pl", {  
		a: "list",
		b: "internalAsOption",
	},  function (data) { 
		$('#input_queue_edit_members').empty();
		$('#input_queue_edit_members').append(data);
	}, "html");
}

function pearlpbx_validate_queue() { 
	var name = $('#input_queue_edit_name').val(); 
    var alphaExp = /^[0-9a-zA-Z]+$/;
    if(name.search(/[^0-9A-Za-z]/) != -1) {
    	alert("Имя группы должно содержать только латинские символы и цифры! Без пробелов!");
    	return false;
    }
}

function pearlpbx_queue_update () { 
	var oldname    = $('#input_queue_hidden_oldname').val();
	var queue_name = $('#input_queue_edit_name').val(); 
	var strategy   = $('select#input_queue_edit_strategy option:selected').val();
	var timeout    = $('#input_queue_edit_timeout').val();
	var maxlen     = $('#input_queue_edit_maxlen'). val();

	var valid = pearlpbx_validate_queue();
	if (valid == false) {
		return false;
	}

	// Submit 
	$.get("/queues.pl",
		{ a: "setqueue",
		  oldname: oldname, 
		  name: queue_name,
		  strategy: strategy, 
		  timeout: timeout,
		  maxlen: maxlen,
		},function(data) 
		{
			if (data == "OK") { 
				pearlpbx_show_queues();
				$('#pearlpbx_queues_edit').modal('hide');
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


function pearlpbx_queues_clear () { 
	$('#pearlpbx_edit_queue_operators_list tbody').empty();
	$('#input_queue_hidden_oldname').val('');
	$('#input_queue_edit_name').val('');
	$('#input_queue_edit_strategy').val('');
	$('#input_queue_edit_timeout').val('');
	$('#input_queue_edit_maxlen').val('');
	pearlpbx_fill_operators_select();
}

function pearlpbx_queues_load_by_name (qname) {
	var remicon = "<img src=/img/remove-icon.png width=16>";

	// clear 
	$('#pearlpbx_edit_queue_operators_list tbody').empty();


	// fill
	$.getJSON("/queues.pl",
	{
		a: "getqueue",
		name: qname,
	},function (json) { 
		$('#input_queue_hidden_oldname').val(json.name);
		$('#input_queue_edit_name').val(json.name);
		$('#input_queue_edit_strategy').val(json.strategy);
		$('#input_queue_edit_timeout').val(json.timeout);
		$('#input_queue_edit_maxlen').val(json.maxlen);
	} );

	$.getJSON("/queues.pl", 
	{
		a: "listmembers",
		b: qname,
	}, function (json) { 
		
		jQuery.each(json, function () {
			var remurl = '<td><a href="#" onClick="pearlpbx_queue_remove_operator('+
				this['membername']+',\''+qname+'\')">'+remicon+'</a></td>';

			$('#pearlpbx_edit_queue_operators_list').append("<tr><td>"+this['membername']
				+"</td><td>"+this['interface']+"</td>"+remurl+"</tr>");
		}); 
	});
	pearlpbx_fill_operators_select();
}

function pearlpbx_show_queues() {
	$('#pearl-pbx-main-container').html($('#queues').html());
	$('#pearlpbx-queues-list').load('/queues.pl?a=list&b=li'); 
	return false; 	
}

function pearlpbx_queue_edit_advanced_mode() { 
	alert('Профессиональный режим редактирования групп/очередей будет доступен в следующей версии!');
}

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


