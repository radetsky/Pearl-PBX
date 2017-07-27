var pearlpbx_monitor_connected = false;

Array.prototype.indexOfQueue = function ( name ) {
	for (var i = 0; i < this.length; i++) {
		if ( this[i].name == name ) {
			return i;
		}
	}
	return -1;
}

function pearlpbx_get_calendar() {
	var remicon = "<img src=/img/remove-icon.png width=16>";

	$('#pearlpbx_ivr_calendar_table tbody').empty();
	$.getJSON('/modules.pl', {
		"exec-module":"Calendar",
		"sub":"getJSON",
	}, function (json) {

		jQuery.each(json, function () {
			var remurl = '<td><a href="javascript:void(0)" onClick="pearlpbx_calendar_item_remove('+
				this['id']+')">'+remicon+'</a></td>';
			var weekday = this['weekday'];
			var mon_day = this['mon_day'];
			var mon     = this['mon'];
			var year    = this['year'];
			var time_start = this['time_start'];
			var time_stop  = this['time_stop'];
			var is_work    = this['is_work'];
			var group_name = this['group_name'];
			var prio       = this['prio'];

			$('#pearlpbx_ivr_calendar_table tbody').append("<tr>"+
				"<td>"+weekday+"</td>"+
				"<td>"+mon_day+"</td>"+
				"<td>"+mon+"</td>"+
				"<td>"+year+"</td>"+
				"<td>"+time_start+"</td>"+
				"<td>"+time_stop+"</td>"+
				"<td>"+group_name+"</td>"+
				"<td>"+is_work+"</td>"+
				"<td>"+prio+"</td>"+remurl+
				"</tr>");
		});

	}, "html");
}

function pearlpbx_show_module (modulename) {
	$('.pearlpbx-modules-admin-ivr-body').html($(modulename).html());
	return false;
}

function pearlpbx_tftp_reload() {
	var confirmed = confirm ("Refresh autoprovision settings ?");
	if ( confirmed == true ) {
		$.get('/sip.pl',{
			a: "tftp_reload",
		},function(data) {
			alert(data);
		}, "html");
	}
}


function pearlpbx_sip_reloaded(msgs) {
	var response = msgs[0].headers['response'];
	var message = msgs[0].headers['message'];

	alert('Настройки протокола SIP перезагружены.');

}
function pearlpbx_sip_reload() {
	var confirmed = confirm ("Перегрузить настройки протокола SIP ?");
	if (confirmed == true ) {
		astmanEngine.sendRequest('action=command&command=sip%20reload',
                        pearlpbx_sip_reloaded,
                        pearlpbx_monitor_fake_callback
                );
	}
}

function pearlpbx_monitor_get_ulines() {
	$('#pearlpbx_monitor_ulines tbody').empty();
	$.getJSON('/route/getulines', undefined, function (json) {
		jQuery.each(json, function () {
			var timt = this['cdr_start'].split(' ');
			var channel = this['channel_name'].split('-');

			$('#pearlpbx_monitor_ulines tbody').append("<tr><td>"+this['id']
				+"</td><td>"+this['callerid_num']+"</td>"
				+"<td>"+timt[1]+"</td>"
				+"<td>"+channel[0]+"</td></tr>");
		});

	}, "html");


}
function pearlpbx_monitor_set_active_channels (msgs) {
	$('#pearlpbx_monitor_active_channels tbody').empty();

	if (msgs[0].headers['response'] != 'Success') {
		if ( msgs[0].headers['response'] == 'Error') {
			if ( msgs[0].headers['message'] == 'Authentication Required') {
				pearlpbx_monitor_connected = false;
				pearlpbx_monitor_connect (pearlpbx_monitor_get_active_channels);
			}
			if ( msgs[0].headers['message'] == 'Permission denied') {
				pearlpbx_monitor_connected = false;
				pearlpbx_monitor_connect (pearlpbx_monitor_get_active_channels);
			}
		}

		$('#pearlpbx_monitor_active_channels tbody').append("Can't get info: "+msgs[0].headers['message']);
		return;
	}

	var achannels = 0;
	var atalks = 0;

	for (var i = 0; i < msgs.length; i++ ) {
		if (msgs[i].headers['event'] == 'Status') {
			achannels++;
			var channel = msgs[i].headers['channel'].split('-');
			var callerid = msgs[i].headers['calleridnum'];
			var state = msgs[i].headers['channelstatedesc'];
			if ( state == undefined ) {
				state = msgs[i].headers['state'];
			}
			var link = msgs[i].headers['bridgedchannel'];

			if (link == undefined) {
				link = new Array (" ", " ");
			} else {
				link = msgs[i].headers['bridgedchannel'].split('-');
				atalks++;
			}

			var tstr = "<tr><td>"+channel[0]+"</td>"
						+"<td>"+callerid+"</td>"
						+"<td>"+state+"</td>"
						+"<td>"+link[0]+"</td></tr>";
			$('#pearlpbx_monitor_active_channels tbody').append(tstr);
		}
	}
	$('#pearlpbx_monitor_zagalom_channels').html(achannels);
	$('#pearlpbx_monitor_zagalom_talks').html(atalks/2);

	pearlpbx_monitor_get_ulines();

}

function pearlpbx_monitor_get_active_channels () {
	if ( pearlpbx_monitor_connected == false ) {
		pearlpbx_monitor_connect (pearlpbx_monitor_get_active_channels);
	} else {
		astmanEngine.sendRequest('action=status',
			pearlpbx_monitor_set_active_channels,
			pearlpbx_monitor_fake_callback
		);
	}
}

function pearlpbx_monitor_set_parkedcalls (msgs) {
	$('#pearlpbx_monitor_parkedcalls tbody').empty();

	if (msgs[0].headers['response'] != 'Success') {
		if ( msgs[0].headers['response'] == 'Error') {
			if ( msgs[0].headers['message'] == 'Authentication Required') {
				pearlpbx_monitor_connected = false;
				pearlpbx_monitor_connect (pearlpbx_monitor_get_parkedcalls);
			}
			if ( msgs[0].headers['message'] == 'Permission denied') {
				pearlpbx_monitor_connected = false;
				pearlpbx_monitor_connect (pearlpbx_monitor_get_parkedcalls);
			}
		}

		$('#pearlpbx_monitor_parkedcalls tbody').append("Can't get info: " + msgs[0].headers['message']);
		return;
	}

	var parked = 0;
	for (var i=0; i < msgs.length; i++ ) {
		if ( msgs[i].headers['event'] == 'ParkedCall') {
			parked++;
			var callerid = msgs[i].headers['callerid'];
			var exten = msgs[i].headers['exten'];
			var channel = msgs[i].headers['channel'].split("-");
			var timeout = msgs[i].headers['timeout'];

			var tstr = "<tr><td>"+callerid+"</td>"
						+"<td>"+exten+"</td>"
						+"<td>"+channel[0]+"</td>"
						+"<td>"+timeout+"</td></tr>";

			$('#pearlpbx_monitor_parkedcalls tbody').append(tstr);
		}
	}
	$('#pearlpbx_monitor_zagalom_parked').html(parked);
	pearlpbx_monitor_get_active_channels();

}
function pearlpbx_monitor_get_parkedcalls () {
	if ( pearlpbx_monitor_connected == false ) {
		pearlpbx_monitor_connect (pearlpbx_monitor_get_parkedcalls);
	} else {
		astmanEngine.sendRequest('action=ParkedCalls',
			pearlpbx_monitor_set_parkedcalls,
			pearlpbx_monitor_fake_callback
		);
	}
}

