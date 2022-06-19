const HTTPServer = require('./lib/HTTPServer.js');

const port = 4200;


let server = new HTTPServer(port, () => {
	console.log("Server running on port: ", port);
});

server.serveStatic('public');

