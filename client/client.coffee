socket = io.connect window.location
socket.on 'connected', (data) =>
    console.log(data)
    socket.on('people', console.log)