function pearlpbx_monitor_show_queue_status (msgs) {
	var QueueName = $('#pearlpbx_queue_details_name').text();
	var queue = new Object();
	var queuemembers = new Array();
	var qentries = new Array();

   /*	alert('QueueName='+QueueName);  */
	$('#pearlpbx_table_queue_details tbody').empty();
	$('#pearlpbx_table_queue_entries tbody').empty();

	if (msgs[0].headers['response'] != 'Success') {
		if ( msgs[0].headers['response'] == 'Error') {
			if ( msgs[0].headers['message'] == 'Authentication Required') {
				pearlpbx_monitor_connected = false;
				pearlpbx_monitor_connect (pearlpbx_show_queue_details(QueueName));
			}
			if ( msgs[0].headers['message'] == 'Permission denied') {
				pearlpbx_monitor_connected = false;
				pearlpbx_monitor_connect (pearlpbx_show_queue_details(QueueName));
			}
		}

		$('#pearlpbx_table_queue_details tbody').append("Can't get info: " + msgs[0].headers['message']);
		return;
	}

	for (var i=1; i < msgs.length; i++) {
		if ( msgs[i].headers['event'] == 'QueueParams') {
			if ( msgs[i].headers['queue'] == QueueName ) {
				$('#qdx_name').html(msgs[i].headers['queue']);
				$('#qdx_calls').html(msgs[i].headers['calls']);
				$('#qdx_max').html(msgs[i].headers['max']);
				$('#qdx_strategy').html(msgs[i].headers['strategy']);
				$('#qdx_holdtime').html(msgs[i].headers['holdtime']);
				$('#qdx_talktime').html(msgs[i].headers['talktime']);
				$('#qdx_completed').html(msgs[i].headers['completed']);
				$('#qdx_abandoned').html(msgs[i].headers['abandoned']);
				$('#qdx_servicelevel').html(msgs[i].headers['servicelevel']);
			}
		}
	}


	for (var i=1; i < msgs.length; i++) {
		var queuemember = new Object();
		var queueentry = new Object();
		if ( msgs[i].headers['event'] == 'QueueMember') {
			if (msgs[i].headers['queue'] == QueueName ) {
				queuemember.name = msgs[i].headers['name'];
				queuemember.penalty = msgs[i].headers['penalty'];
				queuemember.status = msgs[i].headers['status'];
				queuemember.paused = msgs[i].headers['paused'];
				queuemember.callstaken = msgs[i].headers['callstaken'];
				queuemember.lastcall = msgs[i].headers['lastcall'];
				queuemembers.push(queuemember);
			}
		}
		if ( msgs[i].headers['event'] == 'QueueEntry') {
			if (msgs[i].headers['queue'] == QueueName ) {
				queueentry.position = msgs[i].headers['position'];
				queueentry.callerid = msgs[i].headers['calleridnum'];
				queueentry.wait = msgs[i].headers['wait'];
				qentries.push(queueentry);
			}
		}
	}
	for (var i=0; i < qentries.length; i++) {
		var table_string = "<tr>"
			+"<td>"+qentries[i].position+"</td>"
			+"<td>"+qentries[i].callerid+"</td>"
			+"<td>"+qentries[i].wait+"</td></tr>";
		$('#pearlpbx_table_queue_entries tbody').append(table_string);
	}

	//alert("queues length: "+queues.length);
	for (var i=0; i < queuemembers.length; i++ ) {
		var table_string = "<tr>"
								+"<td>"+queuemembers[i].name+"</td>"
								+"<td>"+queuemembers[i].penalty+"</td>"
								+"<td>"+queuemembers[i].callstaken+"</td>"
								+"<td>"+queuemembers[i].lastcall+"</td>"
								+"<td>"+queue_member_status(queuemembers[i].status)+"</td>"
								+"<td>"+queue_member_paused(queuemembers[i].paused)+"</td></tr>";
		//alert(table_string);
		$('#pearlpbx_table_queue_details tbody').append(table_string);
	}


}
function queue_member_status (Status) {
	if (Status == 1) { return "<font color='green'>Not In Use</font>"; }
	if (Status == 2) { return "<font color='red'>In Use</font>"; }
    if (Status == 3) { return "<font color='red'>Busy</font>"; }
	if (Status == 5) { return "<font color='red'>Unavailable</font>"; }
	if (Status == 6) { return "<font color='red'>Ringing</font>"; }
}

function queue_member_paused ( Paused ) {
	if (Paused == 0) { return "<font color='green'>Online</font>"; }
	if (Paused == 1) { return "<font color='red'>Paused</font>"; }
}
function pearlpbx_show_queue_details (QueueName) {
	if (QueueName == "") {
		QueueName = $('#pearlpbx_queue_details_name').text();
	}

	$('#pearlpbx_queue_details_name').text(QueueName);

	if ( pearlpbx_monitor_connected == false ) {
		pearlpbx_monitor_connect (pearlpbx_show_queue_details(QueueName));
	} else {
		astmanEngine.sendRequest('action=QueueStatus',
			pearlpbx_monitor_show_queue_status,
			pearlpbx_monitor_fake_callback
		);
	}

}


