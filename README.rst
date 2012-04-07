A chat using Thoonk
===================

pre-requisites::

   npm -g install socket.io
   npm -g install coofee
   npm -g install thoonk
   apt-get install redis-server

daemon to compile coffee-script::

    coffee -w --compile --output public/lib/ client/

run webserver::

    coffee server/main.coffee

open test page::
    
    xdg-open http://localhost:8880/
