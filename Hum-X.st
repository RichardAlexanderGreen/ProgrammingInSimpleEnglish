ZnHTTPSocketFacade subclass: #HClient


  server stop.

  server stop.


	server delegate: nil.

  server stop.


  server stop.
  responseString := client get.
  
  self expect: ZnResponse actual: (client response class).




  responseString := client get.
  
  self expect: ZnResponse actual: (client response class).




  responseString := client get.
  
  self expect: ZnResponse actual: (client response class).




  response := client head. "In this case, we get ZnResponse back instead of ByteString."
  self expect: ZnResponse actual: (client response class).





			(v isKindOf: HEntity)  ifTrue: [ v printOn: stream. ] 			