function pearlpbx_monitor_set_queue_status(msgs) {

	$('#pearlpbx_monitor_queue tbody').empty();

	if (msgs[0].headers['response'] != 'Success') {
		if ( msgs[0].headers['response'] == 'Error') {
			if ( msgs[0].headers['message'] == 'Authentication Required') {
				pearlpbx_monitor_connected = false;
				pearlpbx_monitor_connect (pearlpbx_monitor_get_queue_status);
			}
			if ( msgs[0].headers['message'] == 'Permission denied') {
				pearlpbx_monitor_connected = false;
				pearlpbx_monitor_connect (pearlpbx_monitor_get_queue_status);
			}
		}

		$('#pearlpbx_monitor_queue tbody').append("Can't get info: " + msgs[0].headers['message']);
		return;
	}

	var queues = new Array();
	var qmembers = new Array();
	var qcalls = 0;
	var inuse = new Array();
	var notinuse = new Array();
	var paused = new Array();
	var unavailable = new Array();
    var readyagents = new Array();
	var notreadyagents = new Array();

	for (var i=1; i < msgs.length; i++) {
		var queue = new Object();

		if ( msgs[i].headers['event'] == 'QueueParams') {
			queue.name  = msgs[i].headers['queue'];
			queue.calls = msgs[i].headers['calls'];
			qcalls = qcalls+parseInt(queue.calls,10);
			queue.inuse    = 0;
			queue.notinuse = 0;
			queue.ringing   = 0;
			queue.unavailable = 0;
			queue.paused = 0;
			queue.ready = 0;
			queue.notready = 0;
			queues.push(queue);
		}
	}

	for (var i=1; i < msgs.length; i++) {
		var queuemember = new Object();
		if ( msgs[i].headers['event'] == 'QueueMember') {
			var name = msgs[i].headers['queue'];

			var j = queues.indexOfQueue(name);
			// alert (i + ': indexOfQueue: '+ name + '=' + j);
			queue = queues[j];
			var name = msgs[i].headers['name'];
			var status = msgs[i].headers['status'];
			var paused = msgs[i].headers['paused'];

			if ( status == 2 ) {
				queue.inuse = queue.inuse + 1;
				queue.notready = queue.notready + 1;
				inuse[name] = 1;
				notreadyagents[name] = 1;
			}
			if ( status == 1 ) {
				if ( paused == 0 ) {
					queue.notinuse = queue.notinuse + 1;
					queue.ready = queue.ready + 1;
					notinuse[name] = 1;
					readyagents[name] = 1;
				} else {
					queue.paused = queue.paused + 1;
					queue.notready = queue.notready + 1;
					paused[name] = 1;
					notreadyagents[name] = 1;
					}
			}
			if ( status == 6 ) {
				queue.ringing = queue.ringing + 1;
				queue.ready = queue.ready + 1;
				notinuse[name] = 1;
				readyagents[name] = 1;
			}
			if ( status == 5 ) {
				queue.unavailable = queue.unavailable + 1;
				queue.notready = queue.notready + 1;
				unavailable[name] = 1;
				notreadyagents[name] = 1;
			}
		}
	}

	//alert("queues length: "+queues.length);
	for (var i=0; i < queues.length; i++ ) {
		var table_string = "<tr><td><a href=\"#pearlpbx_queue_details\" data-toggle=\"modal\" onClick=\"pearlpbx_show_queue_details('"+queues[i].name+"')\">"+queues[i].name+"</a></td>"
								+"<td>"+queues[i].calls+"</td>"
								+"<td>"+queues[i].inuse+"</td>"
								+"<td>"+queues[i].notinuse+"</td>"
								+"<td>"+queues[i].ready+"</td>"
								+"<td>"+queues[i].notready+"</td></tr>";
		//alert(table_string);
		$('#pearlpbx_monitor_queue tbody').append(table_string);
	}
	$('#pearlpbx_monitor_zagalom_qcalls').html(qcalls);

	var zagalom_inuse = 0;
	for (var i in inuse) {
		if (inuse.hasOwnProperty(i)) {
			zagalom_inuse++;
		}
	}

	var zagalom_notinuse = 0;
	for (var i in notinuse) {
		if (notinuse.hasOwnProperty(i)) {
			zagalom_notinuse++;
		}
	}

	$('#pearlpbx_monitor_zagalom_inuse').html(zagalom_inuse);
	$('#pearlpbx_monitor_zagalom_notinuse').html(zagalom_notinuse);
	pearlpbx_monitor_get_parkedcalls();

}

function pearlpbx_monitor_get_queue_status() {
	if ( pearlpbx_monitor_connected == false ) {
		pearlpbx_monitor_connect (pearlpbx_monitor_get_queue_status);
	} else {
		astmanEngine.sendRequest('action=QueueStatus',
			pearlpbx_monitor_set_queue_status,
			pearlpbx_monitor_fake_callback
		);
	}
}

function pearlpbx_monitor_failed() {
	var failed = "<font color=\"#FF0000\"> X </font>";
	$('#pearlpbx_monitor_sip_peers').html(failed);
	$('#pearlpbx_monitor_sip_online').html(failed);
	$('#pearlpbx_monitor_sip_unknown').html(failed);
	$('#pearlpbx_monitor_sip_offline').html(failed);
	pearlpbx_monitor_connected = false;
}

function pearlpbx_monitor_login(msgs, callback_dest) {

	var response = msgs[0].headers['response'];
	var message  = msgs[0].headers['message'];

	//alert (response + " " + message);
	if ( response != 'Success') {
		pearlpbx_monitor_failed();
		return false;
	}
	pearlpbx_monitor_connected = true;
	//alert('connected1');
	callback_dest();

}
function pearlpbx_monitor_connect ( callback_dest ) {
	var username = "";
	var secret = "";

	$.getJSON('/route/manager/credentials', undefined, function (json) {
		username = json.username;
		secret = json.secret;
		// console.log (username + ":" + secret );
		astmanEngine.setURL("/asterisk/rawman");
    	astmanEngine.sendRequest('action=login&username=' + username + "&secret=" + secret,
    		pearlpbx_monitor_login, callback_dest );

	},"html");


  }

function pearlpbx_monitor_get_sip_status() {
	if ( pearlpbx_monitor_connected == false ) {
		pearlpbx_monitor_connect (pearlpbx_monitor_get_sip_status);
	} else {
		astmanEngine.sendRequest('action=SIPPeers',
			pearlpbx_monitor_set_sip_status,
			pearlpbx_monitor_fake_callback
		);
	}
}

