
var nodeio = require("node.io");
var http = require("http");
var fs = require("fs");
var jsdom = require("jsdom").jsdom;
var unzip = require("unzip");

var url = "http://www.gesetze-im-internet.de/";

var options = {
	host: "www.gesetze-im-internet.de",
	port: 80,
	method: "GET",
	path: "/Teilliste_9.html"
};
var req = http.request(options, function(res) {
	var html = "";
	res.setEncoding("UTF-8");
	res.on("data", function(data) {
		html += data;
	});
	res.on("end", function() {
		jsdom.env(
		    html,
		    [ 'http://code.jquery.com/jquery-1.8.0.min.js' ],
		    function (errors, window) {
		    	if (errors) {
		    		return;
		    	}

		    	var abbrevs = [];
		    	(function($) {
		    		$("#container a[href*='.html']").each(function() {
		    			var abbrev = this.getAttribute("href").replace(/.\/([^\/]+).*/, "$1");
		    			abbrevs.push(abbrev);
		    		});
		    	}(window.jQuery));
		    	retrieve(abbrevs);
		    }
		);
	});
});
req.end();

function retrieve(abbrevs) {
	var abbrev = abbrevs.shift();
	console.log("Loading " + abbrev);
	var stream = unzip.Extract({ path: "data" });
	//var stream = fs.createWriteStream("data/" + abbrev + ".zip");
	var options = {
		host: "www.gesetze-im-internet.de",
		port: 80,
		path: "/" + abbrev + "/xml.zip",
		method: "GET"
	};
	var req = http.request(options, function(res) {
		res.on("data", function(data) {
			stream.write(data);
		});
		res.on("end", function() {
			stream.end();
			if (abbrevs.length) {
				retrieve(abbrevs);
			}
		});
	});
	req.on("error", function(e) {
		console.log("Problem loading zip: " + e.message);
		stream.end();
	});
	req.end();
}

// var methods = {
// 	input: false,
// 	run: function() {
// 		console.log("Loading...");
// 		var self = this;
// 		this.getHtml(url + 'Teilliste_B.html', function(err, $) {
// 			if (err) this.exit(err);

// 			var item = 0;
// 			$('#paddingLR12 a[href*="html"]').each("href", function(link) {
// 				var abbrev = link.replace(/.\/([^\/]+).*/, "$1");
// 				item++;
// 				if (item > 1) self.exit("aborted");
// 				var stream = fs.createWriteStream(abbrev + ".zip");
// 				var options = {
// 					host: "www.gesetze-im-internet.de",
// 					port: 80,
// 					path: "/" + abbrev + "/xml.zip",
// 					method: "GET"
// 				};
// 				var req = http.request(options, function(res) {
// 					res.on("data", function(data) {
// 						stream.data(data);
// 					});
// 					res.on("end", function() {
// 						stream.end();
// 					});
// 				});
// 				req.on("error", function(e) {
// 					console.log("Problem loading zip: " + e.message);
// 					stream.end();
// 				});
// 				req.end();
// 			});
// 		});
// 	}
// };

// var job = new nodeio.Job({timeout: 10}, methods);
// nodeio.start(job);