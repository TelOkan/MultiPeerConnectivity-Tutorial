Two thing is very important.
1- This framework requires get two permission:
  1.a- Local Network Usage Description - String
  1.b- Bonjour services - item
2- ServiceType must be related with your Bonjour item. Otherwise Bonjour service won't work and then nobody can find you.
For example;
ServiceType: mytype
Bonjour Services İtem: _mytype._tcp (Because bonjour services item requires underscore)