function pearlpbx_monitor_set_sip_status(msgs) {

	var peers = 0;
	var online = 0;
	var unknown = 0;
	var unreachable = 0;

	if ( msgs[0].headers['response'] != 'Success') {
		if ( msgs[0].headers['response'] == 'Error') {
			if ( msgs[0].headers['message'] == 'Authentication Required') {
				pearlpbx_monitor_connected = false;
				pearlpbx_monitor_connect (pearlpbx_monitor_get_sip_status);
			}
			if ( msgs[0].headers['message'] == 'Permission denied') {
				pearlpbx_monitor_connected = false;
				pearlpbx_monitor_connect (pearlpbx_monitor_get_sip_status);
			}
			alert("Can't get info: "+msgs[0].headers['message']);
		}
		return false;
	}
	for (i = 1; i < msgs.length; i++ ) {

		if ( msgs[i].headers['event'] == 'PeerEntry') {
			peers = peers + 1;

			var status = msgs[i].headers['status'];
			//alert(status + ':' + status.search('OK'));
			if ( status.search('OK') > -1) {
				online = online + 1;
			}
			if ( status.search('LAGGED') > -1) {
				unknown = unknown + 1;
			}
			if ( status.search('Unmonitored') > -1) {
				unknown = unknown + 1;
			}
			if ( status.search ('UNREACH') > -1 ) {
				unreachable = unreachable + 1;
			}
		}

	}
	$('#pearlpbx_monitor_sip_peers').html(peers);
	$('#pearlpbx_monitor_sip_online').html(online);
	$('#pearlpbx_monitor_sip_unknown').html(unknown);
	$('#pearlpbx_monitor_sip_offline').html(unreachable);

	pearlpbx_monitor_get_queue_status();
}

function pearlpbx_monitor_fake_callback() {

}

function pearlpbx_monitor_get_sip_db() {
	$.get('/sip/monitor/get_sip_db',undefined,
	function(data) {
		$('#pearlpbx_monitor_sip_db').html(data);
	}, "html");

}

function pearlpbx_start_me_up() {

/*	var callerid = pearlpbx_load_callerid();
	if ( callerid == false ) {
		alert ("Загрузка таблицы преобразований номеров А закончилось с ошибкой! ");
		return false;
	}
	var convert = pearlpbx_load_convert_exten();
	if ( convert == false ) {
		alert ("Загрузка таблицы преобразований номеров Б закончилось с ошибкой!");
		return false;
	}

	//alert($('a#pearlpbx_username').text());
	pearlpbx_monitor_get_sip_db();
	pearlpbx_monitor_get_sip_status();
*/
    pearlpbx_monitor_get_sip_db();
    pearlpbx_monitor_get_sip_status();
}

