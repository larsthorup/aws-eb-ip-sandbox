const http = require('http');

const got = require('got');

const port = process.env.PORT || 1984;

function requestHandler (request, response) {
  const webhook = request.url.substr(1); // Note: skip the initial "/"
  console.log(webhook);
  if (webhook !== 'favicon.ico') {
    got(webhook).then(response => {
      console.log(response.body);
    }).catch(error => {
      console.error(error);
    });
    response.end('OK');
  }
}

const server = http.createServer(requestHandler);

server.listen(port, error => {
  if (error) {
    return console.error(error);
  }
  console.log(`server is listening on ${port}`);
});
