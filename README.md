### What's new ?

Lots! This is how I am installing OpenStack in a multi host environment.  At the moment this creates two classes of servers.

- all-in-one server
 - nova-api
 - nova-common
 - nova-network
 - nova-cert
 - nova-consoleauth
 - nova-scheduler
 - nova-novncproxy
 - nova-conductor
- nova-compute
 - nova-common
 - nova-compute
 - nova-network
 - nova-api-metadata
 - nova-novncproxy
 - nova-conductor

There currently no HA in this setup. That is something I'm working on. 

### Todo

- Add better instructions
- MySQL HA
- RabbitMQ HA
- Nova HA
- Ceph
- Quantum
- Celliometer   

### Contact

If you have a bug report, a feedback, a suggestion, or just want to say hi, you can contact me using [email](mailto:entropyworks@gmail.com) or [twitter](http://twitter.com/entropyworks).