function pearlpbx_add_convert_exten() {
	var exten = $('#pearlpbx_convert_exten').val();
	var operation = $('select#pearlpbx_convert_exten_operation option:selected').val();
	var param = $('#pearlpbx_convert_exten_param').val();
	var step = $('#pearlpbx_convert_exten_step').val();

	$.get("/route.pl", {
		a: "add_convert_exten",
		exten: exten,
		operation: operation,
		param: param,
		step: step
	}, function (data) {
		if (data == "OK") {
				pearlpbx_load_convert_exten();
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
function pearlpbx_convert_exten_remove (id) {
	var confirmed = confirm ("Вы действительно хотите удалить это преобразование ?");
	if (confirmed == true ) {
		$.get("/route.pl", {
			a: "remove_convert_exten",
			id: id,
		}, function (data) {
			if (data == "OK") {
				pearlpbx_load_convert_exten();
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
}
function pearlpbx_load_convert_exten() {

	var remicon = "<img src=/img/remove-icon.png width=16>";
	$('#pearlpbx_convert_exten_table tbody').empty();
	$('#pearlpbx_convert_exten_table').append("<tr><td colspan=5>Request sent...</td></tr>");
	$.getJSON("/route.pl",
	{
		a: "load_convert_exten",
	},function (json) {
		$('#pearlpbx_convert_exten_table tbody').empty();
		jQuery.each(json, function () {
			var remurl = '<td><a href="javascript:void(0)" onClick="pearlpbx_convert_exten_remove('+
			this['id']+')">'+remicon+'</a></td>';

			$('#pearlpbx_convert_exten_table').append("<tr><td>"+this['exten']
				+"</td><td>"+this['operation']+"</td>"
				+"<td>"+this['parameters']+"</td>"
				+"<td>"+this['step']+"</td>"
				+remurl
				+"</tr>");
		});

	} );

	return true;

}
function pearlpbx_sip_add_trunk() {
	$('#input_peer_edit_id').val('');
	$('#input_peer_edit_regstr_id').val('');
	$('#input_peer_edit_comment').val('');
	$('#input_peer_edit_name').val('');
	$('#input_peer_edit_username').val('');
	$('#input_peer_edit_secret').val('');
	$('#input_peer_edit_registration').prop('checked',false);
	$('#input_peer_edit_regstr').val('');
	$('#input_peer_edit_is_dynamic').prop('checked',false);
	$('#input_peer_edit_nat').prop('checked',false);
	$('#input_peer_edit_ipaddr').val('');
	$('#input_peer_edit_call_limit').val('');
}

function pearlpbx_sip_update_peer() {
	var sip_id = $('#input_peer_edit_id').val();
	var sip_comment = $('#input_peer_edit_comment').val();
	var sip_name = $('#input_peer_edit_name').val();
	var sip_username = $('#input_peer_edit_username').val();
	var sip_secret = $('#input_peer_edit_secret').val();
	var sip_remote_register = false;
	var sip_remote_regstr = $('#input_peer_edit_regstr').val();
	var sip_remote_regstr_id = $('#input_peer_edit_regstr_id').val();

	if ($('#input_peer_edit_registration').prop('checked') ) {
		sip_remote_register = true;
	}

	var sip_local_register = false;
	if ( $('#input_peer_edit_is_dynamic').prop('checked') ) {
		sip_local_register = true;
	}

	var sip_nat = false;
	if ( $('#input_peer_edit_nat').prop('checked') ) {
		sip_nat = true;
	}

	var sip_ipaddr = $('#input_peer_edit_ipaddr').val();
	var sip_call_limit = $('#input_peer_edit_call_limit').val();

// Submit
	$.get("/sip/setpeer",
		{
		  sip_id: sip_id,
		  sip_comment: sip_comment,
		  sip_name: sip_name,
		  sip_username: sip_username,
		  sip_secret: sip_secret,
		  sip_remote_register: sip_remote_register,
		  sip_remote_regstr_id: sip_remote_regstr_id,
		  sip_remote_regstr: sip_remote_regstr,
		  sip_local_register: sip_local_register,
		  sip_nat: sip_nat,
		  sip_ipaddr: sip_ipaddr,
		  sip_call_limit: sip_call_limit,
		},function(data)
		{
			if (data == "OK") {
				$('#pearlpbx-sip-connections-list').load('/sip/list/external');
				$('#pearlpbx_sip_edit_peer').modal('hide');
				return false;
			}
			alert("Server returns unrecognized answer. Please contact system administrator.");
			alert(data);
		}, "html");

}
function pearlpbx_edit_peer_is_dynamic() {

  if ($('#input_peer_edit_is_dynamic').prop('checked') ) {
		$('#div_input_peer_edit_ipaddr').hide();
		$('#input_peer_edit_registration').prop('checked',false);
		$('#div_input_peer_edit_regstr').hide();
		$('#input_peer_edit_ipaddr').val('');
	} else {
		$('#div_input_peer_edit_ipaddr').show();

	}
}
function pearlpbx_edit_peer_registration() {
	if ($('#input_peer_edit_registration').prop('checked') ) {
		$('#div_input_peer_edit_regstr').show();
		$('#input_peer_edit_is_dynamic').prop('checked',false);
		$('#div_input_peer_edit_ipaddr').show();
	} else {
		$('#div_input_peer_edit_regstr').hide();
	}

}
function pearlpbx_sip_load_external_id (sip_id) {
	$.getJSON("/sip/getpeer",
	{
		id: sip_id,
	}, function (json) {
		$('#input_peer_edit_id').val(json.id);
		$('#input_peer_edit_comment').val(json.comment);
		$('#input_peer_edit_name').val(json.name);
		$('#input_peer_edit_secret').val(json.secret);

		$('#input_peer_edit_call_limit').val(json.cl);
		$('#input_peer_edit_username').val(json.username);

		if (json.nat == 'force_rport,comedia') {
			$('#input_peer_edit_nat').prop('checked',true);
		} else {
			$('#input_peer_edit_nat').prop('checked',false);
		}

		if ( (json.type == 'friend') && ( json.host=='dynamic') )  {
			$('#div_input_peer_edit_ipaddr').hide();
			$('#input_peer_edit_ipaddr').val('');
			$('#input_peer_edit_is_dynamic').prop('checked',true);
			$('#div_input_peer_edit_regstr').hide();
		} else {
			$('#div_input_peer_edit_ipaddr').show();
			$('#input_peer_edit_ipaddr').val(json.ipaddr);
			$('#input_peer_edit_is_dynamic').prop('checked',false);
			$('#div_input_peer_edit_regstr').show();
		}
		$('#input_peer_edit_regstr').val(json.regstr);
		$('#input_peer_edit_regstr_id').val(json.regstr_id);

		if ( ( json.regstr_id != null ) && ( json.regstr_commented != 1 ) ) {
			$('#div_input_peer_edit_regstr').show();
			$('#input_peer_edit_registration').prop('checked',true);

		} else {
			$('#div_input_peer_edit_regstr').hide();
			$('#input_peer_edit_registration').prop('checked',false);
		}
	});
}

function pearlpbx_load_peers_as_options () {

	$.get("/sip.pl", {
		a: "list",
		b: "internalAsOptionIdValue"
	}, function (data) {
		$('select#pearlpbx_setcallerid_src_sip').empty();
		var x = '<optgroup><option value="Anybody">Для всех</option></optgroup>';
		$('select#pearlpbx_setcallerid_src_sip').append(x);
		$('select#pearlpbx_setcallerid_src_sip').append('<optgroup>');

		$('select#pearlpbx_setcallerid_src_sip').append(data);
		$('select#pearlpbx_setcallerid_src_sip').append('</optgroup><optgroup>');
		$.get("/sip.pl", {
			a: "list",
			b: "externalAsOptionIdValue"
		}, function (data) {
			$('select#pearlpbx_setcallerid_src_sip').append(data);
			$('select#pearlpbx_setcallerid_src_sip').append('</optgroup>');
		});
	});
}

function pearlpbx_load_directions_as_options() {

	$.get("/route.pl", {
		a: "list-directions-options",
	}, function (data) {
		$('select#pearlpbx_setcallerid_dest_direction').empty();
		$('select#pearlpbx_setcallerid_dest_direction').append(data);
	});

}
function pearlpbx_add_newcallerid () {
	var direction_id = $('select#pearlpbx_setcallerid_dest_direction option:selected').val();
	var sip_id = $('select#pearlpbx_setcallerid_src_sip option:selected').val();
	var callerid = $('#pearlpbx_setcallerid_value').val();

	if (direction_id == 'help') {
		alert("Пожалуйста, выберите направление.");
		return false;
	}
	if (sip_id == 'help') {
		alert("Пожалуйста, выберите подключение или пункт 'Для всех'.");
		return false;
	}
	//alert("direction_id="+direction_id+" sip_id="+sip_id+" callerid="+callerid);

	$.get("/route.pl",
		{ a: "setcallerid_add",
		  direction_id: direction_id,
		  sip_id: sip_id,
		  callerid: callerid,
		},function(data)
		{
			if (data == "OK") {
				pearlpbx_load_callerid();
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
function pearlpbx_setcallerid_remove (setcallerid_id) {

	var confirmed = confirm ("Вы действительно уверены в том, что хотите данную установку номера А ?");
	if (confirmed == true) {
		$.get("/route.pl",
		{ a: "setcallerid_remove_id",
		  b: setcallerid_id,
		},function(data)
		{
			if (data == "OK") {
				pearlpbx_load_callerid();
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
function pearlpbx_load_callerid() {
	pearlpbx_load_directions_as_options();
	pearlpbx_load_peers_as_options();

	var remicon = "<img src=/img/remove-icon.png width=16>";
	$('#pearlpbx_callerid_table tbody').empty();
	$('#pearlpbx_callerid_table').append("<tr><td colspan=5>Request sent...</td></tr>");
	$.getJSON("/route.pl",
	{
		a: "loadcallerid",
	},function (json) {
		$('#pearlpbx_callerid_table tbody').empty();
		jQuery.each(json, function () {
			var remurl = '<td><a href="javascript:void(0)" onClick="pearlpbx_setcallerid_remove('+
			this['id']+')">'+remicon+'</a></td>';

			$('#pearlpbx_callerid_table').append("<tr><td>"+this['name']
				+"</td><td>"+this['dlist_name']+"</td>"
				+"<td>"+this['set_callerid']+"</td>"
				+remurl
				+"</tr>");
		});

	} );


	return true;
}


function pearlpbx_logout() {
	window.location.assign('/login.pl?logout=1');
	return true;
}

function pearlpbx_load_lost_calls (queuename, sincedatetime,tilldatetime) {
	$('#pearlpbx_lost_calls_list tbody').empty();
	$('#pearlpbx_lost_calls_list').append("<tr><td colspan=5>Request sent...</td></tr>");
	$.getJSON("/reports.pl",
	{
		"exec-report": "listlostcalls",
		queuename: queuename,
		sincedatetime: sincedatetime,
		tilldatetime: tilldatetime,
	},function (json) {
		$('#pearlpbx_lost_calls_list tbody').empty();
		jQuery.each(json, function () {
			$('#pearlpbx_lost_calls_list').append("<tr><td>"+this['msisdn']
				+"</td><td>"+this['datetimelost']+"</td>"
				+"<td>"+this['holdtime']+"</td>"
				+"<td>"+this['lucky']+"</td>"
				+"<td>"+this['luckyhold']+"</td>"
				+"<td>"+this['outtime']+"</td>"
				+"<td>"+this['source']+"</td>"
				+"<td>"+this['billsec']+"</td>"
				+"</tr>");
		});
	} );

}
function pearlpbx_tgrpitem_remove (tgrp_item_id) {

	var confirmed = confirm ("Вы действительно уверены в том, что хотите удалить транк из группы ?");
	if (confirmed == true) {
		$.get("/route.pl",
		{ a: "tgrp_removemember",
		  member: tgrp_item_id,
		},function(data)
		{
			if (data == "OK") {
				var tgrp_id = $('#input_trunkgroup_hidden_id').val();
				var tgrp_name = $('#input_trunkgroup_edit_name').val();
				pearlpbx_trunkgroup_load_by_id(tgrp_id,tgrp_name);
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
function pearlpbx_trunkgroup_add_member() {
	var member = $('select#input_trunkgroup_edit_members option:selected').val();
	var tgrp_id = $('#input_trunkgroup_hidden_id').val();
	var tgrp_name = $('#input_trunkgroup_edit_name').val();

	$.get("/route.pl",
		{ a: "tgrp_addmember",
		  newmember: member,
		  tgrp_id: tgrp_id,
		},function(data)
		{
			if (data == "OK") {
				pearlpbx_trunkgroup_load_by_id(tgrp_id,tgrp_name);
				return true;
			}
			if (data == "ERROR") {
				alert("Сервер вернул ошибку!");
				return false;
			}
			if (data == "ALREADY") {
				alert ("Данный транк уже присутствует в группе.");
				return false;
			}
			alert("Server returns unrecognized answer. Please contact system administrator.");
			alert(data);
		}, "html");

}
function pearlpbx_trunkgroup_add(tgrp_name) {
	var valid = pearlpbx_validate_russian_name(tgrp_name);
	if (valid == false) {
		return false;
	}
	$.get("/route.pl",
		{ a: "newtrunkgroup",
		  b: tgrp_name,
		},function(data)
		{
			var result = data.split(":",2);
			if (result[0] == "OK") {
				$('#pearlpbx_trunkgroups_list').load('/route.pl?a=list-trunkgroups-tab');
				$('#pearlpbx_trunkgroup_edit').modal('hide');
				return true;
			}
			if (result[0] == "ERROR") {
				alert("Сервер вернул ошибку! : "+result[1]);
				return false;
			}
		}, "html");
	return false;
}

function pearlpbx_trunkgroup_update() {
	var tgrp_id = $('#input_trunkgroup_hidden_id').val();
	var tgrp_name = $('#input_trunkgroup_edit_name').val();
	if (tgrp_id == '') {
		// Добавляем новую группу
		return pearlpbx_trunkgroup_add(tgrp_name);
	}
	$.get("/route.pl",
		{ a: "updatetrunkgroup",
		  b: tgrp_id,
		  c: tgrp_name
		},function(data)
		{
			var result = data.split(":",2);
			if (result[0] == "OK") {
				$('#pearlpbx_trunkgroups_list').load('/route.pl?a=list-trunkgroups-tab');
				$('#pearlpbx_trunkgroup_edit').modal('hide');
				return true;
			}
			if (result[0] == "ERROR") {
				alert("Сервер вернул ошибку! : "+result[1]);
				return false;
			}
		}, "html");
	return false;
}
function pearlpbx_trunkgroup_remove() {
	var tgrp_id = $('#input_trunkgroup_hidden_id').val();
	if (tgrp_id == '') {
		alert("Невозможно удалить несохраненную группу.");
		return false;
	}

	var confirmed = confirm ("Вы уверены, что хотите удалить данную группу ?");
	if (confirmed == false) {
		return false;
	}

	$.get("/route.pl",
		{ a: "removetrunkgroup",
		  b: tgrp_id,
		},function(data)
		{
			var result = data.split(":",2);
			if (result[0] == "OK") {
				$('#pearlpbx_trunkgroups_list').load('/route.pl?a=list-trunkgroups-tab');
				$('#pearlpbx_trunkgroup_edit').modal('hide');
				return true;
			}
			if (result[0] == "ERROR") {
				alert("Сервер вернул ошибку! : "+result[1]);
				return false;
			}
		}, "html");
	return false;
}
function pearlpbx_empty_trunkgroup_edit_form() {
	$('#pearlpbx_edit_trunkgroup_items_list tbody').empty();
	$('#input_trunkgroup_hidden_oldname').val('');
	$('#input_trunkgroup_edit_name').val('');
	$('#input_trunkgroup_hidden_id').val('');

}
function pearlpbx_trunkgroup_load_by_id (tgrp_id, tgrp_name) {
	$('#input_trunkgroup_hidden_oldname').val(tgrp_name);
	$('#input_trunkgroup_hidden_id').val(tgrp_id);
	$('#input_trunkgroup_edit_name').val(tgrp_name);

	var remicon = "<img src=/img/remove-icon.png width=16>";

	$('#pearlpbx_edit_trunkgroup_items_list tbody').empty();
	$.getJSON("/route.pl",
	{
		a: "gettrunkgroup-items",
		b: tgrp_id,
	},function (json) {
		jQuery.each(json, function () {
			var remurl = '<td><a href="#" onClick="pearlpbx_tgrpitem_remove('+
			this['tgrp_item_id']+')">'+remicon+'</a></td>';

			$('#pearlpbx_edit_trunkgroup_items_list').append("<tr><td>"+this['name']+remurl+"</tr>");
		});
	} );

}

function pearlpbx_save_permissions() {
	var matrix = new String;
	var regstr=/^X\d+.Y\d+/;
	var count = 0;

	$('#pearlpbx_permissions_div').find('input[type=checkbox]').each(function() {
		//alert("id="+$(this).attr('id')+ " " + regstr.test( $(this).attr('id') ));
		var id = $(this).attr('id');
		if (regstr.test( id ) == true ) {
			count = count + 1;
			if ($(this).prop('checked') ) {
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
	var checked = $('#XYall').prop('checked');
	$('#pearlpbx_permissions_div').find('input[type=checkbox]').each(function() {
			if ( checked ) {
				$(this).prop('checked',true);
			} else {
				$(this).prop('checked',false);
			}
	});
}
function pearlpbx_permissions_set_y(yid) {
	var checked = $('#'+yid).prop('checked');
	$('#pearlpbx_permissions_div').find('input[type=checkbox]').each(function() {
		if ($(this).attr('id').search(yid+'$') >= 0) {
			if ( checked ) {
				$(this).prop('checked',true);
			} else {
				$(this).prop('checked',false);
			}
		}
	});
}
function pearlpbx_permissions_set_x(x) {
	var checked = $('#'+x).prop('checked');
	$('#pearlpbx_permissions_div').find('input[type=checkbox]').each(function() {
		if ($(this).attr('id').search(x) >= 0 ) {
			if ( checked ) {
				$(this).prop('checked',true);
			} else {
				$(this).prop('checked',false);
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
		$.getJSON("/route.pl", {
			a: "loadpermissionsJSON",
			}, function (json) {
				jQuery.each(json, function () {
				var id = "#X"+this['peer_id']+"_Y"+this['direction_id'];
				if ( $(id).length>0 ) {
					$(id).prop('checked',true);
				}
			} );
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

	$.get("/sip/list/internal", {
		format: "OPTION"
	}, function (data) {
		$('select#check_routing_channel').append(data);
		$('select#check_routing_channel').append('</optgroup><optgroup>');
		$.get("/sip/list/external", {
			format: "OPTION"
		}, function (data) {
			$('select#check_routing_channel').append(data);
			$('select#check_routing_channel').append('</optgroup>');
		});
	});

}
function pearlpbx_validate_routing ( dlist_id, route_step, route_type, route_dest, route_src) {

	// alert ("dlist_id: "+dlist_id + "\n" + "route_step: " + route_step + "\n" +
	//	"route_type: "+route_type + "\n" + "route_dest: " + route_dest + "\n" +
	//	"route_src: "+route_src
	//
	//	);

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
	var confirmed = confirm ("Are you sure you want to remove operator "+ membername+" from group "+qname+" ?");
	if (confirmed == true) {
		$.get("/queues/removemember",
		{
		  member: membername,
		  queue: qname,
		},function(data)
		{
			if (data == "OK") {
				pearlpbx_queues_load_by_name(qname);
				return true;
			}
			alert("Server returns unrecognized answer. Please contact system administrator.");
			alert(data);
		}, "html");
	}
}
function pearlpbx_queue_remove() {
	var qname = $('#input_queue_edit_name').val();
	if ( qname == '') {
		alert("Imposible remove group/queue without name!");
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
	$.get("/queues/delqueue",
		{
		  queue: qname,
		},function(data)
		{
			if (data == "OK") {
				pearlpbx_show_queues();
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
	$.get("/queues/addmember",
		{
		  newmember: operator,
		  queue: qname,
		},function(data)
		{
			if (data == "OK") {
				pearlpbx_queues_load_by_name(qname);
				return true;
			}
			if (data == "ALREADY") {
				alert ("Operator already in the group.");
				return false;
			}
			alert("Server returns unrecognized answer. Please contact system administrator.");
			alert(data);
		}, "html");
}

function pearlpbx_fill_operators_select () {
	$.get("/sip/list/internal", {
        format: "OPTION"
	},  function (data) {
		$('#input_queue_edit_members').empty();
		$('#input_queue_edit_members').append(data);
	}, "html");
}

function pearlpbx_validate_queue() {
	var name = $('#input_queue_edit_name').val();
    if (name == "" ) {
        alert("Input name of the queue!");
        return false;
    }
    var alphaExp = /^[0-9a-zA-Z]+$/;
    if(name.search(/[^0-9A-Za-z]/) != -1) {
    	alert("Queue name must contain only english letters andd digits without spaces.");
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
	$.get("/queues/setqueue",
		{
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
	$.getJSON("/queues/getqueue",
	{
		name: qname,
	},function (json) {
		$('#input_queue_hidden_oldname').val(json.name);
		$('#input_queue_edit_name').val(json.name);
		$('#input_queue_edit_strategy').val(json.strategy);
		$('#input_queue_edit_timeout').val(json.timeout);
		$('#input_queue_edit_maxlen').val(json.maxlen);
	} );

	$.getJSON("/queues/listmembers",
	{
		name: qname,
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
	$('#pearlpbx-queues-list').load('/queues/list?format=li');
	return false;
}

function pearlpbx_queue_edit_advanced_mode() {
	alert('Профессиональный режим редактирования групп/очередей будет доступен в следующей версии!');
}

function pearlpbx_sip_delete_user() {

    var confirmed = confirm("Are you sure to remove this user?\nThis operations is uncancellable.");
    if ( confirmed == true ) {

        var sip_id = $('#input_sip_edit_id').val();
        $.get("/sip/deluser",{ id: sip_id },
                function(data) {
                    if (data == "OK") {
                        $('#pearlpbx-sip-connections-list').load('/sip/list/internal');
                        $('#pearlpbx_sip_edit_user').modal('hide');
                        return false;
                    }
                    alert("Server returns unrecognized answer. Please contact system administrator.");
                    alert(data);
               }, "html");
    }
}

function pearlpbx_sip_update_user(){
	var sip_id = $('#input_sip_edit_id').val();
	var comment = $('#input_sip_edit_comment').val();
	var terminal = $('select#input_sip_edit_terminal option:selected').val();
	var macaddr = $('#input_sip_edit_macaddr').val();
	var secret = $('#input_sip_edit_secret').html();

 // Submit
	$.get("/sip/setuser",
		{ id: sip_id,
		  comment: comment,
		  terminal: terminal,
		  macaddr: macaddr,
		  secret: secret
		},function(data)
		{
			if (data == "OK") {
				$('#pearlpbx-sip-connections-list').load('/sip/list/internal');
				$('#pearlpbx_sip_edit_user').modal('hide');
				return false;
			}
			alert("Server returns unrecognized answer. Please contact system administrator.");
			alert(data);
		}, "html");
}
function pearlpbx_sip_load_id(sip_id) {
	$.getJSON("/sip/getuser",
	{
		id: sip_id,
	}, function (json) {
		$('#input_sip_edit_id').val(json.id);
		$('#input_sip_edit_comment').val(json.comment);
		$('#input_sip_edit_extension').html(json.extension);
		$('#input_sip_edit_secret').html(json.secret);
		$('#input_sip_edit_macaddr').val(json.mac_addr_tel);
		$('#input_sip_edit_terminal').val(json.teletype);
		$('#input_sip_edit_integration_type').val(json.integration_type);
		$('#input_sip_edit_ip_addr_tel').val(json.ip_addr_tel);
		$('#input_sip_edit_ip_addr_pc').val(json.ip_addr_pc);
		$('#input_sip_edit_tcp_port').val(json.tcp_port);
	});
}


function pearlpbx_sip_add_user(){
	var comment = $('#input_sip_add_comment').val();
	var extension = $('#input_sip_add_extension').val();
	var terminal = $('select#input_sip_add_terminal option:selected').val();
	var macaddr = $('#input_sip_add_macaddr').val();
	var secret = $('#input_sip_add_secret').html();
	var integration_type = $('select#input_sip_add_integration_type option:selected').val();
	var tcp_port = $('#input_sip_add_tcp_port').val();
	var ip_addr_tel = $('#input_sip_add_ip_addr_tel').val();
	var ip_addr_pc = $('#input_sip_add_ip_addr_pc').val();

	// FIXME: validate

	// Submit
	$.get("/sip/adduser",
		{ comment: comment,
		  extension: extension,
		  terminal: terminal,
		  macaddr: macaddr,
		  secret: secret,
		},function(data)
		{
			if (data == "OK") {
				$('#pearlpbx-sip-connections-list').load('/sip/list/internal');
				$('#add_sip_user').modal('hide');
				return false;
			}
			alert("Server returns unrecognized answer. Please contact system administrator.");
			alert(data);
		}, "html");
}

function pearlpbx_change_secret_add_form() {
	$('#input_sip_add_secret').load('/sip/newsecret');
	return false;
}
function pearlpbx_change_secret_edit_form() {
	$('#input_sip_edit_secret').load('/sip/newsecret');
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


function pearlpbx_sip_edit_id(sip_id) {
	alert("called sip_edit_id ( "+sip_id+" )");
}

function pearlpbx_fill_sip_form() {
	// $('.pearlpbx_internal_free_list').load('/sip.pl?a=list&b=internal-free');
	pearlpbx_change_secret_add_form();
}

function pearlpbx_show_sip_internal_users () {
	$('#pearlpbx-sip-connections-list').load('/sip/list/internal');
	$('#pearlpbx-sip-add-internal-button').css('display','block');
	$('#pearlpbx-sip-add-external-button').css('display','none');
}
function pearlpbx_show_sip_external_trunks () {
	$('#pearlpbx-sip-connections-list').load('/sip/list/external');
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

function turnOnPBXPlayer (cdr_start, cdr_src, cdr_dst, uniqueid ) {

 //alert (cdr_start + ' ' + cdr_src + ' ' + cdr_dst );
 $('#param_cdr_start').text(cdr_start);
 $('#param_cdr_src').text(cdr_src);
 $('#param_cdr_dst').text(cdr_dst);
 $('#param_uniqueid').text(uniqueid);

 $.get("recordings.pl",
    { "list-recordings": 1,
			start: cdr_start,
			src: cdr_src,
			dst: cdr_dst,
            uniqueid: uniqueid
    },function(data)
    {

      $('#recordings_table').html(data);
	  $("#jquery_jplayer_1").jPlayer( { swfPath: "/jPlayer" } );

    }, "html");

 return false;
}

function PBXPlayerSetMedia (url, type) {

pearlpbx_player_type = type;
pearlpbx_player_url = url;
$("#jquery_jplayer_1").jPlayer( "destroy" );
$("#jquery_jplayer_1").jPlayer({
        ready: function () {
          $(this).jPlayer("setMedia", {
                "mp3": pearlpbx_player_url,
          }).jPlayer("play");
        },
        swfPath: "/js",
        supplied: "mp3",
      });
  return false;
}

function pearlpbx_parse_internal_phone ( phone ) {
	if (phone == '') {
		alert ("Введите хотя бы 3 цифры номер телефона для поиска!");
		return false;
	}

  if (phone.length < 3 ) {
		alert ("Введите номер телефона, где количество цифр >= 3 !");
		return false;
	}

	return true;

}

function cdrfilter_validate() {
  return false;
}
function cdrfilter_submit () {

  var valid = cdrfilter_validate();

  var cdrfilter_dateFrom = $('#cdrfilter_dateFrom').val();
  var cdrfilter_timeFrom = $('#cdrfilter_timeFrom').val();
  var cdrfilter_dateTill = $('#cdrfilter_dateTill').val();
  var cdrfilter_timeTill = $('#cdrfilter_timeTill').val();

  var cdrfilter_src = $('#cdrfilter_src').val();
  var cdrfilter_dst = $('#cdrfilter_dst').val();

  var cdrfilter_channel = $('select#cdrfilter_channel option:selected').val();
  var cdrfilter_dstchannel = $('select#cdrfilter_dstchannel option:selected').val();

  var cdrfilter_disposition = $('select#cdrfilter_disposition option:selected').val();
  var cdrfilter_billsec = $('select#cdrfilter_billsec option:selected').val();

  $("#cdrfilter_result").html("Request sent...");
  $.get("/reports.pl",
    { "exec-report": "cdrfilter",
      dateFrom: cdrfilter_dateFrom,
      timeFrom: cdrfilter_timeFrom,
      dateTill: cdrfilter_dateTill,
      timeTill: cdrfilter_timeTill,
      src:      cdrfilter_src,
      dst:      cdrfilter_dst,
      channel:  cdrfilter_channel,
      dstchannel: cdrfilter_dstchannel,
      disposition: cdrfilter_disposition,
      billsec: cdrfilter_billsec,
    },function(data)
    {
      $('#cdrfilter_result').html(data);
    }, "html");

  return false;

}

function load_reports_names() {
//<!-- Скрипт, который заполняет список названий отчетов -->
    $.get("/reports.pl",
        { "list-reports": 1, },
        function(data) {
            $('#pearlpbx-general-reports-list').html(data);
        }, "html");

    $.get("/reports.pl",
        { "list-reports": 2, },
        function(data) {
            $('#pearlpbx-reports-bodies').html(data);
            $.get("/reports.pl",
                { "list-external-numbers": 1, },
                function(data) {
                    $('.pearlpbx-external-numbers').html(data);
                },"html");
            $.get("/reports.pl",
                { "list-queues":1, },
                function(data) {
                    $('.pearlpbx-list-queues').html(data);
                },"html");
        }, "html");

    $('#reports-summary-names').load('/reports.pl?list-reports=1&rtype=sum');
    $('#pearlpbx-summary-reports-bodies').load('/reports.pl?list-reports=2&rtype=sum');
    $('.pearlpbx_list_channels').load('/reports.pl?list-channels=1');
    pearlpbx_fill_check_routing_channel();
}

function load_trunkgroups_names() {
    $('#pearlpbx_trunkgroups_list').load('/route.pl?a=list-trunkgroups-tab');
}

function load_trunkgroups_members() {
    $('select#input_trunkgroup_edit_members').load("/sip.pl?a=list&b=externalAsOptionIdValue");
}

function load_ivr_modules() {
    $('#pearlpbx-modules-admin-ivr-list').load('/modules.pl?list-modules=1&rtype=ivr');
    $('#pearlpbx-modules-admin-ivr-bodies-preload').load('/modules.pl?list-modules=2&rtype=ivr');
}

function load_directions_names () {
    $('#pearlpbx_directions_list').load('/route.pl?a=list-directions-tab');
}


