Object subclass: #HumOntologyTranslator
		 ifTrue: [ critique add: 'Vignette`s next context {',( self nextVignetteContext ),'} is unknown in ontology. ' ].
					ifFalse: ["Got to here with no match. But allow for dropped 'a', 'an', 'the', 'this', 'that'. "				
			].
	| s |