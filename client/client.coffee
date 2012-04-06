@socket = io.connect window.location
socket.on 'connected', (data) =>
    console.log(data)
    socket.on('people', console.log)
    socket.on('msg', console.log)
    socket.on('msgs', console.log)
    socket.on('join', console.log)
    socket.on('leave', console.log)
    socket.on('new_nick', console.log)

