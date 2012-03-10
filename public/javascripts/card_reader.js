document.onkeypress = function(e) { return captureCardReader(e); }

var keyQueue = "";
var cardReaderEnabled = true;
var debug = true;

// Captures input that starts with a "&;" and ends with a ";"
function captureCardReader(e) {
	var k
	if (!e) e = window.event
	document.all ? k = e.keyCode : k = e.which
	var ch = String.fromCharCode(k)

	if (keyQueue == "" && ch == "&") { // start queueing if we have a "&" to start
		keyQueue = ch
		updatekq()
		return false;
	} else if (keyQueue != "" && (ch.match(/[;A-F\d]/))) { // add any new characters to the queue
		keyQueue += ch
		updatekq()
		return false;
	} else if (keyQueue != "" && k == 13) { // if we get an ENTER we're at the end
		processCardReaderInput()
		keyQueue = ""
		updatekq()
		return false;
	} else if (keyQueue.length > 20) {
		keyQueue = ""
		updatekq()
	}
}

function updatekq() {
	// $('keyQueue').innerHTML = keyQueue;
	return true
}

function processCardReaderInput() {
	if (debug) { window.console.log("keyQueue: " + keyQueue) }
	regexp = /\&;([A-F\d]{6,16});/
	if (!cardReaderEnabled) {
		return false
	}
	if (keyQueue.match(regexp) && $('tag_id')) {
		$('tag_id').value = keyQueue.match(regexp)[1]
		if (debug) { window.console.log("tag_id: " + $('tag_id').value) }
		// $('tag_id').up('form').submit();
	} else {
		if (debug) { window.console.log("  ERROR (keyQueue did not match regexp "+ regexp + ")") }
	}
}

function disableCardReader() {
	cardReaderEnabled = false
	if($('cardStatus')) {
		$('cardStatus').removeClassName('on')
		$('cardStatus').addClassName('off')		
	}
	return cardReaderEnabled
}

function enableCardReader() {
	cardReaderEnabled = true
	if($('cardStatus')) {
		$('cardStatus').removeClassName('off')
		$('cardStatus').addClassName('on')
	}
	return cardReaderEnabled
}

function toggleCardReader() {
	if (cardReaderEnabled) {
		disableCardReader()
	} else {
		enableCardReader()
	}
	return cardReaderEnabled
}
