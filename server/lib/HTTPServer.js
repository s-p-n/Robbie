const http = require('http');
const path = require('path');
const fs = require('fs/promises');
const root = process.mainModule.path;
const rootPathRegex = /([A-Z]\:\\|\/).+/;
const uuidv4 = require('uuid').v4;

function pathToURL(p) {
	return p.toLowerCase().replace('\\', '/');
}

function prepareURL(url) {
	return url.substring(1).toLowerCase();
}

async function searchRecursive (directory, original = false) {
	let result = {};

	if (!rootPathRegex.test(directory)) {
		directory = path.join(root, directory);
	}

	if (!original) {
		original = directory;
	}

	try {
		const dir = await fs.opendir(directory) 

		for await (const entry of dir) {
			const filename = entry.name;

			if (filename == "." || filename == "..") {
				return;
			}

			const address = path.join(directory, filename);

			if (entry.isDirectory()) {
				result = {
					...result,
					...(await (searchRecursive(address, original)))
				};
			} else {
				const url = pathToURL(path.relative(original, address));
				result[url] = {
					url,
					address,
					contents: null
				};
			}
		}
	} catch (err) {
		console.error(err);
	}

	return result;
}

class HTTPServer {
	constructor (port = 8080, startCallback = () => {}) {
		this.server = http.createServer(this.handleRequest());
		this.ready = false;
		this.port = port;
		this.startCallback = startCallback;
		this.publicDir = uuidv4(); // prevent accidentally hosting wrong dir
		this.fileSystem = {};
	}

	async serveStatic (directory) {
		this.publicDir = directory;
		this.fileSystem = await searchRecursive(directory);

		console.log("Prepared fileSystem");
		//console.log(this.fileSystem);
		this.server.listen(
			this.port, 
			() => {
				this.ready = true;
				return this.startCallback(this);
			}
		);
	}

	handleRequest() {
		return async (req, res) => {
			if (!this.ready) {
				console.error("Warning: Caught attempt to handle request before HTTPSever is ready.")
				return this.endResponseFalsey(res);
			}

			const url = prepareURL(req.url);

			if (url === '') {
				return this.redirect('/index.html', res);
			}

			console.log(`Got request for '${url}'`);
			//console.log(this.fileSystem);
			console.log(url in this.fileSystem);
			if (url in this.fileSystem) {
				let contents = this.fileSystem[url].contents;
				console.log("URL is in fileSystem.");
				if (contents === null) {
					const address = this.fileSystem[url].address;
					console.log(`No cache found for '${address}'\nLoading file..`)
					try {
						contents = await fs.readFile(address);
						this.fileSystem[url].contents = contents;
						console.log(`File loaded for '${url}'`);
					} catch (err) {
						console.error(err);
						return this.endResponseFalsey(res);
					}
				}
				return this.endResponse(url, res);
			}

			return this.endResponseFalsey(res);
		};
	}

	redirect (location, res) {
		console.log(`sending redirect to '${location}'`);
		res.writeHead(302, {
			location
		});
		res.end();
	}

	endResponse (url, res) {
		console.log(`Sending response for '${url}'`);

		res.writeHead(200);
		res.end(this.fileSystem[url].contents)
	}

	endResponseFalsey (res) {
		console.log("Sending falsey response.");

		res.writeHead(404,{
			'content-type': 'text/html'
		});

		res.end("Something went wrong.");
	}
}

module.exports = HTTPServer;