var http = require('http');

http.createServer(function (request, response) {
    response.writeHead(200, {'Content-Type': 'text/plain'});
    response.end('Hello World\n');
}).listen(3000);

console.log('Server started');

const Salt = require("salt-api");

const salt = new Salt({
	url: "http://192.168.25.7:8080/hook",
	username: "labuser",
	password: "labpassword"
});


salt.ready.then(() => {

	console.log("Salt ready...")

	/*// Same as running `salt "*" test.ping` in the command line
	salt.fun("*", "test.ping").then(data => {

		// Do something with the data
		console.log(data);
		// { return: [ { b827eb3aaaf7: true, b827ebcc82fe: true } ] }

	}).catch(e => console.error(e));*/

});