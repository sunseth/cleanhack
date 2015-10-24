module.exports =
  port: 9001
  mongo:
    uri: 'mongodb://localhost:27017/berc'
    options:
      server:
        socketOptions: {keepAlive: 1, connectTimeoutMS: 60000}