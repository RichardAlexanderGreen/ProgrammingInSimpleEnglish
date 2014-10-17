!classDefinition: #HumBlackBoard category: #'Hum-RunTime'!
Object subclass: #HumBlackBoard
	instanceVariableNames: 'quads worldbase worldbaseID defaultEntity entityIdentifiers'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumBlackBoard commentStamp: 'RichardAlexanderGreen 4/20/2014 15:50' prior: 0!
The blackboard holds the values for nouns in memory that are currently being referenced by an agent.In addition, the blackboard operates the persistence mechanism so that new noun values are recorded on the world-base (database). TODO: Deal with attributes that are collections (bag, set, list).- The items in a collection are entities. (They are identifiable and countable.)- That implies that they have identifiers.- The collection itself has an identifier.- Let a collection attribute be a Hum datatype. . . Then it supports the Hum equivlalent of add: item, remove: item, do: [:item| ...], asStream. . . A Hum list also supports append: item, prepend: item, first, last.. . Updating a collection is handled the same as updating other datatypes.. . The difference will be that the entities in the collection must also be on the blackboard.. . And, the collections only contain identifiers.!


!HumBlackBoard methodsFor: 'private' stamp: 'RichardAlexanderGreen 10/18/2012 11:48'!
quads	^ quads ifNil: [ quads := Dictionary new. ].! !

!HumBlackBoard methodsFor: 'private' stamp: 'RichardAlexanderGreen 7/24/2013 11:01'!
worldbase	^ worldbase ifNil: [Error signal: 'Blackboard configured without a world base.']! !


!HumBlackBoard methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/6/2014 14:44'!
appendEntity: childEntityID toEntity: parentEntityID list: anAttributeName 	"Append the given child entity to the named list attribute"	| list attribute |	self assert: ( childEntityID isKindOf: HumIdentifier ).		self assert: ( parentEntityID isKindOf: HumIdentifier ).	self assert: ( anAttributeName isKindOf: String ).	attribute := self cleanAttribute: anAttributeName.	list := self getEntityID: parentEntityID attribute: attribute.	( list isKindOf: OrderedCollection )		ifFalse: [ list := OrderedCollection new].	list addLast: childEntityID.	self setEntityID: parentEntityID attribute: attribute toValue: list.! !

!HumBlackBoard methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/6/2014 14:29'!
cleanAttribute: anAttributeNameString 	| result |	result := ((anAttributeNameString isKindOf: String ) 	                              ifTrue: [ anAttributeNameString ] 	                             ifFalse: [ self halt. anAttributeNameString asString. ]) trimBoth asLowercase.	^result.! !

!HumBlackBoard methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/6/2014 14:43'!
cleanEntity: anEntityNameString 	| result |	result := ( anEntityNameString ifNil: [self defaultEntity ] ) trimBoth asLowercase.	self assert: (result isKindOf: String).	^result.! !

!HumBlackBoard methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/19/2014 10:43'!
defaultEntity	^ defaultEntity ifNil: ['default'].! !

!HumBlackBoard methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/6/2014 14:42'!
defaultEntity: aString	"This will be the entity when caller send nil for entityName" 	defaultEntity := self cleanEntity: aString. ! !

!HumBlackBoard methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/24/2014 09:21'!
entityIdentifiers	^ entityIdentifiers ifNil: [entityIdentifiers := Dictionary new].! !

!HumBlackBoard methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/6/2014 14:40'!
generateNewIdentifierForEntityName: anEntityName	"Ask the attached world base for a new unique identifier."	| id entity |	entity := self cleanEntity: anEntityName.	id := HumIdentifier createUniqueIdentifierForEntityName: entity.	^id.! !

!HumBlackBoard methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/6/2014 14:39'!
getEntityID: entityID attribute: anAttributeName 	" Get requested value (if any) from the blackboard instance "	| valueAndTau value tau attribute |	self assert: (entityID isKindOf: HumIdentifier ).	attribute := self cleanAttribute: anAttributeName.		valueAndTau := (self quads ) at: ( entityID -> attribute ) ifAbsent: [ ^nil ].	"ToDo: If I don't have it, maybe WorldBase does. "	value := valueAndTau at: 1.	tau := valueAndTau at: 2.	^ value.! !

!HumBlackBoard methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/6/2014 14:38'!
getEntityName: anEntityName attribute: anAttributeName 	"for now - same as get by ID"	| value entityName entityID attributeName  |	entityName := self cleanEntity: anEntityName.	attributeName := self cleanAttribute: anAttributeName.		entityID := self identifierForEntityName: entityName.	value := self getEntityID: entityID attribute: attributeName.	^value.! !

!HumBlackBoard methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/6/2014 14:38'!
identifierForEntityName: anEntityName 	"Do I already have an entity of that name? 	 If so, assign the same ID. Otherwise, get a new identifier."	| id entity | 	entity := self cleanEntity: anEntityName.	id := (self entityIdentifiers) at: entity 	     ifAbsent: [ entityIdentifiers at: entity put: (self generateNewIdentifierForEntityName: entity). ].	^id.! !

!HumBlackBoard methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/6/2014 14:37'!
setEntityID: entityID attribute: anAttributeName toValue: aValue	"Store given value in the blackboard with a time-stamp. 	 *** Side Effect: Notify the World Base. ***"	| tau  attributeName |	self assert: ( entityID isKindOf: HumIdentifier ).	attributeName := self cleanAttribute: anAttributeName.			"Put value of entity attribute and the timestamp."	tau := HumIdentifier createUniqueIdentifierForEntityName: 'some event'. "TODO: Relate this to a business event."	( self quads ) at: ( entityID -> attributeName ) put: { aValue. tau. }.		"Update the world base also."	(worldbase notNil) 		ifTrue: [			(( self worldbase ) isKindOf: String ) 				ifTrue: [ worldbase := HumWorldBase new. 					( self worldbase ) setEntityID: entityID attribute: attributeName toValue: aValue.					].			]		ifFalse: ["Okay. Some actor blackboard updates do not need to be recorded in real time."			].		"TODO: Blackboard detects mutations ? -- And then what?"	"TODO: Code critic flags mutation as Error?"	"COMMENT: Mutation in the world-base is treated via versioning."! !

!HumBlackBoard methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/10/2014 09:54'!
setEntityName: anEntityName attribute: anAttributeName toValue: aValue	"for now -- same as:"	| entityID entityName attributeName |  entityName := self cleanEntity: anEntityName.  attributeName := self cleanAttribute: anAttributeName.	"Do I already have an entity of that name? 	 If so, assign the same ID. Otherwise, get a new identifier."	entityID := self identifierForEntityName: entityName.		( anAttributeName sameAs: aValue asString   )		ifTrue: ["When the value matches the attribute name, the value references an entity."			| referencedEntityID |			referencedEntityID := self identifierForEntityName: anAttributeName.			self setEntityID: entityID attribute: attributeName toValue: referencedEntityID.			^self.			].		self setEntityID: entityID attribute: attributeName toValue: aValue.		! !

!HumBlackBoard methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/24/2013 11:02'!
worldbase: aHumWorldBase 	worldbase := aHumWorldBase! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumBlackBoard class' category: #'Hum-RunTime'!
HumBlackBoard class
	instanceVariableNames: ''!

!HumBlackBoard class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 4/1/2014 16:08'!
worldbase: aString 	| instance |	instance := self basicNew.	instance worldbase: aString.	^instance.! !


!classDefinition: #HumCalculator category: #'Hum-RunTime'!
Object subclass: #HumCalculator
	instanceVariableNames: 'priorCaseIsTrue indentString'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumCalculator commentStamp: 'RichardAlexanderGreen 8/16/2013 14:07' prior: 0!
The Calculator role (agent) provides - base level arithmetic (using measures)- string utilities used to parse Hum source code.The Calculator provides compute operations.When a Hum procedure (or Hum Run-Time) needs an interface to the host computer, the Calculator provides it.See also: HumMeasure. -- In the Hum framework, all numbers are measures.See also: HumFuzzy.-- HumFuzzy provides arithmetic on S-curve distributions.TODO: Integrate HumMeasure and HumCalculator.!


!HumCalculator methodsFor: 'parsing' stamp: 'RichardAlexanderGreen 10/17/2014 09:22'!
fillTemplate: template fromDictionary: dictionary	"Create a String based on the given template and parameters."	| result |	result := template.	[ result includesSubString: '@']		whileTrue: ["Replace the first parameter with its value"			| front back name value delimiters |				front := self given: result extractUpto: '@'.			back := self given: result extractAfter: '@'.			"Get and remove the name of the parameter"			delimiters := '					 ~!!@#$%^&*()_+`-=[]\{}|:";<>?,./'''.			name := (back findTokens: delimiters ) at: 1.			"Insert the value of the parameter"			value := dictionary at: name.			self assert: (value isKindOf: String ).			back := self given: back extractAfter: name.			result := front, value, back.			].	^result.! !

!HumCalculator methodsFor: 'parsing' stamp: 'RichardAlexanderGreen 6/13/2014 08:44'!
given: sourceString extractAfter: stringA 	"Return the substring in the sourceString between the two."	| result |	result := HumCalculator given: sourceString extractAfter: stringA.	^result.! !

!HumCalculator methodsFor: 'parsing' stamp: 'RichardAlexanderGreen 3/1/2014 10:10'!
given: input extractAfterSecond: marker 	"Parse cases like matching quotes or markup emphasis."	| wip result |	wip := self given: input extractAfter: marker.	result := self given: wip extractAfter: marker.	^result.! !

!HumCalculator methodsFor: 'parsing' stamp: 'RichardAlexanderGreen 6/13/2014 08:50'!
given: sourceString extractBetween: stringA and: stringB	"Return the substring in the sourceString between the two."	| result |	result := HumCalculator given: sourceString extractBetween: stringA and: stringB.	^result.! !

!HumCalculator methodsFor: 'parsing' stamp: 'RichardAlexanderGreen 6/13/2014 08:46'!
given: sourceString extractUpto: stringA 	"Return the substring in the sourceString between the two."	|   result |	result := HumCalculator given: sourceString extractUpto: stringA.	^result.! !

!HumCalculator methodsFor: 'parsing' stamp: 'RichardAlexanderGreen 10/7/2014 12:30'!
parse: aString	"Parse into { token. type. start. stop. }"	| sequence |	sequence := OrderedCollection new.	self parse: aString startingAt: 1 appendTokenTo: sequence.	^sequence.			! !

!HumCalculator methodsFor: 'parsing' stamp: 'RichardAlexanderGreen 10/7/2014 13:15'!
parse: aString startingAt: start appendTokenTo: sequence	"Parse into { token. type. start. stop. }"	|  whitespace separators quotes quote doubleQuote isWhiteSpace isSeparator tests type isQuote priorQuote alphabet isAlphabet isQuotedText mode currentCharacter stop lex |	self assert: (sequence isKindOf: OrderedCollection).	self assert: (start > 0).	"Terminate if start is greater than aString."	(start > aString size) ifTrue: [^self].	"Set up terminal token definitions."	whitespace := ' 			'.	quote := ($' asString).	doubleQuote := ($" asString).	quotes := quote, doubleQuote.	priorQuote := quote.	separators := '~!!@#$%^&*()_+`={}|[]\:;<>?,./'.	alphabet := 'qwertyuiopasdfghjklzxcvbnm1234567890-'.		"Side-effect sets type in detect:[]"	isWhiteSpace := [ :ch | type := #whitespace. whitespace includes: ch ].	isSeparator  := [ :ch | type := #separator.  separators includes: ch ].	isAlphabet   := [ :ch | type := #word.       alphabet includes: (ch asLowercase)].	isQuote      := [ :ch | type := #quote.      quotes includes: ch ].	isQuotedText := [ :ch | type := #string.    ( priorQuote = ch ) not ].				tests := { isWhiteSpace. isSeparator. isAlphabet. isQuote. isQuotedText. }.	"mode is determined by the starting character"	currentCharacter := aString at: start.	mode := tests detect: [ :test | test value: currentCharacter.].	( type = #quote ) 		ifTrue: [ mode := isQuotedText. priorQuote := currentCharacter. ].	"The next lex is string starting with current character that matches mode test."	(start = aString size) 		ifTrue:  [stop := start ]		ifFalse: [ |x|			x := ( (start+1) to: (aString size) ) 								detect: [ :iCharacter | (mode value: (aString at: iCharacter)) not ].			(mode = isQuotedText) ifTrue: [ stop := x ] ifFalse: [ stop := x - 1 ].			 			].	lex := aString copyFrom: start to: stop .	sequence add: { lex. type. start. stop. }.	"Call self recursively"	self parse: aString startingAt: (stop + 1) appendTokenTo: sequence.	! !

!HumCalculator methodsFor: 'parsing' stamp: 'RichardAlexanderGreen 10/7/2014 11:49'!
zparse: aString	"Parse into { token. type. start. stop. }"	| sequence mode whitespace separators quotes quote doubleQuote isWhiteSpace lex isSeparator isNonQuote modes start stop token type isQuote priorQuote test appendLex alphabet isAlphabet priorMode |	sequence := OrderedCollection new.	whitespace := ' 			'.	quote := ($' asString).	doubleQuote := ($" asString).	quotes := quote, doubleQuote.	priorQuote := quote.	separators := '~!!@#$%^&*()_+`={}|[]\:;<>?,./'.	alphabet := 'qwertyuiopasdfghjklzxcvbnm1234567890-'.		"Side-effect sets type in detect:[]"	isWhiteSpace := [ :ch | type := #whitespace. whitespace includes: ch ].	isSeparator  := [ :ch | type := #separator.  separators includes: ch ].	isAlphabet   := [ :ch | type := #word.       alphabet includes: (ch asLowercase)].	isQuote      := [ :ch | type := #quote.      quotes includes: ch ].	isNonQuote   := [ :ch | type := #string.    ( priorQuote = ch ) not ].		modes := { #whitespace -> isWhiteSpace. 						#separator -> isSeparator. 						#quote -> isQuote. 						#word -> isAlphabet.						#string -> isNonQuote. }.	mode := #whitespace.	start := stop := 0.	token := ''.	appendLex := [ :x | 								stop := x.								type := mode.					      lex := { token. type. start. stop. }.							  sequence add: lex.].	( 1 to: aString size )		do: [ :iCharacter |			| character |			character := aString at: iCharacter.			modes do: [:association |  			 ( association key = mode ) 			  ifTrue: [test := association value]].			 ( test value: character ) 				ifTrue: [ token := token, character asString. ]				ifFalse: [ "End of current lex detected. Record current lex." 									(mode := #string)										ifTrue: [ "Current lex includes the closing quote."											token := token, character asString. 											appendLex value: iCharacter.											token := String new. 									    start := iCharacter + 1.											]										ifFalse: [ "Record token. Do not include current character."											appendLex value: iCharacter - 1.											"Start next token"											token := character asString. 									    start := iCharacter.											].					        									 "Set up next lex"					         									 "Reset mode."									 modes detect: [ :association |   										| key block result | 										key := association key.										block := association value.										"First mode that matches current character will terminate detect loop."										result := block value: character.										result 											ifTrue: [ 												priorMode := mode. "Remember prior mode - to fudge for quoted strings."												mode := key. "Reset the mode - tentatively."												"Change mode to #string when we see a starting quote."												((priorMode ~= #string) and: [isQuote value: character]) 												   ifTrue: [														priorQuote := character. 														"appendLex value: iCharacter. token := ''."														mode := #string. 														].												].										"assure result - boolean that controls detect loop."										result. 										].								].			].	appendLex value: ( aString size ).		^sequence.			! !


!HumCalculator methodsFor: 'xml' stamp: 'RichardAlexanderGreen 5/28/2014 10:49'!
xml: aTagString dictionary: aDictionary 	"Create a stand-alone tag (ending with '/>') with the given attribute values."	| xml space equals quote  |  space := String space.	equals := '='.	quote := $" asString.	"Don not mess with indent here. Caller should handle."	xml := '<', aTagString.	aDictionary keysSortedSafely 		do: [ :key  |			| value |			value := aDictionary at: key. 			xml := xml, space, key asString, equals, quote, value asString, quote.			].	xml := xml, ' />', String cr.	^xml.! !

!HumCalculator methodsFor: 'xml' stamp: 'RichardAlexanderGreen 5/28/2014 11:11'!
xml: aTagString dictionary: aDictionary with: aBlockClosure 	"Generate the front tag and the end tag with block to produce the middle"	| frontTag xml cr indent priorIndent |	self assert: ( aDictionary isKindOf: Dictionary ).	cr := String cr.	priorIndent := indentString.	indent := indentString, String tab.	indentString := indent.	frontTag :=  self xmlOpen: aTagString dictionary: aDictionary.	xml := indent, frontTag, cr, 	       indent, ( aBlockClosure value ), cr,			   indent, '</', aTagString, '>', cr.	"Restore prior indent"	indentString := priorIndent.	^xml.! !

!HumCalculator methodsFor: 'xml' stamp: 'RichardAlexanderGreen 5/28/2014 11:11'!
xml: aTag with: aBlock 	"Fix up the indent after we get this working."	| xml cr priorIndent indent insert |	insert := aBlock value.	self assert: ( insert isKindOf: String ).	cr := String cr.	priorIndent := indentString.	indent := indentString, String tab.	"Change the indent that child process will see."	indentString := indentString, '  '.	xml  := indent,'<', aTag, '>', cr			 , indent, insert, cr			 , indent, '</', aTag, '>', cr.	"Restore prior indent."	indentString := priorIndent.	^xml.! !

!HumCalculator methodsFor: 'xml' stamp: 'RichardAlexanderGreen 5/28/2014 10:48'!
xmlOpen: aTagString dictionary: aDictionary 	"Create an opening tag ( NOT ending with '/>' ) with the given attribute values."	| xml space equals quote |	self assert: ( aDictionary isKindOf: Dictionary ).	space := String space.	equals := '='.	quote := $" asString.  "Do no mess with indent here. Caller should handle."	xml := '<', aTagString.	aDictionary keysSortedSafely 		do: [ :key  |			| value |			value := aDictionary at: key. 			xml := xml, space,  key, equals, quote,  value, quote.			].		xml := xml, ' >', String cr.	^xml.! !


!HumCalculator methodsFor: 'case statement cascade' stamp: 'RichardAlexanderGreen 10/14/2014 15:56'!
cases	"Initialize case cascade.	Usage:	calculator cases;		 when: [ block returning boolean] then: [ some action];		 when: [ block returning boolean] then: [ some action];		 otherwise: [ action if all the when-blocks are false ].	See also:		object caseOf: {value->block. value->block.} otherwise: [action if no value matches]		"	priorCaseIsTrue := false.	! !

!HumCalculator methodsFor: 'case statement cascade' stamp: 'RichardAlexanderGreen 5/13/2014 08:55'!
otherwise: thenBlock	"If a prior case was true, ignore this case. 	 Otherwise, execute this block."		( self priorCaseIsTrue ) ifTrue: [ ^self ].	"otherwise"	thenBlock value.	^self.	! !

!HumCalculator methodsFor: 'case statement cascade' stamp: 'RichardAlexanderGreen 3/26/2014 16:57'!
when: whenBlock then: thenBlock	"If the whenBlock evaluated to true, execute the thenBlock."	| |	"If a prior case was true, ignore this case."		( self priorCaseIsTrue ) ifTrue: [ ^self ].	"If the when block is true"	( whenBlock value ) 		ifTrue: [ 			priorCaseIsTrue := true. 			thenBlock value ].	^self.	! !


!HumCalculator methodsFor: 'converting' stamp: 'RichardAlexanderGreen 2/24/2014 12:29'!
given: input replaceAll: old with: new 	| s before between after|	s := input.	[ ('*',old,'*') matches: s ]		whileTrue: ["Replace old with new"			before := self given: s extractUpto: old.			after  := self given: s extractAfter: old.			s := before,new,after.			].	^s.! !


!HumCalculator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/28/2014 10:31'!
initialize	indentString := String new.! !

!HumCalculator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/19/2014 16:13'!
priorCaseIsTrue	^ priorCaseIsTrue ifNil: [priorCaseIsTrue := false ].! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumCalculator class' category: #'Hum-RunTime'!
HumCalculator class
	instanceVariableNames: ''!

!HumCalculator class methodsFor: 'string utilities' stamp: 'RichardAlexanderGreen 6/13/2014 08:44'!
given: stringIn extractAfter: stringA 	"Get the substring that is between the two given."	| x1 stringOut s |	s := stringIn.	stringOut := ''.	x1 := s findString: stringA startingAt: 1.	(x1 > 0 ) 		ifTrue: [ stringOut := stringIn copyFrom: (x1 + stringA size) to: (stringIn size). 			 ].	^stringOut.! !

!HumCalculator class methodsFor: 'string utilities' stamp: 'RichardAlexanderGreen 6/13/2014 20:22'!
given: stringIn extractBetween: stringA and: stringB	"Get the substring that is between A and B."	| temp result |  temp := HumCalculator given: stringIn extractAfter: stringA.	result := HumCalculator given: temp extractUpto: stringB.	^result.! !

!HumCalculator class methodsFor: 'string utilities' stamp: 'RichardAlexanderGreen 6/13/2014 20:26'!
given: aString extractIncludingMatching: pairString	"Return substring between balanced pair -- or nil if there is no such pattern.	s = 'this is before [[blah]] this is after'.	self assert: ( HumCalculator given: s betweenMatching: '[]' ) = '[[blah]]'.	 "	| startPos pos nestLevel pairStart pairStop |	pairStart := pairString at: 1.	pairStop  := pairString at: 2.	self assert: (pairStart isKindOf: Character ).	self assert: (pairStop isKindOf: Character ).	"Find the start of the substring."	startPos := aString indexOf: pairStart.	"TODO: If there is no starting character, what should we return?"	(startPos > 0 ) 		ifFalse: [ ^nil ].	"Following assumes we have found the starting position."	self assert: startPos > 0.	pos := startPos + 1.	nestLevel := 1.	[ pos <= aString size ] whileTrue: [		| aCharacter |		aCharacter := aString at: pos.		( aCharacter = pairStart ) 			ifTrue: [ nestLevel := nestLevel + 1 ].		( aCharacter = pairStop )  			ifTrue: [ nestLevel := nestLevel - 1 ].		(nestLevel = 0) 			ifTrue: [ |result| result := ( aString copyFrom:startPos to: pos ). ^result. ].		pos := pos + 1.	].	"If we come here, the matching closing character is missing."	Error signal: 'String does not contain a balanced pair: ', pairString.	^nil.! !

!HumCalculator class methodsFor: 'string utilities' stamp: 'RichardAlexanderGreen 6/13/2014 08:46'!
given: stringIn extractUpto: stringA 	"Get the substring that is between the two given."	| x1 stringOut s |	s := stringIn.	stringOut := ''.	x1 := s findString: stringA startingAt: 1.	(x1 > 0 ) ifTrue: [ stringOut := stringIn copyFrom: 1 to: (x1-1).  ].	^stringOut.! !

!HumCalculator class methodsFor: 'string utilities' stamp: 'RichardAlexanderGreen 8/16/2013 14:13'!
justTheWordsIn: aString	"Return just the words.	Simplify an English string by removing the words 'the', 'a', 'an'.	Also, remove puncturation.	Note: Returns lowercase tokens.	"	| tokens words delimiters whiteSpace |	whiteSpace := String space, String tab, String cr.	delimiters := whiteSpace, '.,?/;!!'.	tokens := (aString asLowercase) findTokens: delimiters.	"Filter out 'the' 'a' 'an' 	(punctuation is already filtered by findTokens)"	words := OrderedCollection new.	tokens		do: [:token |			| skipWord |			skipWord := false.			skipWord := (token = 'the') | (token = 'a') | (token = 'an'). 			skipWord				ifFalse: [ words add: token ].			].	^ words.! !

!HumCalculator class methodsFor: 'string utilities' stamp: 'RichardAlexanderGreen 1/1/2014 09:25'!
writeString: aString toFileNamed: aFileName	"Write the given string to given file - overwrite the previous content."	| file |	file := StandardFileStream forceNewFileNamed: aFileName. 	file nextPutAll: aString.	file close.! !


!HumCalculator class methodsFor: 'evaluating' stamp: 'RichardAlexanderGreen 10/16/2014 22:56'!
does: aString matchPattern: anArrayOfPatterns 
	| tokens whitespace quote punctuation delimiters keepers tests |
	whitespace := Character separators.
	quote := $' asString.
	punctuation := '~!!@#$%^&*()_+`-={}|[]\:,./<>?"', quote.
	delimiters := whitespace, punctuation.
	keepers := delimiters.

	tokens := aString findTokens: delimiters keep: keepers.
	
	( tokens size < anArrayOfPatterns size ) ifTrue: [^false].
	
	tests := Dictionary new.
	tests
		at: #name put: [ :s | s noneSatisfy: [ :ch | delimiters include: ch ]  ];
		at: #digits put: [ :s | s allSatisfy: [ :ch | '1234567890' includes: ch ] ];
		at: #space put: [ :s | s trimBoth isEmpty ]. 
	( 1 to: anArrayOfPatterns size ) do: [ :i |  | token pattern test result |
		token := tokens at: i.
		pattern := anArrayOfPatterns at: i.
		
		test := tests at: pattern.
		result := test value: token.
		result ifFalse: [ ^false ].
		
		].
	^ true.
	
	
	! !


!classDefinition: #HumConfiguration category: #'Hum-RunTime'!
Object subclass: #HumConfiguration
	instanceVariableNames: 'messengerID managerID bookkeeperID worldbaseID ontology messengerProxy isTest clock dispatcherID'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumConfiguration commentStamp: 'RichardAlexanderGreen 9/14/2014 13:21' prior: 0!
A configuration holds the information about how agents are connected to other agents.A typical running application needs the following actors/components:. Dialog Agent to communicate with the client. Coordinator to operate plans. Dispatcher to assign actors to actions. Bookkeeper to record resource untilization. Messenger to enable communication between these actors. A Dialog Agent uses one or more Scribes to decouple dialogs from specific user interface frameworks.. Actors have Blackboards to hold and organize their entity-attribute data.. Blackboards have World Bases to persist and archive their data.. Actors will generally share a common World Base because they are all operating in the same "world."Q: Should a configuration also hold actual objects? A: No. The configuration holds the unique names.    The messenger maps those names to network addresses and sends messages over the network.Q: How do we mock/proxy actors so that we can test without a network?A: (Eventually) The network is mocked in test mode.    Everything else should work the same in test and production modes.Note: (2014-09-07)- Currently HumConfiguration is supertype to HumActor. This reduces some coding problems while creating some cognitive dissonance.I am not sure this is a good idea. (RAGreen). !


!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 2/13/2012 10:42'!
bookkeeper	^ bookkeeperURI ifNil: [ Error signal: 'Bookkeeper is missing!!' ].! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/24/2013 17:51'!
bookkeeperID	^ bookkeeperID! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/24/2013 17:52'!
bookkeeperID: anObject	bookkeeperID := anObject! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/9/2014 21:41'!
clock	^ clock ifNil: [clock := TimeStamp "class singleton"].! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/9/2014 21:42'!
clock: anObjectThatImplementsNow	clock := anObjectThatImplementsNow.! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/3/2014 08:37'!
configuration: aHumConfiguration 	self copyFrom: aHumConfiguration.! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/14/2014 13:55'!
dispatcherID	^ dispatcherID ifNil: [ Error signal: 'A configuration must have a Dispatcher.']! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/14/2014 13:56'!
dispatcherID: anObject	dispatcherID := anObject! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/2/2014 09:24'!
isTest  "Are we running in TEST mode?"	^isTest ifNil: [ isTest := true. ].	! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/2/2014 09:24'!
isTest: aBoolean	"Are we running in TEST mode?"	isTest := aBoolean	! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/15/2014 09:20'!
messenger	^ messengerProxy 			ifNil: [ "Set up messenger with my clock."				messengerProxy := HumMessenger new.				messengerProxy clock: self. 				messengerProxy. "return"				].! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/21/2013 15:50'!
messenger: aHumMessenger	"Set the messenger -- Use to configure mocks when needed."  messengerProxy := aHumMessenger! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/24/2013 17:53'!
messengerID	^ messengerID! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/24/2013 17:53'!
messengerID: aString	messengerID := aString.	('*URL*' matches: aString) ifTrue: [self halt].	('*ID' matches: aString ) ifFalse: [ Error signal: 'ID is not in expected (MOCK) format.' ].! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/14/2014 14:00'!
messengerID: idMessenger dispatcherID: idDispatcher bookkeeperID: idBookkeeper worldbaseID: idWorldbase	messengerID := idMessenger.	dispatcherID := idDispatcher.  bookkeeperID := idBookkeeper.   worldbaseID := idWorldbase.	"WARNING: I am not sure this is a good idea."  ontology ifNil: [self ontology: HumOntology baseOntology].	! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/22/2014 16:51'!
now	^ clock now.! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/17/2014 11:28'!
ontology	^ ontology ifNil: [ Error signal: 'ontology is missing from configuration'].	"TODO: Perhaps we should return HumOntology baseOntology instead."! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 2/8/2012 13:51'!
ontology: aHumOntology 	ontology := aHumOntology.! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/24/2013 17:54'!
worldbaseID	^ worldbaseID! !

!HumConfiguration methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/24/2013 17:54'!
worldbaseID: anObject	worldbaseID := anObject! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumConfiguration class' category: #'Hum-RunTime'!
HumConfiguration class
	instanceVariableNames: ''!

!HumConfiguration class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 9/14/2014 13:38'!
configuration: aHumConfiguration	"Create an instance with the same configuration as the given configuration."	 | c instance |	 c := aHumConfiguration.   instance := self messengerID: c messengerID                       dispatcherID: c dispatcherID                    bookkeeperID: c bookkeeperID                     worldbaseID: c worldbaseID.   instance messenger: c messenger.	instance ontology: c ontology.	^ instance.! !

!HumConfiguration class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 9/14/2014 14:08'!
messengerID: idMessenger dispatcherID: idDispatcher bookkeeperID: idBookkeeper worldbaseID: idWorldbase 	| instance |	instance := self basicNew.	instance messengerID: idMessenger dispatcherID: idDispatcher bookkeeperID: idBookkeeper worldbaseID: idWorldbase.	instance ontology ifNil: [instance ontology: HumOntology baseOntology].	^instance.! !


!classDefinition: #HumEntity category: #'Hum-RunTime'!
Object subclass: #HumEntity
	instanceVariableNames: 'title id'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumEntity commentStamp: 'RichardAlexanderGreen 4/25/2014 10:13' prior: 0!
An entity is a concept that exists in two contexts: entity-type and entity-instance.However, we tend to user the same word regardless of context because the meaning is usually clear-enough.1. An entity-type is a meta-data concept. It is associated with a noun in a Hum ontology.. . An entity-type is identified with a noun (a word or a hyphenated-word).. . In an ontology, an entity-type may have supertypes, subtypes, attributes. (See also: HumEntityAttribute). . In this context, the attribute-set of an entity merges its own attributes with those of its supertypes.2. An entity-instance is an node/item in a run-time data store (Hum BlackBoard and WorldBase).. . In a run-time context, an entity must have a unique identifier. (See HumIdentifier). . . The unique identifier enables references and facilitates data store operations.. . . Entity-instances may reference each other via their unique identifiers.. . A Hum World Base is a temporal database. . . . That means that entity data is time-stamped so that we can retrieve the history of an entity.. . . An entity may be ~created~ and ~destroyed~ to correspond to events in the real-world.. . . However, existence in the World Base may continue until the entity is ~purged~.Q: TODO: How do we represent the "entity destroyed" event in data and the world-base?A: This is relevant to how the World Base handles requests for an entity.   If the request`s time-window is beyond the "destroy" event, the entity should not be in the result.!


!HumEntity methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/19/2014 11:50'!
asString	^self title.! !

!HumEntity methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/19/2014 11:51'!
id	^ id ifNil: [ id := HumIdentifier createUniqueIdentifierForEntityName: (self title) ].! !

!HumEntity methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/19/2013 17:35'!
printOn: aStream	| myClassName |	myClassName := self class name.	aStream nextPutAll: ( myClassName,'(',id asString,')' ).! !

!HumEntity methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/19/2014 11:49'!
title	"a display string describing this entity" 	^ title ifNil: [title := 'Unknown Entity'].! !

!HumEntity methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/13/2013 08:47'!
title: aString	"a display string describing this entity" 	title := aString.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumEntity class' category: #'Hum-RunTime'!
HumEntity class
	instanceVariableNames: ''!

!HumEntity class methodsFor: 'as yet unclassified' stamp: 'RichardAlexanderGreen 4/13/2013 08:44'!
title: aString	| instance |	instance := self basicNew.	instance title: aString.	^instance.! !


!classDefinition: #HumDataFrame category: #'Hum-RunTime'!
HumEntity subclass: #HumDataFrame
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumDataFrame commentStamp: 'RichardAlexanderGreen 4/25/2014 10:07' prior: 0!
The Data Frame class standardizes the way we structure data.Data Frame versus Message:A HumMessage specializes a HumDataFrame.A Message Entity requires sender, reciever, sent-when, statement, and noun-values.The Message class provides serialization and deserialization services.A DataFrame may hold any entity structure and may be used for purposes other than actor-to-actor communication.For example, we may represent configuration, layout, landscape, or actor suspence data in Data Frames. !



!classDefinition: #HumEntityAttribute category: #'Hum-RunTime'!
Object subclass: #HumEntityAttribute
	instanceVariableNames: 'title id'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumEntityAttribute commentStamp: 'RichardAlexanderGreen 4/20/2014 16:53' prior: 0!
An attribute describes an entity. Hence we may say entity-attribute to be more explicit.An attribute exists in two contexts: attribute-type, attribute-instance.However we tend to just say "attribute" in many contexts because the meaning is generally clear enough.1. In an ontology, an attribute-type is named by a noun.. . Entity-types have attributes. More than one entity-type may have the same attribute.. . Basically this means that an attribute-type has no meaning without the context of an entity-type.. . However, to avoid confusion, only one datatype may be associated with the noun that names an attribute-type.2. In an ontology, an attribute-type may reference an entity-type or one of the built-in entity-types.. . The built-in datatypes include string, date, timestamp, collection (set, list, bag), and measure.. . . There are no abstract or machine-oriented numeric types in Hum. . . . A real-world number is always a measurement. (See HumMeasure).. . . If no datatype is assigned to an attribute-type, the default datatype is a string.3. At run-time, an attribute-instance is associated with an entity-instance in a data store (BlackBoard/WorldBase).. . The entity-instance identifier plus the attribute-type (noun) is unique. . . . So the attribute-instance does not need an additional identifier.. . The attribute may take on different values over time. . . . Attribute values have timestamps so we know which value was applicable at any point in time.. . . Note: It makes no sense to assign a null value to a Hum attribute.. . . . If a business process assigns a meaning to an empty collection/string/date/measure, . . . . . it should explicitly assign the string 'none'. (TODO: THINK THIS THROUGH.)!



!classDefinition: #HumFuzzy category: #'Hum-RunTime'!
Magnitude subclass: #HumFuzzy
	instanceVariableNames: 'distribution sampleSize resultDivisions'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumFuzzy commentStamp: 'RichardAlexanderGreen 4/9/2013 09:48' prior: 0!
This class implements fuzzy arithmetic using Monte Carlo sampling of the distributions.!


!HumFuzzy methodsFor: 'plot' stamp: 'RichardAlexanderGreen 6/24/2014 13:03'!
asCrudeMorph		| magnifyBy scaleX scaleY scalePt vMax extent priorPt canvas morph |	magnifyBy := 2.	scaleX := [:v | v*magnifyBy].	scaleY := [:p | (100 - (100*p))*magnifyBy ]. "Flip Y. Screen coordinates have Y pointing down."	scalePt := [:pt | (scaleX value: (pt x))@(scaleY value: (pt y)) ].	vMax := distribution at: 1.0.	extent := ( scalePt value: (vMax@0.0) )* 1.1.		priorPt := scalePt value: 0.0@0.0.	canvas := FormCanvas extent: extent depth: 32 origin: (10@10) clipRect: (Rectangle origin: 0@0 extent: extent).	  canvas fillColor: Color blue muchLighter.		"verticle grid"		(0.0 to: vMax by: 100.0)			do: [:v | canvas line: (scalePt value: v@0.0) to: (scalePt value: v@1.0) width: 1 color: Color green].	  "horizontal grid"		(0.0 to: 1.0 by: 0.1)			do:[:p | canvas line: (scalePt value: 0.0@p) to: (scalePt value: vMax@p) width: 1 color: Color green].		(0.0 to: 1.0 by: 0.5)			do:[:p | canvas line: (scalePt value: 0.0@p) to: (scalePt value: vMax@p) width: 2 color: Color green].		self distributionDo: [ :p :v | 		| xy | 		xy := scalePt value: v@p.		canvas line: priorPt to: xy width: 4 color: Color red.		priorPt := xy.		]. 	morph := canvas form asMorph openInWorld. 	"You can delete morph by double-clicking it."	morph on: #doubleClick send: #delete to: morph. ! !

!HumFuzzy methodsFor: 'plot' stamp: 'RichardAlexanderGreen 6/24/2014 13:33'!
asCrudeMorph2		|  scaleX scaleY scalePt vMax extent priorPt canvas morph pPixels vPixels vMin |	pPixels := 2.	vPixels := 2.	vMax := distribution at: 1.0.	vMin := distribution at: 0.0.	"Normalize v range to [0,100]."	scaleX := [:v | 100*(v-vMin)/(vMax-vMin)*vPixels ].	"Flip Y. Screen coordinates have Y pointing down."	scaleY := [:p | (100 - (100*p))*pPixels ]. 	scalePt := [:pt | (scaleX value: (pt x))@(scaleY value: (pt y)) ].		extent := ( scalePt value: (vMax@0.0) )* 1.1. "TODO: Enable caller to specify extent."			priorPt := scalePt value: 0.0@0.0.	canvas := FormCanvas extent: extent depth: 32 origin: (10@10) clipRect: (Rectangle origin: 0@0 extent: extent).	"Paint grid lines"	  canvas fillColor: Color blue muchLighter.		"vertical grid"		(vMin to: vMax by: ((vMax-vMin)*0.1))			do: [:v | canvas line: (scalePt value: v@0.0) to: (scalePt value: v@1.0) width: 1 color: Color green].		(vMin to: vMax by: ((vMax-vMin)*0.5))			do: [:v | canvas line: (scalePt value: v@0.0) to: (scalePt value: v@1.0) width: 2 color: Color green].	  "horizontal grid"		(0.0 to: 1.0 by: 0.1)			do:[:p | canvas line: (scalePt value: 0.0@p) to: (scalePt value: vMax@p) width: 1 color: Color green].		(0.0 to: 1.0 by: 0.5)			do:[:p | canvas line: (scalePt value: 0.0@p) to: (scalePt value: vMax@p) width: 2 color: Color green].		self distributionDo: [ :p :v | 		| xy | 		xy := scalePt value: v@p.		canvas line: priorPt to: xy width: 4 color: Color red.		priorPt := xy.		]. 	morph := canvas form asMorph openInWorld. 	"You can delete morph by double-clicking it."	morph on: #doubleClick send: #delete to: morph. ! !

!HumFuzzy methodsFor: 'plot' stamp: 'RichardAlexanderGreen 6/24/2014 22:21'!
asCrudeMorphInRectangle: aRectangle	"Display a plot in a Morph with the origin and extent indicated by the given Rectangle."	|  scaleX scaleY scalePt vMax extent priorPt canvas morph pPixels vPixels vMin r |	vMax := distribution at: 1.0.	vMin := distribution at: 0.0.	"Pixels per normalized value unit."	extent := (aRectangle extent) - (10@10). 	vPixels := (extent x) / 100.	pPixels := (extent y) / 100.	"Normalize v range to [0,100]."	scaleX := [:v | 100*(v-vMin)/(vMax-vMin)*vPixels ].	"Flip Y. Screen coordinates have Y pointing down."	scaleY := [:p | (100 - (100*p))*pPixels ]. 	scalePt := [:pt | (scaleX value: (pt x))@(scaleY value: (pt y)) ].		extent := ( scalePt value: (vMax@0.0) )* 1.1. "TODO: Enable caller to specify extent."			canvas := FormCanvas extent: extent depth: 32 origin: (10@10) clipRect: (Rectangle origin: 0@0 extent: extent).	"Paint grid lines"	  canvas fillColor: Color blue muchLighter.		"vertical grid"		(vMin to: vMax by: ((vMax-vMin)*0.1))			do: [:v | canvas line: (scalePt value: v@0.0) to: (scalePt value: v@1.0) width: 1 color: Color green].		(vMin to: vMax by: ((vMax-vMin)*0.5))			do: [:v | canvas line: (scalePt value: v@0.0) to: (scalePt value: v@1.0) width: 2 color: Color green].	  "horizontal grid"		(0.0 to: 1.0 by: 0.1)			do:[:p | canvas line: (scalePt value: 0.0@p) to: (scalePt value: vMax@p) width: 1 color: Color green].		(0.0 to: 1.0 by: 0.5)			do:[:p | canvas line: (scalePt value: 0.0@p) to: (scalePt value: vMax@p) width: 2 color: Color green].	priorPt := scalePt value: vMin@0.0.		self distributionDo: [ :p :v | 		| xy | 		xy := scalePt value: v@p.		canvas line: priorPt to: xy width: 4 color: Color red.		priorPt := xy.		]. 	morph := canvas form asMorph bounds: aRectangle.	morph openInWorld. 	"You can delete morph by double-clicking it."	morph on: #doubleClick send: #delete to: morph. ! !


!HumFuzzy methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/9/2013 11:14'!
atP: aFloat 	"Return the appropriate value from the distribution.	Iterpolate when necessary. 	This version uses linear interpolation.	Future versions might use a spline or something."	| result |	"Check that aFloat is between zero and one"	self assert: ( aFloat isKindOf: Float ).	self assert: ( aFloat >= 0.0 ).	self assert: ( aFloat <= 1.00).	"Look up value or interpolate to get a result."	result := distribution at: aFloat ifAbsent: [ self interpolate: aFloat ].	^ result.! !

!HumFuzzy methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/23/2014 14:09'!
distribution: aDictionary 	"Distribution is an S-curve that maps probability to value.	Example: 'distribution at: 0.50 put: 12.' 	  means that sample values will be less than or equal to 12 for 50% of samples.	In other words, the median of the distribution is 12.	"	self assert: ( aDictionary isKindOf: Dictionary ).	distribution := aDictionary.! !

!HumFuzzy methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/23/2014 17:26'!
distributionDo: pvBlock	"Vist the key->value (probability->value) entries in the distribution."	| keys |	self assert: ( pvBlock isKindOf: BlockClosure ).	self assert: ( pvBlock argumentCount = 2 ).	self assert: ( distribution isKindOf: Dictionary ).	keys := distribution keysSortedSafely.	keys 		do: [ :p |			| v |			v := distribution at: p.			pvBlock value: p value: v.			].! !

!HumFuzzy methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/22/2014 13:33'!
initialize	self sampleSize: 1024*16 resultDivisions: 32.	! !

!HumFuzzy methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/9/2013 11:20'!
interpolate: aProbability	"Interpolate the predicted value at aProbability"	| lowerP lowerF upperP upperF slope intercept result |	self assert: (aProbability isKindOf: Float ).	"Following depends on Dictionary semantics"	self assert: ( distribution isKindOf: Dictionary ).	lowerP := 0.0.	lowerF := distribution at: lowerP.	upperP := 1.0.	upperF := distribution at: upperP.	distribution keysAndValuesDo: [ :k :v |		( k > lowerP and: [ k < aProbability ] ) ifTrue: [ lowerP := k. lowerF := v. ].		( k < upperP and: [ k > aProbability ] ) ifTrue: [ upperP := k. upperF := v. ].		].	"Do simple linear interpolation."	slope :=  ( upperF - lowerF ) / ( upperP - lowerP ).	"Check: for an S-Curve the slope is always positive."	self assert: ( slope > 0.0 ).		result := lowerF + ( (aProbability - lowerP) * ( slope) ).	"Check: the result must be between upper and lower function values"	self assert: ( result > lowerF ).	self assert: ( result < upperF ).	^result.! !

!HumFuzzy methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/9/2013 13:14'!
median	"find the point that represents the median"	|  medianPoint |	"Distribution is list of f->p".	"Look for f@0.50"	medianPoint := self atP: 0.50.	^medianPoint.! !

!HumFuzzy methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/23/2014 14:10'!
sampleSize: anInteger	"Reset the sample size used in Monte Carlo sampling of input distributions.	Default value is preset in >>initialize method.	A value on the order of 10,000 produces good results.	The sampleSize must be a multiple of 10. (See >>op:with:)	"	sampleSize := anInteger.! !

!HumFuzzy methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/23/2014 14:15'!
sampleSize: aSampleSize resultDivisions: aDivisionCount	"Reset the sample size used in Monte Carlo sampling of input distributions.	Default value is preset in >>initialize method.	A value on the order of 10,000 produces good results.	The sampleSize must be a multiple of aDivisionCount. (See >>op:with:)	"	self assert: (aSampleSize \\ aDivisionCount = 0).	"The Monte Carlo will randomly sample the inputs this many times."	sampleSize := aSampleSize.	"The resulting S-curve will have N+1 points selected from sampleSize points."	resultDivisions := aDivisionCount. ! !


!HumFuzzy methodsFor: 'evaluating' stamp: 'RichardAlexanderGreen 4/9/2013 14:15'!
* aHumFuzzy 	| times result |	times := #*.	result := self op: times with: aHumFuzzy.	^result.! !

!HumFuzzy methodsFor: 'evaluating' stamp: 'RichardAlexanderGreen 6/22/2014 13:15'!
+ aHumFuzzy 	| plus result |	plus := #+.	result := self op: plus with: aHumFuzzy.	^result.! !

!HumFuzzy methodsFor: 'evaluating' stamp: 'RichardAlexanderGreen 4/9/2013 14:11'!
- aHumFuzzy 	| minus result |	minus := #-.	result := self op: minus with: aHumFuzzy.	^result.! !

!HumFuzzy methodsFor: 'evaluating' stamp: 'RichardAlexanderGreen 4/9/2013 14:13'!
/ aHumFuzzy 	| divide result |	divide := #/.	result := self op: divide with: aHumFuzzy.	^result.! !

!HumFuzzy methodsFor: 'evaluating' stamp: 'RichardAlexanderGreen 6/23/2014 14:18'!
correctInterceptInDistribution: aDistribution	"-- Use slope-intercept to get a better estimate of the S-curve value at probability 0.	v(p) = a + b*p	v(0) = a.	v(p1) = a + b*p1.	v(p2) = a + b*p2.	v(p2) - v(p1) = b*(p2-p1).	b = ( v(p2) - v(p1) ) / (p2-p1).	extrapolate a = v(0) so that we get the same slope b.	b = ( v(p2) - v(0) ) / (p2 - 0).	b = ( v(p2) - a ) / p2.	b * p2 = v(p2) - a.	a = v(p2) - (b * p2).	"	| tick p1 p2 v1 v2 b a | 	self assert: (aDistribution isKindOf: Dictionary).	tick := sampleSize / resultDivisions.  "This must be coordinated to match >>op:with:"	p1 := (tick/sampleSize) asFloat.	p2 := (tick * 2/sampleSize) asFloat.	v1 := aDistribution at: p1.	v2 := aDistribution at: p2.	b := (v2 - v1) / (p2 - p1).	a := v2 - ( b * p2 ).	aDistribution at: 0.0 put: a.	! !

!HumFuzzy methodsFor: 'evaluating' stamp: 'RichardAlexanderGreen 4/22/2013 09:59'!
mean	| sum n result |	sum := 0.0.	n := 0.	self sampleWithBlock: [ :x | n := n + 1. sum := sum + x.].	result := sum / n.	^result.! !

!HumFuzzy methodsFor: 'evaluating' stamp: 'RichardAlexanderGreen 6/24/2014 12:54'!
op: aSymbol with: aHumFuzzy "Add two fuzzy distibutions using Monte Carlo sampling"	| resultSet random  vC sortedSet distributionC tick count fuzzyC |	resultSet := Set new.	random := Random new.	( 1 to: sampleSize )		do: [ :i |			| rA rB vA vB |			rA := random next.			vA := self atP: rA.			rB := random next.			vB := aHumFuzzy atP: rB.			vC := vA perform: aSymbol with: vB.			resultSet add: vC.			].	"Create a new distribution with points every 10%"	sortedSet := resultSet asSortedCollection.	self assert: ( sortedSet size = sampleSize ).	"Note: Assertion above occasionally fails due to accidental matches in set.	TODO: CONSIDER USING A BAG INSTEAD OF A SET."	distributionC := Dictionary new.	distributionC at: 0.0 put: ( sortedSet first ). "This is a placeholder."	tick := sampleSize / resultDivisions.	count := 0.	sortedSet		do: [ :x | 				| modulo |				modulo := ( count \\ tick ).				( modulo = 0 )					ifTrue: [ distributionC at: ( (count/sampleSize) asFloat )  put: x ].			  count := count + 1.			 ].	distributionC at: 1.0 put: (sortedSet last).	"self correctInterceptInDistribution: distributionC."	self assert: ( distributionC size = (resultDivisions + 1) ).	fuzzyC := HumFuzzy distribution: distributionC.	^fuzzyC.		! !

!HumFuzzy methodsFor: 'evaluating' stamp: 'RichardAlexanderGreen 4/22/2013 10:01'!
sampleWithBlock: aBlock "Operate on fuzzy distibution using Monte Carlo sampling"	| resultSet random |	resultSet := Set new.	random := Random new.	( 1 to: sampleSize )		do: [ :i |			| rA  vA  |			rA := random next.			vA := self atP: rA.			aBlock value: vA.			].		! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumFuzzy class' category: #'Hum-RunTime'!
HumFuzzy class
	instanceVariableNames: ''!

!HumFuzzy class methodsFor: 'as yet unclassified' stamp: 'RichardAlexanderGreen 4/9/2013 13:43'!
distribution: aDistribution	"Create a new instance from the given distribution."	| fuzzy |	fuzzy := self basicNew.	fuzzy initialize.	fuzzy distribution: aDistribution.	^fuzzy.! !


!HumFuzzy class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 4/22/2013 10:24'!
quantity: aQuantity plusOrMinus: aLimit 	"Create a distribution with given limits."	| fuzzy stats |	self assert: ( aQuantity isKindOf: Number ).	self assert: (    aLimit isKindOf: Number ).	"Assume upper and lower will not be exceeded.	The idea is that cases exceeding those measures would be rejected.	"	fuzzy := self basicNew.	fuzzy initialize.	stats := Dictionary new.	stats		at: 0.50  put: aQuantity;		at: 0.00  put: (aQuantity - aLimit );		at: 1.00  put: (aQuantity + aLimit ).	fuzzy distribution: stats.	^fuzzy.! !


!classDefinition: #HumIdentifier category: #'Hum-RunTime'!
Object subclass: #HumIdentifier
	instanceVariableNames: 'bigNumber uuid entityName'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!

!HumIdentifier methodsFor: 'private' stamp: 'RichardAlexanderGreen 4/29/2014 09:37'!
printOn: aStream	aStream nextPutAll: (self asString).! !


!HumIdentifier methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/19/2014 11:43'!
asString	(bigNumber isKindOf: Integer ) ifFalse: [ ^(entityName asString),':',(bigNumber asString)].	^ (entityName asString),':',(bigNumber printStringHex).! !

!HumIdentifier methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/16/2014 23:10'!
bigNumber
	^ bigNumber! !

!HumIdentifier methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/16/2014 21:13'!
generateForEntityName: anEntityName	| ticks days seconds nanos prior priorDays priorSeconds priorNanos priorBigNumber |	entityName := anEntityName.	ticks := DateAndTime now asUTC ticks copy.	days := ticks at: 1.	seconds := ticks at: 2.	nanos := ticks at: 3.	prior := self class.	priorDays := prior days.	priorSeconds := prior seconds.	priorNanos := prior nanos.	( days = priorDays and: [ seconds = priorSeconds and: [ nanos <= priorNanos ] ] )		ifTrue: [ nanos := (prior nanos) + 1. ].	"Post Conditions:"		bigNumber := (((days * 86400) + seconds) * 1e9) + nanos.	priorBigNumber := ( ((priorDays * 86400) + priorSeconds) * 1e9) + priorNanos.	self assert: ( bigNumber > priorBigNumber ).	"Set the singleton values."	prior days: days seconds: seconds nanos: nanos.	self uuid: self class uuid.	! !

!HumIdentifier methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/16/2014 23:31'!
initialize	"This UUID represents the run-time. 	TODO: THIS IS A STUB. 	EVENTUALLY, THIS SHOULD BE SET FROM A CONFIGURATION FILE OR SOMETHING."	| s  |
	self generateForEntityName: (DateAndTime now asString).
	s := WriteStream on: ''.
	(self bigNumber) printOn: s base: 36 nDigits: 14.
	uuid := s contents. 
	! !

!HumIdentifier methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/28/2014 17:13'!
uuid: aUUID 	uuid := aUUID! !


!HumIdentifier methodsFor: 'as yet unclassified' stamp: 'RichardAlexanderGreen 10/16/2014 23:09'!
< anotherIdentifier
	"compare time of creation"
	| result |
	result := ( bigNumber ) < ( anotherIdentifier bigNumber ).
	^ result.
	! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumIdentifier class' category: #'Hum-RunTime'!
HumIdentifier class
	instanceVariableNames: 'daysRegister secondsRegister nanosRegister uuid'!

!HumIdentifier class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 4/29/2014 09:42'!
createUniqueIdentifierForEntityName: entityName	| instance |	instance := self basicNew.	instance generateForEntityName: entityName. 	^instance.! !


!HumIdentifier class methodsFor: 'class variables' stamp: 'RichardAlexanderGreen 9/19/2014 12:07'!
days	"Fetch the prior identifier parameters."	^ daysRegister ifNil: [ daysRegister := 0 ].! !

!HumIdentifier class methodsFor: 'class variables' stamp: 'RichardAlexanderGreen 4/28/2014 09:56'!
days: nDays seconds: nSeconds nanos: nNanos 	daysRegister := nDays.	secondsRegister := nSeconds.	nanosRegister := nNanos.! !

!HumIdentifier class methodsFor: 'class variables' stamp: 'RichardAlexanderGreen 9/19/2014 12:07'!
nanos	"Fetch the prior identifier parameters."	^ nanosRegister ifNil: [ nanosRegister := 0 ].! !

!HumIdentifier class methodsFor: 'class variables' stamp: 'RichardAlexanderGreen 9/19/2014 12:07'!
seconds	"Fetch the prior identifier parameters."	^ secondsRegister ifNil: [ secondsRegister := 0 ].! !

!HumIdentifier class methodsFor: 'class variables' stamp: 'RichardAlexanderGreen 9/19/2014 12:23'!
uuid	"Fetch the prior identifier parameters?"	| x |		x := (((daysRegister*10e6)+secondsRegister)*10e9)+nanosRegister.	uuid := x printStringHex.	^ uuid! !


!classDefinition: #HumJobTicket category: #'Hum-RunTime'!
HumEntity subclass: #HumJobTicket
	instanceVariableNames: 'ontology charges'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumJobTicket commentStamp: 'RichardAlexanderGreen 9/14/2014 13:22' prior: 0!
A job ticket records the resources consumed by a job.A job is initiated when a goal is set running.When actions are delegated by the one actor to other actors, they get jobtickets also.The resulting resource data is consolidated on the parent-level job-ticketsso that the costs are rolled-up to each level and eventually to the job as a whole.When each action is completed, the Dispatcher reports new resource entries to the Bookkeeper.Hence a running account is maintained for the job, for each resource, for each actor, for each role, for each action.---Dictionary: Job Vocabulary.Job attributes include goal-invocation, resource-usage.Goal-invocation attributes include invocation-event, goal.Resource-usage has a list of usage-notes.Usage-note attributes include resource, quantity-used, by-actor, in-role, performing-action.---Note that resource accounting only sums resource quantities.It does not attempt to monetize (price) the resources used because that is a very specialized process.For example, withdrawals from inventory might be priced using LIFO, FIFO, or some other accounting practice.TODO: Refactor job ticket so that it is not a subtype of data frame.      (2013-06-07) A job ticket is currently a subtype of HumDataFrame.       That is a bad idea because it mixes ticket concept with serialization process.!


!HumJobTicket methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/22/2014 09:52'!
appendCharge: aHumMeasure forAction: action byActor: anID inRole: aRoleName onJob: aJobID 	| charge debug |	"Use a dictionary to represent a charge."		charge := Dictionary new.	charge 		at: 'measure' put: aHumMeasure "asString";		at: 'action'  put: action asString;		at: 'ID'      put: anID asString;		at: 'role'    put: aRoleName asString;		at: 'job'     put: aJobID asString.	debug := false. 	debug 		ifTrue: [ 			Transcript cr.			charge keysAndValuesDo: [:k :v | Transcript show: ' ',k,': ', v asString.]			].			"Append this charge to ticket`s charges."	  ( self charges ) add: charge.	! !

!HumJobTicket methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/10/2013 10:07'!
charges	^charges ifNil: [ charges := OrderedCollection new.]! !

!HumJobTicket methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/24/2014 10:27'!
getActionSequence	"Parse the job ticket to show the sequence of actions."	| listOfActions |	listOfActions := OrderedCollection new.	self charges		do:[:charge |			listOfActions add: (charge at: 'action') source.			].	^listOfActions.! !

!HumJobTicket methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/22/2014 10:40'!
printOn: aStream	|  |		aStream nextPutAll: ( 'Job:(',title asString,')' ).! !

!HumJobTicket methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/24/2014 10:23'!
zAppendCharge: aHumMeasure forAction: action byActor: anID inRole: aRoleName onJob: aJobID 	| charge |	"Use a dictionary to represent a charge."	charge := Dictionary new.	charge 		at: 'measure' put: aHumMeasure asString;		at: 'action'  put: action asString;		at: 'ID'      put: anID asString;		at: 'role'    put: aRoleName asString;		at: 'job'     put: aJobID asString.			"Append this charge to ticket`s charges."	  ( self charges ) add: charge.	! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumJobTicket class' category: #'Hum-RunTime'!
HumJobTicket class
	instanceVariableNames: ''!

!HumJobTicket class methodsFor: 'as yet unclassified' stamp: 'RichardAlexanderGreen 9/22/2014 13:56'!
new	| instance |	"Catch cases where instances are created without titles."	self halt.	instance := self basicNew.	instance initialize.	^instance! !


!classDefinition: #HumMeasure category: #'Hum-RunTime'!
Magnitude subclass: #HumMeasure
	instanceVariableNames: 'dimensions quantity unitsSynonyms'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumMeasure commentStamp: 'RichardAlexanderGreen 11/28/2013 19:06' prior: 0!
HumMeasure2 (experiment) extends HumMeasure to track non-KMS units and cancel units when they both appear in the numerator and denominator.If it works out, the mechanism may be merged into HumMeasure.s := 1 lightSecond.  "HumMeasure( 299792458 meter )"milliC := s / 1000.  "HumMeasure( 299792.458 meter ) about 300 kilometers"microC := s / 1e6.   "HumMeasure( 299.792 meter ) a football field"nanoC := s / 1e9.    "HumMeasure( 0.300 meter ) about 300 millimeter" picoC := s / 1e12.   "HumMeasure( 0.000299792458 meter ) about 0.3 millimeter"  femtoC := s / 1e15.  "HumMeasure( 2.99792458e-7 meter ) about 4000 atoms - See below."attoC := s / 1e18.   "HumMeasure( 2.99792458e-10 meter ) about 4 atoms" picoMeter := 1 meter / 1e12." HumMeasure( (1/1000000000000) meter )"carbonRadius := picoMeter * 70." HumMeasure( (7/100000000000) meter )"nCarbonAtoms := femtoC / carbonRadius." HumMeasure( 4282.749  )" !


!HumMeasure methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/16/2014 21:22'!
deepCopy
	| newInstance |
	newInstance := self class new.
	newInstance
		quantity: self quantity copy;
		dimensions: self dimensions copy.
	^newInstance.
		
		! !

!HumMeasure methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 11/28/2013 19:09'!
dimensions	"Tracks units and powers of units -- "	^ dimensions ifNil: [ dimensions := Dictionary new.]! !

!HumMeasure methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/29/2013 10:59'!
dimensions: aDictionary 	dimensions := aDictionary! !

!HumMeasure methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/28/2013 10:28'!
quantity	^ quantity ifNil: [ quantity := 0.0 ].! !

!HumMeasure methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/28/2013 10:30'!
quantity: aNumber 	quantity := aNumber! !

!HumMeasure methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 8/22/2013 10:10'!
quantity: aNumber per: denominatorUnits	"Set instance denominator units.	 Use this method when the quantity is something like coefficient of expansion.	 coefficient := HumMeasure quantity: 6.5e-6 per: #degreeCentigrade.	"	| exponent standardName numeratorExponent |	quantity := aNumber.		exponent := -1.	(denominatorUnits beginsWith: 'square' ) ifTrue: [ exponent := -2 ].	(denominatorUnits beginsWith: 'cubic' ) ifTrue: [ exponent := -3 ].	standardName := self standardNameFor: denominatorUnits.	(self dimensions) at: standardName put: exponent.	 	 ! !

!HumMeasure methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/28/2013 13:14'!
quantity: aNumber units: numeratorUnits 	"Set instance numerator units	"	| unitsString exponent |	quantity := aNumber.		exponent := 1.	(numeratorUnits beginsWith: 'square' ) ifTrue: [ exponent := 2 ].	(numeratorUnits beginsWith: 'cubic' ) ifTrue: [ exponent := 3 ].	(self dimensions) at: (self standardNameFor: numeratorUnits ) put: ( exponent ).	 	 ! !

!HumMeasure methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/4/2013 11:04'!
quantity: aNumber units: numeratorUnits per: denominatorUnits	"Set instance numerator and denominator units.	Example1:	   milesPerHour := HumMeasure2 quantity: 65 units: 'miles' per: 'hour'.	   feetPerMile := HumMeasure2 quantity: 5280 units: 'feet' per: 'mile'.	   feetPerHour := milesPerHour * feetPerMile.		 secondsPerHour := HumMeasure2 quantity: 3600 units: 'seconds' per: 'hour'.		 feetPerSecond := feetPerHour / secondsPerHour.	"	| exponent standardName numeratorExponent |	quantity := aNumber.	exponent := 1.	(numeratorUnits beginsWith: 'square' ) ifTrue: [ exponent := 2 ].	(numeratorUnits beginsWith: 'cubic' ) ifTrue: [ exponent := 3 ].	(self dimensions) at: (self standardNameFor: numeratorUnits) put: ( exponent ).		exponent := -1.	(denominatorUnits beginsWith: 'square' ) ifTrue: [ exponent := -2 ].	(denominatorUnits beginsWith: 'cubic' ) ifTrue: [ exponent := -3 ].	standardName := self standardNameFor: denominatorUnits.	"Get matching numerator exponent, if any, so that we correctly handle ratios 	 such as 'length per length' and 'dollars per dollar' "	numeratorExponent := (self dimensions) at: standardName ifAbsent: [0].	(self dimensions) at: standardName put: ( numeratorExponent + exponent ).	 	 ! !

!HumMeasure methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 5/30/2014 12:54'!
unitsSynonyms	^ unitsSynonyms ifNil: [ unitsSynonyms := Dictionary new.		unitsSynonyms			at: 'feet' put: 'foot';			at: 'miles' put: 'mile';			at: 'meters' put: 'meter';			at: 'kg' put: 'kilogram';			at: 'km' put: 'kilometer';			at: 'inches' put: 'inch';			at: 'watt' put: 'Watt';			at: 'joule' put: 'Joule';			at: 'amp' put: 'Ampere';			at: 'ft' put: 'foot';			at: 'in' put: 'inch';			at: 'sec' put: 'second';			yourself.] ! !


!HumMeasure methodsFor: 'arithmetic' stamp: 'RichardAlexanderGreen 9/22/2013 10:41'!
* multiplier 	| result |	result := self deepCopy.	(multiplier isKindOf: Number) 		ifTrue: [ result := self deepCopy. 							result quantity: (self quantity * multiplier).							^result.							].	(multiplier isKindOf: Duration)		ifTrue: [			| m |			m := HumMeasure quantity: (multiplier asSeconds) units: #second.			result := self * m.			^result.			].	result quantity: (self quantity) * (multiplier quantity).	(multiplier dimensions)		keysAndValuesDo: [ :unit :exponent | 			"Increment and net-out the dimensions."			result incrementDimensionsAt: unit by: exponent.			].	^result.	! !

!HumMeasure methodsFor: 'arithmetic' stamp: 'RichardAlexanderGreen 4/29/2013 09:45'!
+ operand 	| result |	"The units of measure must be the same."	self assert: (operand dimensions) = (self dimensions).	"Make a deep copy to get fresh dimensions and quantity."	result := self deepCopy.	result quantity: (self quantity) + (operand quantity).	^result.	! !

!HumMeasure methodsFor: 'arithmetic' stamp: 'RichardAlexanderGreen 4/29/2013 09:43'!
- operand 	| result |	self assert: (operand dimensions) = (self dimensions).	result := self deepCopy.	result quantity: (self quantity) - (operand quantity).	^result.	! !

!HumMeasure methodsFor: 'arithmetic' stamp: 'RichardAlexanderGreen 10/17/2014 10:33'!
/ aDivisor 	| result divisor |		result := self deepCopy.	( aDivisor isKindOf: HumMeasure )		ifTrue: [divisor := aDivisor].	( aDivisor isKindOf: Duration )		ifTrue: [divisor := HumMeasure quantity: (aDivisor seconds) units: 'second'. ].	( aDivisor isKindOf: Number )		ifTrue: [ result quantity: (self quantity / aDivisor). ^ result. ].		"If the dimensions match, the result is a ratio. But we keep it as a HumMeasure to enable cascade."	self assert: ( divisor isKindOf: HumMeasure ).		( divisor dimensions = self dimensions )		ifTrue: [ result := HumMeasure new quantity: (self quantity) / (aDivisor quantity). ^result. ].						result quantity: (self quantity) / (divisor quantity).	(divisor dimensions)		keysAndValuesDo: [ :unit :exponent |			"Decrement and net-out the dimensions."			result incrementDimensionsAt: unit by: (exponent negated).			].	^result.	! !

!HumMeasure methodsFor: 'arithmetic' stamp: 'RichardAlexanderGreen 12/11/2013 13:00'!
< operand 	| result |	"The units of measure must be the same."	((operand dimensions) = (self dimensions)) ifFalse: [^false].		result := (self quantity) < (operand quantity).	^result.	! !

!HumMeasure methodsFor: 'arithmetic' stamp: 'RichardAlexanderGreen 5/4/2013 20:14'!
= operand 	| result |	"The units of measure must be the same."	((operand dimensions) = (self dimensions)) ifFalse: [^false].		result := (self quantity) closeTo: (operand quantity).	^result.	! !

!HumMeasure methodsFor: 'arithmetic' stamp: 'RichardAlexanderGreen 12/11/2013 13:00'!
> operand 	| result |	"The units of measure must be the same."	((operand dimensions) = (self dimensions)) ifFalse: [^false].		result := (self quantity) > (operand quantity).	^result.	! !

!HumMeasure methodsFor: 'arithmetic' stamp: 'RichardAlexanderGreen 5/8/2013 18:48'!
incrementDimensionsAt: aUnit by: anIncrement	"Increment / Decrement dimension exponent by given increment (negative when decrementing).	"	| x |	self assert: (anIncrement isKindOf: SmallInteger ).	x := (self dimensions) at: aUnit ifAbsent: [0].	"Remove zeroed dimensions."	"TODO: THINK: This discards potentially useful information." 	(( x + anIncrement ) = 0)				ifTrue:  [ (self dimensions) removeKey: aUnit ]  				ifFalse: [ (self dimensions) at: aUnit put: ( x + anIncrement )].					"TODO: When units cancel (e.g. length/length), find some way to preserve information.	Example: L^0 Degree^-1 should find L^1 Degree^1 in a multiplier.	"	! !

!HumMeasure methodsFor: 'arithmetic' stamp: 'RichardAlexanderGreen 5/4/2013 20:55'!
negated	| result |	result := self deepCopy.	result quantity: (self quantity) negated.	^result.! !


!HumMeasure methodsFor: 'converting' stamp: 'RichardAlexanderGreen 5/4/2013 20:09'!
as: aSymbol	"Convert to the unit of measure indicated by aSymbol"	| result qty divisor string displayUnits|	divisor := 1.0 perform: aSymbol.	self assert: (self dimensions) = (divisor dimensions).	result := self / divisor.	qty := result quantity.	displayUnits := aSymbol asString.	((qty abs) between: 0.1 and: 99999.0 )		ifTrue:  [ string := ( ( qty printShowingDecimalPlaces: 3), ' ', displayUnits )]		ifFalse: [ string := ( ( qty asString                    ), ' ', displayUnits )].	^string.! !

!HumMeasure methodsFor: 'converting' stamp: 'RichardAlexanderGreen 4/28/2013 13:29'!
units	"Render dimensions as a string"	| string append prefix  secondPassNeeded |	append := Dictionary new.	append 		at: 2 put: 'square ';		at: 3 put: 'cubic '.	string := String new.	secondPassNeeded := false.	(self dimensions)		keysAndValuesDo: [ :unit :exponent |					( exponent > 0 ) 						ifTrue: [ 							prefix := append at: exponent ifAbsent: [''].							string := string, prefix, unit, ' '.									]						ifFalse: [ (exponent < 0 ) ifTrue: [ secondPassNeeded := true ] ].					].	secondPassNeeded 		ifTrue: [ 			string := string, 'per '.			(self dimensions)				keysAndValuesDo: [ :unit :exponent |					( exponent < 0 ) 						ifTrue: [ 							prefix := append at: (exponent negated) ifAbsent: [''].							string := string, prefix, unit, ' '.									]					].			].		^string trimBoth.	! !


!HumMeasure methodsFor: 'user interface' stamp: 'RichardAlexanderGreen 4/29/2013 10:46'!
asString	| result displayUnits |	displayUnits := (self units).	(self dimensions = (Dictionary newFrom: {'kilogram'->1. 'meter'->1. 'second'->(-2).}) )			ifTrue: [displayUnits := 'Newton'].	(self dimensions = (Dictionary newFrom: {'kilogram'->1. 'meter'->(-1). 'second'->(-2).}) )			ifTrue: [displayUnits := 'Pascal'].	(self dimensions = (Dictionary newFrom: {'kilogram'->1. 'meter'->2. 'second'->(-2).}) )		ifTrue: [displayUnits := 'Joule'].	(self dimensions = (Dictionary newFrom: {'kilogram'->1. 'meter'->2. 'second'->(-3).}) )		ifTrue: [displayUnits := 'Watt'].	( quantity = (quantity truncated) ) 		ifTrue:[ result := ((quantity truncated) asString), ' ', displayUnits. 						  ^result. 					 ].	((quantity abs) between: 0.1 and: 99999.0 )		ifTrue:  [ result := ( ( quantity printShowingDecimalPlaces: 3), ' ', displayUnits )]		ifFalse: [ result := ( ( quantity asString                    ), ' ', displayUnits )].	^result.! !

!HumMeasure methodsFor: 'user interface' stamp: 'RichardAlexanderGreen 4/28/2013 13:18'!
printOn: aStream	"Append to the argument, aStream, a sequence of characters that  	identifies the receiver."	| title |	title := self class name.	aStream		nextPutAll: title;		nextPutAll: ( '( ', (self asString), ' )' ).! !

!HumMeasure methodsFor: 'user interface' stamp: 'RichardAlexanderGreen 5/30/2014 12:58'!
standardNameFor: aString 	"Fix up names of units to assure consistency."	| unitsString |	unitsString := aString asString trimBoth.	"Remove square- cubic-"	(unitsString beginsWith: 'square' ) ifTrue: [ unitsString := unitsString copyReplaceTokens: 'square' with: ''].	(unitsString beginsWith: 'cubic' ) ifTrue: [ unitsString := unitsString copyReplaceTokens: 'cubic' with: ''].	unitsString := unitsString trimBoth.	"Standardize terms"	unitsString := (self unitsSynonyms) at: unitsString ifAbsent: [ unitsString ].			self assert: ( unitsString endsWith: 's' ) not.	^unitsString.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumMeasure class' category: #'Hum-RunTime'!
HumMeasure class
	instanceVariableNames: ''!

!HumMeasure class methodsFor: 'examples' stamp: 'RichardAlexanderGreen 5/31/2014 22:07'!
exampleStarVoyage| watt hp m v e d t p megaW n nB11 molesB11 gramsB11 kgB11 nCN nCNOreactions nGrams kgOfHydrogen cubicMeterPerSecond area minCollectingVelocity minCollectingVoverC  |watt := 1 watt." HumMeasure( 1 Watt )"hp := 1 megaWatt." HumMeasure( 1000 Watt )" m := 1000 kilogram." HumMeasure( 1000 kilogram )"    v := 0.1 lightSpeed." HumMeasure( 2.99792458e7 meter per second )"  e := m * v * v * 0.5." HumMeasure( 449377589368408832 Joule )"d := 4 lightYear." HumMeasure( 37842921890323200 meter )"t := d / v." HumMeasure( 1262304000 second )"p := e / t." HumMeasure( 3.5599791283906955e8 Watt )"megaW := 3.56e8 / 1e6.n := e / (8 MeV). "350599310495773556710666403840 atoms of B11"nB11 := 350599310495773556710666403840.molesB11 := nB11 / (1 Avogadro). "582183.7997985426"gramsB11 := molesB11 * 11." 6.404e6"kgB11 := gramsB11/1e3." 6404.021797783969 -- Houston, we have a problem.""For each tonne of payload we need over 6 tonne of fuel,  and for each tonne of fuel we need fuel to accelerate the fuel."  "What if we captured Hydrogen in ram scoop and converted them via CNO fusion? "nCNOreactions := (3.5599791283906955e8 joule)/(25 MeV)." 8.887857e19 reactions/second""Each reaction requires 4 Hydrogen atoms (4 protons)."nGrams := 8.887857e19 * 4 / (1 Avogadro). "0.000590345"kgOfHydrogen := nGrams / 1e3.                " 5.90345e-7 per second per tonne""But we need to sweep up 8.89e19 Hydrogen atoms per second.""There is roughly 1e6 Hydrogen atoms per cubic meter in interstellar space "cubicMeterPerSecond := 8.89e19 / 1e6." 8.89e13""If our scope is 1 km in radius . . ."area := 3.14 * 1e3 * 1e3." 3.14e6 square meters" "Our velocity needs to be at least"minCollectingVelocity := cubicMeterPerSecond / area. "==> 28,312 km/second" minCollectingVoverC := minCollectingVelocity / 3e8.  " 0.09 lightSpeed" "So this scheme is feasible if artificial CNO fusion is feasible. And if the CNO reactor and scoop does not consume too much of our mass budget."! !

!HumMeasure class methodsFor: 'examples' stamp: 'RichardAlexanderGreen 5/31/2014 22:08'!
exampleWateringHighPlains	"How much power is required to lift water from Missippi / Missouri to High Plains.	"	| density acre foot acreFoot mass gravity weight lift energy timePeriod watts irrigatedAcres totalWatts |		density := HumMeasure quantity: 1000 units: 'kilogram' per: 'cubic meter'.			" HumMeasure2( 1000 kilogram per cubic meter )"		acre := HumMeasure quantity: 4046.873 units: 'square meter'.		" HumMeasure2( 4046.873 square meter )"			foot := HumMeasure quantity: 0.3048 units: 'meter'.						" HumMeasure2( 0.305 meter )"						acreFoot := acre * foot.																			" HumMeasure2( 1233.487 cubic meter )"				mass := acreFoot * density.																		" HumMeasure2( 1.2334868904e6 kilogram )"																					gravity := HumMeasure quantity: 9.80665 units: 'meter' per: 'square second'.																														" HumMeasure2( 9.807 meter per square second )" 	weight := mass * gravity.																			" HumMeasure2( 1.2096374213741159e7 Newton )"																				lift := HumMeasure quantity: (5000*0.3048) units: 'meter'.		" HumMeasure2( 1524 meter )"	energy := weight * lift.																			" HumMeasure2( 1.8434874301741528e10 Joule )"	timePeriod := HumMeasure quantity: 31449600 units: 'second'.		" HumMeasure2( 31449600 second )"	watts := energy / timePeriod.																	" HumMeasure2( 586.172 Watt )"	irrigatedAcres := 13.6e6." 1.36e7"	totalWatts := watts * irrigatedAcres.		" HumMeasure2( 7.971938927798279e9 Watt ) ==> 8 GigaWatt"	^totalWatts asString.! !


!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 4/29/2013 10:32'!
acre: aNumber	| measure |	measure := self quantity: (4046.873 * aNumber) units: 'square meter'.		^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 5/4/2013 10:41'!
astronomicalUnit: aNumber	| measure |	measure := self quantity: ( aNumber * 149597870700 ) units: 'meter'.		^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 5/4/2013 10:42'!
au: aNumber	| measure |	measure := self astronomicalUnit: aNumber.	^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 5/4/2013 10:42'!
britishThermalUnit: aNumber	"Energy - British Thermal Unit (ISO)"	| measure |	measure := self quantity: ( aNumber * 1.0545) units: 'Joule'.	measure dimensions: (Dictionary newFrom: {'kilogram'->1. 'meter'->2. 'second'->(-2).}). 	^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 5/4/2013 10:42'!
btu: aNumber	"Energy - British Thermal Unit (ISO)"	| measure |	measure := self britishThermalUnit: aNumber.	^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 4/29/2013 10:34'!
foot: aNumber	| measure |	measure := self quantity: (0.3048 * aNumber) units: 'meter'.		^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 5/4/2013 10:32'!
footH2O: aNumber	"foot of water - pressure"	| measure |	measure := HumMeasure quantity: ( aNumber * 2.98898e3 ) units: 'Pascal'.	measure dimensions: (Dictionary newFrom: { }).	^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 6/13/2014 08:44'!
fromString: aString 	"Convert a string of the form '-999 units'"	| measure quantity units|	self assert: (aString isKindOf: String).	quantity := aString asNumber.	units := (HumCalculator given: aString extractAfter: (String space) ) trimBoth.	measure := HumMeasure quantity: quantity units: units.	^measure.			! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 4/29/2013 11:01'!
gravity: aNumber	| measure |	measure := self quantity: (9.80665 * aNumber) units: 'meter' per: 'square second'.	^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 4/29/2013 11:45'!
horsePower: aNumber	| measure |	measure := self quantity: ( aNumber * 735.49875 ) units: 'Watt'.	measure dimensions: (Dictionary newFrom: {'kilogram'->1. 'meter'->2. 'second'->(-3).}).	^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 5/4/2013 10:34'!
joule: aNumber	"Energy - British Thermal Unit (ISO)"	| measure |	measure := self quantity: ( aNumber ) units: 'Joule'.	measure dimensions: (Dictionary newFrom: {'kilogram'->1. 'meter'->2. 'second'->(-2).}). 	^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 4/29/2013 11:39'!
lightSpeed	| measure |	measure := self quantity: (1e8) units: 'meter' per: 'second'.	^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 4/29/2013 11:41'!
lightSpeed: aNumber	"Only makes sense if aNumber < 1."	| measure |	measure := self quantity: (1e8 * aNumber) units: 'meter' per: 'second'.	^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 5/4/2013 10:40'!
meter: aNumber	| measure |	measure := self quantity: (aNumber) units: 'meter'.		^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 5/4/2013 10:33'!
pascal: aNumber	"foot of water - pressure"	| measure |	measure := HumMeasure quantity: ( aNumber ) units: 'Pascal'.	measure dimensions: (Dictionary newFrom: {'kilogram'->1. 'meter'->(-1). 'second'->(-2). }).	^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 4/29/2013 11:47'!
psi: aNumber	"pound per square inch - pressure"	| measure |	measure := self quantity: ( aNumber * 6.894757e3 ) units: 'Pascal'.	measure dimensions: (Dictionary newFrom: {'kilogram'->1. 'meter'->(-1). 'second'->(-2).}). 	^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 8/21/2013 19:21'!
quantity: aNumber per: aSymbol 	| measure |	measure := self basicNew.	measure quantity: aNumber per: aSymbol.	^measure.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 4/28/2013 10:47'!
quantity: aNumber units: aString 	| instance |	instance := self basicNew.	instance quantity: aNumber units: aString.	^instance.! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 4/28/2013 10:11'!
quantity: aNumber units: numeratorUnits per: denominatorUnits	"Create instance with given numerator and denominator units.	Example1:	   milesPerHour := HumMeasure2 quantity: 65 units: 'miles' per: 'hour'.	   feetPerMile := HumMeasure2 quantity: 5280 units: 'feet' per: 'mile'.	   feetPerHour := milesPerHour * feetPerMile.		 secondsPerHour := HumMeasure2 quantity: 3600 units: 'seconds' per: 'hour'.		 feetPerSecond := feetPerHour / secondsPerHour.	"	| instance |	instance := self basicNew.	instance quantity: aNumber units: numeratorUnits per: denominatorUnits.	^instance.		 	 	 	 ! !

!HumMeasure class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 5/4/2013 10:35'!
watt: aNumber	"Energy - British Thermal Unit (ISO)"	| measure |	measure := self quantity: ( aNumber ) units: 'Watt'.	measure dimensions: (Dictionary newFrom: {'kilogram'->1. 'meter'->2. 'second'->(-3).}). 	^measure.! !


!classDefinition: #HumMessage category: #'Hum-RunTime'!
HumDataFrame subclass: #HumMessage
	instanceVariableNames: 'sender receiver whenSent statement nounValues'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumMessage commentStamp: 'RichardAlexanderGreen 4/25/2014 09:56' prior: 0!
A Hum Message handles data in-transit between Hum Actors.The Message class will serialize/deserialize messages to/from JSON or XML.For clarity, all Hum Messages represent Hum Action Statements sent between Hum Actors. The components of a message include sender, receiver, when sent, statement, and noun-values. Separation of function -- Messenger / Network / Message:  - The Messenger keeps track of which actors are online and where.- The Messenger also provides logging for playback and debug.- The Network wraps whatever technology is used for actor-to-actor communication.- If an actor is running in test mode, the convention is to start the URI with 'mock:'- The Network will skip the socket business when the URI starts with 'mock:'.- We will probably use Jabber technology for the network.   It provides a number of built-in operators including 'presence' that should come in handy.- The Network will send Hum Messages formatted as JSON objects  so that actors may use a number of different technologies.  (JSON is supported in almost all frameworks.)- In mock (test) mode, the Network will skip translation to/from JSON.- Hum Message will serialize/deserialize to/from JSON or XML. (as needed)		!


!HumMessage methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/10/2014 21:28'!
nounValues: associations 	nounValues := associations! !

!HumMessage methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/10/2014 21:22'!
receiver: aString 	receiver := aString ! !

!HumMessage methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/10/2014 21:21'!
sender: aString 	sender := aString.! !

!HumMessage methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/10/2014 21:26'!
statement: aHumStatement 	statement := aHumStatement ! !

!HumMessage methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/10/2014 21:25'!
whenSent: aTimeStamp 	" "	self assert: (( aTimeStamp isKindOf: TimeStamp ) or: [ aTimeStamp isKindOf: Duration ]).	whenSent := aTimeStamp ! !


!classDefinition: #HumNetwork category: #'Hum-RunTime'!
Object subclass: #HumNetwork
	instanceVariableNames: 'uriToNode'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumNetwork commentStamp: 'RichardAlexanderGreen 4/25/2014 09:42' prior: 0!
The Network wraps whatever technology is used for actor-to-actor communication.Separation of function -- Messenger / Network / Message:  - The Messenger keeps track of which actors are online and where.- The Messenger also provides logging for playback and debug.- The Network wraps whatever technology is used for actor-to-actor communication.- If an actor is running in test mode, the convention is to start the URI with 'mock:'- The Network will skip the socket business when the URI starts with 'mock:'.- We will probably use Jabber technology for the network.   It provides a number of built-in operators including 'presence' that should come in handy.- The Network will send Hum Messages formatted as JSON objects  so that actors may use a number of different technologies.  (JSON is supported in almost all frameworks.)- In mock (test) mode, the Network will skip translation to/from JSON.- Hum Message will serialize/deserialize to/from JSON.		!


!HumNetwork methodsFor: 'as yet unclassified' stamp: 'RichardAlexanderGreen 9/11/2014 15:20'!
sendAction: anInstruction toURI: recipientURI fromURI: senderURI 	"Send the (action) statement to the given actor."	| actorInstance |	self assert: (anInstruction isKindOf: HumInstructionLine).	"Following only works when actor is local."	"TODO: Fix so that it works when actor is remote."	actorInstance := ( self uriToNode ) at: recipientURI 	                              ifAbsent: [ Error signal: 'Network has no actor for URI: ', recipientURI ].	actorInstance runAction: anInstruction inRole: (anInstruction role) onJob: (anInstruction jobTicket).		! !


!HumNetwork methodsFor: 'URI to actor' stamp: 'RichardAlexanderGreen 9/16/2014 09:55'!
uriToNode	"Return dictionary that maps a URI to an actual actor instance"	"NOTE: This should only be used in test/local mode. 	(Mode where actors are running in same VM as the messenger.)"	^ uriToNode ifNil: [ uriToNode := Dictionary new. ].! !


!classDefinition: #HumNode category: #'Hum-RunTime'!
Object subclass: #HumNode
	instanceVariableNames: 'myURI myID clock'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumNode commentStamp: 'RichardAlexanderGreen 9/7/2014 13:07' prior: 0!
A Hum node may send and recieve Hum messages. !


!HumNode methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/16/2014 17:10'!
clock	^ clock ifNil: [clock := DateAndTime "class singleton"].! !

!HumNode methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/7/2014 13:42'!
clock: anObjectThatImplementsNow	clock := anObjectThatImplementsNow.	"WARNING: #clock also appears in HumConfiguration."! !

!HumNode methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/7/2014 13:08'!
id	^myID! !

!HumNode methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/7/2014 13:26'!
id: aString 	self assert: (aString isKindOf: String ).	myID := aString.! !

!HumNode methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/7/2014 13:26'!
uri	^myURI.! !

!HumNode methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/11/2014 15:18'!
uri: aURI	self assert: ( aURI isKindOf: String ).	myURI := aURI.	! !


!HumNode methodsFor: 'as yet unclassified' stamp: 'RichardAlexanderGreen 9/8/2014 10:29'!
checkIn	| |	"Check-in with the messenger."	( self messenger ) registerActor: self atURI: (self uri).! !


!classDefinition: #HumActor category: #'Hum-RunTime'!
HumNode subclass: #HumActor
	instanceVariableNames: 'roles blackboard stepLog configuration'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumActor commentStamp: 'RichardAlexanderGreen 9/7/2014 13:01' prior: 0!
An actor is capable of performing one or more roles.Some actors are part of the run-time systems and have particular configuration requirements.In general, an actor needs a connection to a messenger in order to communicate with the system.Most actors also need a connection to a manager so that the manager can assign actions to the actor.Some actors also need a connection to a bookkeeper so that the actor can record utilization.Instance Variables:	myID	<String>	myURI	<String>	messengerURI	<URI>	bookkeeperURI	<URI>	roles			<Collection of: String>	managerURI	<URI>	configuration	<HumConfiguration> -- (2014-09-07 HumActor is subtype of HumConfiguration)		Configuration:. An actor needs to know a messenger. (To simplify, we hide the details in a messenger proxy.). An actor checks-in with a manager/dispatcher.. An actor`s action interface is defined in an ontology. (The ontology might also define an implementation.)!


!HumActor methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/18/2012 10:40'!
blackboard	^ blackboard ifNil: [ blackboard := HumBlackBoard new. ].! !

!HumActor methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/1/2014 16:13'!
blackboard: aHumBlackBoard 	blackboard := aHumBlackBoard! !

!HumActor methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/7/2014 13:17'!
configuration	^ configuration! !

!HumActor methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/7/2014 13:14'!
configuration: aHumConfiguration 	configuration := aHumConfiguration.! !

!HumActor methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/14/2014 13:25'!
dispatcherID	^self configuration dispatcherID.! !

!HumActor methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/8/2014 10:39'!
messenger	^self configuration messenger.! !

!HumActor methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/7/2014 13:55'!
ontology	^self configuration ontology.! !

!HumActor methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/21/2013 16:04'!
roles	(roles isNil and: [self class = HumActor]) ifNil: [ Error signal: 'Actor {', myID,'} has no role.' ].	^roles ifNil: [ roles := { self class name. }].! !

!HumActor methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 1/26/2012 20:10'!
roles: anArray 	self assert: ( anArray isKindOf: Array ).	roles := anArray.! !


!HumActor methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 10/15/2014 13:03'!
checkIn	| statement quotedRoles instruction jobTicket quote |	"First, check-in with the messenger."	"TODO: REFACTOR THIS CALL."	( self messenger ) registerActor: self atURI: (self uri).	"Don't check-in with self."	(self isKindOf: HumDispatcher ) ifTrue: [^self.].	"Coordinator is not dispatched by Dispatcher"	(self isKindOf: HumCoordinator ) ifTrue: [^self.].	"Send check-in message to my Dispatcher."	quotedRoles := ''.
	quote := $' asString.
		(self roles)		do: [ :role | quotedRoles := quotedRoles, ' ', quote, role, quote ].			statement := HumStatement source: 'Check-in actor with roles.'.	statement role: #dispatcher;	          noun: 'actor' value: myURI;	          noun: 'roles' value: quotedRoles;	   translation: ('self checkInActor: ', quote,myID,quote, ' at: ', quote,myURI,quote, 'withRoles: #(', quotedRoles, ')').		jobTicket := HumJobTicket title: 'checkIn:',myID.	instruction := HumInstructionLine new.	instruction	  role: #dispatcher;		statement: statement;		jobTicket: jobTicket.	self delegateAction: instruction toRole: #dispatcher onJob: jobTicket.	! !

!HumActor methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/21/2014 10:33'!
completedAction: anAction inRole: aRoleString onJob: aHumJobTicket 	"Following is first-cut direct call.	When this is debugged, put an asynch wrapper on it.	"	| dispatcher   |	self assert: ( anAction isKindOf: HumInstructionLine).	dispatcher := (self messenger) getActorInstanceFromID: (self dispatcherID).	"TODO: Refactor above - It is using the messengers back door and is only valid in test mode."	self assert: (dispatcher isKindOf: HumDispatcher ).	dispatcher actor: (self id) completedAction: anAction.! !

!HumActor methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/16/2014 10:08'!
completedInstruction: aHumInstructionLine inRole: aRoleString onJob: aHumJobTicket 	"Following is first-cut direct call.	When this is debugged, put an asynch wrapper on it.	"	| dispatcher   |	self assert: ( aHumInstructionLine isKindOf: HumInstructionLine).	dispatcher := (self messenger) getActorInstanceFromID: (self dispatcherID).	"TODO: Refactor above - It is using the messengers back door and is only valid in test mode."	self assert: (dispatcher isKindOf: HumDispatcher ).	dispatcher actor: (self id) completedAction: aHumInstructionLine.! !

!HumActor methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/22/2014 14:40'!
delegateAction: anAction toRole: aRole onJob: aJobTicket	"Delegate action to another role."	| |		(self roles includes: aRole)		ifTrue: [ "If the role is one of my own, do action myself."			self runAction: anAction inRole: aRole onJob:  aJobTicket ]		ifFalse: ["Otherwise have the dispatcher send it to some actor that knows the role."			anAction jobTicket: aJobTicket.			(self messenger) sendAction: anAction toID: (self dispatcherID) fromID: myID. "STUB"].	! !

!HumActor methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/16/2014 10:14'!
runAction: anAction inRole: aRole onJob: aHumJobTicket	"Run the action frame named ..." 	| ontology lines |	self assert: (anAction isKindOf: HumInstructionLine ).	ontology := self configuration ontology.	self assert: (ontology frames notEmpty).	"TODO: Ontology has instruction sequence, but lacks frame lines."	lines := ontology instructionsForRole: aRole action: anAction.	(lines size > 0 ) ifFalse: [Error signal: 'Action: {',anAction source,'} is not defined.'].	lines do: [ :frameLine | 		self runInstruction: frameLine inRole: aRole onJob: aHumJobTicket.		].	"Tell Dispatcher that we completed action normally."	self completedAction: anAction inRole: aRole onJob: aHumJobTicket.! !

!HumActor methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/22/2014 14:43'!
runInstruction: anInstruction inRole: aRole onJob: aJobTicket	"Execute, simulate, or log the given statement"	| charge aStatement |	self assert: ( anInstruction isKindOf: HumInstructionLine ).	aStatement := anInstruction statement.	"If instruction role is not one of my roles, delegate the instruction."	(anInstruction role > '')		ifTrue: [(self roles includes: anInstruction role) 								ifFalse: [ ^self delegateAction: anInstruction toRole: anInstruction role onJob: aJobTicket ].						].	"If statement has a translation (assume Smalltalk), run the translation."			( aStatement translation notNil ) 		ifTrue: ["Execute in Smalltalk -- TODO: What if translation is for Erlang/Java/...?"			Compiler evaluate: (aStatement translation) for: self logged: false.			"Charge to job ticket"				charge := HumMeasure quantity: 1 units: #step.   			aJobTicket appendCharge: charge forAction: aStatement byActor: myID inRole: aRole onJob: aJobTicket.			"Tell Dispatcher that we completed action normally."			self completedInstruction: anInstruction inRole: aRole onJob: aJobTicket.			^self.			]		ifFalse: [ "Simulate execution"			"Append to log"			self stepLog add: ('Actor: ', myID, ' is doing: ', aStatement source).			( aStatement nounValues )				keysAndValuesDo: [ :noun :value | stepLog add: ('. with: ', noun, ' = ', value asString). ].			"Charge to job ticket"				charge := HumMeasure quantity: 1 units: #step.   			aJobTicket appendCharge: charge forAction: aStatement byActor: myID inRole: aRole onJob: aJobTicket.			^ self.			].	Error signal: 'Statement type not handled.'.! !


!HumActor methodsFor: 'logging' stamp: 'RichardAlexanderGreen 6/9/2014 09:21'!
stepLog	^ stepLog ifNil: [ stepLog := OrderedCollection new.]! !

!HumActor methodsFor: 'logging' stamp: 'RichardAlexanderGreen 8/12/2014 10:04'!
stepLogDisplay	"Display the step log"	Transcript cr; show: 'Step log from actor: ', (self id asString);cr.	(self stepLog) do: [:s | Transcript show: '. ', s; cr.]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumActor class' category: #'Hum-RunTime'!
HumActor class
	instanceVariableNames: ''!

!HumActor class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 7/2/2014 10:43'!
bookkeeperID: myID uri: myURI configuration: aHumConfiguration 	| instance |	instance := HumBookkeeper configuration: aHumConfiguration.	instance id: myID; uri: myURI.	^instance. ! !

!HumActor class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 7/2/2014 10:42'!
coordinatorID: myID uri: myURI goal: aGoalStatementString dialog: aHumDialogAgent configuration: aHumConfiguration 	| instance |	instance := HumCoordinator configuration: aHumConfiguration.	instance  id: myID; 	          uri: myURI; 					 goal: aGoalStatementString; 	    dialogAgent: aHumDialogAgent.	^instance.! !

!HumActor class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 9/7/2014 19:22'!
dialogID: myID uri: myURI client: clientURI configuration: aHumConfiguration	| instance |	instance := HumDialogAgent configuration: aHumConfiguration.	instance  id: myID; 					 uri: 'URI:',myID; 					blackboard: (HumBlackBoard worldbase: (aHumConfiguration worldbaseID) );				 client: myID.	^instance.	! !

!HumActor class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 9/14/2014 13:32'!
dispatcherID: myID uri: myURI configuration: aHumConfiguration 	| instance |	instance := HumDispatcher configuration: aHumConfiguration.	instance id: myID; uri: myURI. 	^instance. ! !

!HumActor class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 9/17/2014 10:35'!
scribeID: myID dialog: dialogURI uri: myURI client: clientURI configuration: aHumConfiguration	| instance |	"TODO: REFACTOR - This looks backwards. 	The scribe initiates the dialog agent. 	The dialog agent is not already present.	"	instance := HumScribe new.	instance id: myID; 					 uri: myURI; 					roles: #('scribe' #scribe);					 configuration: aHumConfiguration; "Use a common configuration (messenger, Dispatcher, ...)"					 blackboard: (HumBlackBoard worldbase: aHumConfiguration worldbaseID );				   clientConnection: clientURI. "How do we connect / have connection with client."	instance dialogAgentURI: dialogURI.	^instance.	! !

!HumActor class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 7/2/2014 10:34'!
workerID: workerID uri: workerURI roles: arrayOfRoleNames configuration: aHumConfiguration 	| instance |	instance := self configuration: aHumConfiguration.	instance id: workerID; 					uri: workerURI; 					roles: arrayOfRoleNames.	^instance.! !


!HumActor class methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/7/2014 13:13'!
configuration: aHumConfiguration 	| instance |	instance := self basicNew.	instance configuration: aHumConfiguration.	instance initialize.	^instance.! !


!classDefinition: #HumBookkeeper category: #'Hum-RunTime'!
HumActor subclass: #HumBookkeeper
	instanceVariableNames: 'jobTickets'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumBookkeeper commentStamp: 'RichardAlexanderGreen 9/19/2012 11:34' prior: 0!
The bookkeeper records resource utilization and expenditure statistics.It provides the basic data needed for cost accounting and system utilization analysis.Instance Variables:	jobTickets	<OrderedCollection>!


!HumBookkeeper methodsFor: 'sums' stamp: 'RichardAlexanderGreen 9/22/2014 09:48'!
chargesBy: attribute	"Produce sums for each role."	| sums |	sums := Dictionary new.	jobTickets 		do: [ :ticket |			| charges |			charges := ticket charges.						charges do: [:charge |				| key sumBy units amount x |				amount := charge at: 'measure'.				sumBy := charge at: attribute.				units := amount units.				key := sumBy,':',units.				x := sums at: key 				    ifAbsent: [ |q| q := amount copy quantity: 0. q].				x := x + amount.				sums at: key put: x.				].			].		^sums.! !

!HumBookkeeper methodsFor: 'sums' stamp: 'RichardAlexanderGreen 9/19/2014 09:32'!
chargesByAction	"Produce sums for each role."	| sums |	sums := self chargesBy: 'action'.	^sums.! !

!HumBookkeeper methodsFor: 'sums' stamp: 'RichardAlexanderGreen 9/19/2014 09:32'!
chargesByActor	"Produce sums for each role."	| sums |	sums := self chargesBy: 'ID'.		^sums.! !

!HumBookkeeper methodsFor: 'sums' stamp: 'RichardAlexanderGreen 9/19/2014 09:30'!
chargesByJob	| sums |	sums := self chargesBy: 'job'.	^sums.! !

!HumBookkeeper methodsFor: 'sums' stamp: 'RichardAlexanderGreen 9/19/2014 10:58'!
chargesByMetric	"Produce sums for each role."	| sums |	sums := Dictionary new.	jobTickets 		do: [ :ticket |			| charges |			charges := ticket charges.			charges do: [:charge |				| key sumBy units amount x |				amount := charge at: 'measure'.				units := amount units.				sumBy := 'total'.				key := sumBy,':',units.				x := sums at: key 				    ifAbsent: [ |q| q := amount copy quantity: 0. q].				x := x + amount.				sums at: key put: x.				].			].		^sums.! !

!HumBookkeeper methodsFor: 'sums' stamp: 'RichardAlexanderGreen 9/19/2014 09:28'!
chargesByRole	"Produce sums for each role."	| sums |	sums := self chargesBy: 'role'.	^sums.! !


!HumBookkeeper methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 2/13/2012 11:02'!
jobTickets	^ jobTickets ifNil: [ jobTickets := OrderedCollection new. ].! !

!HumBookkeeper methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/20/2013 11:11'!
recordJobTicket: aHumJobTicket 	(self jobTickets) add: aHumJobTicket.! !


!classDefinition: #HumCoordinator category: #'Hum-RunTime'!
HumActor subclass: #HumCoordinator
	instanceVariableNames: 'goal context remainingConditions dialogAgent planFrames jobTicket'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumCoordinator commentStamp: 'RichardAlexanderGreen 9/19/2012 11:43' prior: 0!
The supervisor tracks the execution state of a plan.The state includes which conditions are satisfied, which plan frames have been completed, the accumulated resource utilization associated with the execution, and any exceptions that were encounterd or are currently pending resolution.Instance Variables:	ontology	<HumOntology>	goal	<ProtoObject | PseudoContext>	context	<Object>	remainingConditions	<Integer>	dialogAgent	<ProtoObject | PseudoContext>	planFrames	<Collection | PTEnumerable | PragmaCollector>!


!HumCoordinator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 2/3/2012 17:33'!
context: aHumActor	context := aHumActor.! !

!HumCoordinator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/2/2014 10:42'!
coordinatorID: anID uri: aURI goal: aGoalStatementString dialog: aHumDialogAgent configuration: aHumConfiguration	self configuration: aHumConfiguration.		self id: anID.	self uri: aURI.	self goal: aGoalStatementString.	self dialogAgent: aHumDialogAgent.			^self.	! !

!HumCoordinator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/24/2013 11:23'!
dialogAgent: aHumDialogAgent 	"Concept: The dialog agent provides noun values 	 as needed to populate plan and action statements."	self assert: ( aHumDialogAgent isKindOf: HumDialogAgent ).	dialogAgent := aHumDialogAgent.! !

!HumCoordinator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/17/2013 12:55'!
goal: aStatement	goal := nil.	(aStatement isKindOf: HumStatement ) ifTrue: [ goal := aStatement. ^self ].	( aStatement isKindOf: String )		ifTrue: [ "Get the goal statement from the root frame."			| rootFrame statement |			rootFrame := (self ontology) getPlanFrameForGoal: aStatement.			statement := rootFrame goal.			self assert: (statement isKindOf: HumStatement).			goal := statement.			^self.			].	! !

!HumCoordinator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/8/2013 10:37'!
goalStatement	"Translate goal string to goal statement"	"TODO: THERE IS SOMETHING WRONG HERE."	| rootFrame statement |	rootFrame := ((self ontology) getPlanFrameForGoal: goal).	statement := rootFrame goal.	self assert: (statement isKindOf: HumStatement ).	^ statement. ! !

!HumCoordinator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/22/2014 10:31'!
jobTicket	^ jobTicket ifNil: [ jobTicket := HumJobTicket title: goal ].! !

!HumCoordinator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/23/2013 09:20'!
remainingConditions	^ remainingConditions ifNil: [ remainingConditions := Set new.] .! !


!HumCoordinator methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/22/2014 14:45'!
runAction: anInstructionLine 	"Run the given action statement."	| debug |	debug := true. 	debug ifTrue: [ Transcript cr; show: 'HumCoordinator ',myID,' is running { ', anInstructionLine source, ' }'.].	anInstructionLine runInContext: self.	"TODO: Implement the round-trip:	       Coordinator ==> Dispatcher ==> Actor ==> Dispatcher (Bookkeeper) ==> Coordinator"	anInstructionLine jobTicket: (HumJobTicket title: goal).	(self messenger) sendAction: anInstructionLine toID: (self configuration dispatcherID) fromID: myID.	! !

!HumCoordinator methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 7/17/2013 10:33'!
runPlan	"Run my plan.	"	|  result |	self runPlanSetup.	result := self runPlanFrameForCondition: goal.	result 		ifFalse: [ Error signal: 'Attempt to run plan for goal: {',goal,'} has failed.'].! !

!HumCoordinator methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/4/2014 13:44'!
runPlanFrameForCondition: aGoalString	"This visits the subtree and runs each frame that is ready to run.	TODO: SOMEDAY THIS SHOULD PERMIT ACTIONS TO RUN IN PARALLEL.	TODO: Write several tests.	"	| rootFrame result |	"If the condition is already satisfied (not in remainingConditions set), we can skip and return immediately."	remainingConditions detect: [:condition | condition sameAs: aGoalString ] ifNone: [  ^true.].	"Get the root of this subtree."	rootFrame := (self ontology) getPlanFrameForGoal: aGoalString.	"REFACTOR: The rootFrame does not know if it is runnable. But the Coordinator knows."	( self isPlanFrameRunnable: rootFrame )		ifTrue: ["Run its actions and then declare the goal satisfied"			"Run actions"			(rootFrame actionStatements) 				do: [ :action | self runAction: action.  ].			"Declare goal satisfied"			self conditionIsSatisfied: rootFrame goal.			^true.	 "Indicates something was runnable. See check below."			] "ifTrue"		ifFalse: [ "Try to satisfy the preconditions."			result := false.			( rootFrame preconditions )					do: [ :precondition |						| preconditionString stepResult |						preconditionString := precondition statement source.						"Call recursively on preconditions."						stepResult := self runPlanFrameForCondition: preconditionString.						result := result | stepResult.  "Boolean"						]. "do"					"Check post condition 					-- At least one precondition in the tree should be runnable on each iteration."					result ifFalse: [ Error signal: 'Nothing in the subtree was runnable!!']					]."ifFalse"						"Fall through to here when goal frame is not runnable and we ran preconditions.		Now try again."		((self remainingConditions ) isEmpty) 			ifTrue: [ Error signal: 'Remaining conditions should not be empty in this recursive loop.'.				"In this context,				 the remaining conditions should include the original goal, 				 and therfore, not be empty yet."				].		result := self runPlanFrameForCondition: aGoalString.		^result.			! !

!HumCoordinator methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/22/2014 10:45'!
runPlanSetup	"Setup to run a plan:	1. Assure plan is runnable.	2. Populate the remaining conditions collection. ()	3. Initialize the job ticket?	TODO: WATCH OUT: instance variables passed via the back-door 	"	| |	self assert: (goal isKindOf: HumStatement ).	self planIsRunnable ifFalse: [ Error signal: 'Plan is not runnable for goal: ', goal ].	planFrames := self ontology collectPlanFramesForGoal: (self goalStatement).  "Populate the remaining conditions collection"	(self remainingConditions) add: goal.	jobTicket := HumJobTicket title: goal.	planFrames		do: [ :frame |				( frame preconditions )						do: [ :precondition |								remainingConditions add: (precondition statement).							].			].! !


!HumCoordinator methodsFor: 'evaluating' stamp: 'RichardAlexanderGreen 7/23/2013 10:33'!
isPlanFrameRunnable: aHumFrame4Plan	"Determine if the given plan frame is runnable.	To be runnable, it`s preconditions must all be satisfied.	TODO: This implementation is only correct where the noun values do not affect.	Assumes: All instances of the condition have the same noun values.	" 	(aHumFrame4Plan preconditions)		do: [ :precondition | 				((self remainingConditions) includes: (precondition statement) )						ifTrue: [^false]						].		^true				! !

!HumCoordinator methodsFor: 'evaluating' stamp: 'RichardAlexanderGreen 9/14/2014 13:50'!
planIsRunnable	"TODO: ADD NEEDED CHECKS TO THIS STUB."	| |	context := dialogAgent.	self assert: ( context isKindOf: HumDialogAgent ).	self assert: ( goal isKindOf: HumStatement ).	"		Additional Preconditions:	. All nouns in the goal statement have values on the dialog agent's' blackboard.	. The frame collection is complete.	. All the roles in the action statements are known (checked-in) to the Dispatcher.	. All action statements are defined in the ontology.	"	"TODO: DANGER -- THIS IS A STUB!!!!!!"	^true.! !


!HumCoordinator methodsFor: 'events-registering' stamp: 'RichardAlexanderGreen 9/4/2014 13:18'!
conditionIsSatisfied: precondition 	"Note that condition is satisfied.	Then runnable frames may change.	If all conditions have been satisfied, the goal is achieved.	THINK: Should the goal itself be in remainingConditions collection?	"	| debug |	(debug := false). debug ifTrue: [Transcript cr; show: 'HumCoordinator conditionIsSatisfied: ', precondition asString. ].	self assert: ( precondition isKindOf: HumStatement ).		precondition isSatisfied: true.	(self remainingConditions) 		remove: precondition 		ifAbsent: [Error signal: 'absent condition: ', precondition "statement" source]! !


!HumCoordinator methodsFor: 'logging' stamp: 'RichardAlexanderGreen 5/24/2014 10:26'!
getActionSequence	"Parse the job ticket to show the sequence of actions."	| listOfActions |	listOfActions := jobTicket getActionSequence.	^listOfActions.! !


!classDefinition: #HumDialogAgent category: #'Hum-RunTime'!
HumActor subclass: #HumDialogAgent
	instanceVariableNames: 'clientURI clientID contextStack scribeProxy'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumDialogAgent commentStamp: 'RichardAlexanderGreen 8/13/2014 13:23' prior: 0!
A Dialog Agent responds to client/user inputs according to the dialog vignettes in an ontology.A Scribe interprets user interface input (gestures)and sends those inputs to the dialog agent.A Scribe (subtype) implements a user interface.See HumScribe documentation.A Dialog has a history.The history may be represented by a sequence of User Inputs with corresponding system responses.The history has also caused the context 'stack' to be what it is.!


!HumDialogAgent methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 8/17/2014 19:53'!
client: aString 	clientID := aString.	clientURI := 'URI:',aString.! !

!HumDialogAgent methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/16/2014 21:27'!
contextStack	^ contextStack ifNil: [ contextStack := OrderedCollection new. self pushContext: 'new'. contextStack ].! !

!HumDialogAgent methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/16/2014 21:27'!
pushContext: aString 	( self contextStack ) addLast: aString.! !

!HumDialogAgent methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 8/13/2014 13:30'!
scribeProxy	"Return an instance that understands #systemSays:	"	^scribeProxy ifNil: [ scribeProxy := HumScribe new. ].! !

!HumDialogAgent methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/2/2014 09:39'!
setEntityID: anEntityID attribute: anAttributeType toValue: aValue 	"Delegate to my blackboard."	( self blackboard ) setEntityID: anEntityID attribute: anAttributeType toValue: aValue. ! !


!HumDialogAgent methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 10/16/2014 21:28'!
clientSays: aString 	"Match user utterance to vignette patterns in the ontology	and return the vignette frame with the best match.	"	| bestMatch |	"We need a context stack to define the best match."	self assert: ( self contextStack isKindOf: OrderedCollection ).	self assert: ( self contextStack notEmpty ).	"Delegate the search to the ontology."	bestMatch := self ontology findBestMatchingVignetteForInput: aString inContextStack: (self contextStack).	"TODO: Now that I've got a vignette (or not), what do I do with it?"	self assert: ( bestMatch isKindOf: HumFrame4Vignette ).	(self stepLog) add: (clientID asString,': ', aString).	self interpretVignette: bestMatch.	^ bestMatch.! !


!HumDialogAgent methodsFor: 'user interface' stamp: 'RichardAlexanderGreen 8/11/2014 10:34'!
interpretVignette: aHumFrame4Vignette 	"Send response lines. Execute response instructions."	| responseLines responseInstructions proxy |	responseLines := aHumFrame4Vignette responseLines.	self assert: (responseLines size > 0).	responseInstructions := aHumFrame4Vignette instructionLines.	self assert: (responseInstructions size >= 0).	responseLines do: [ :responseLine | self sayToClient: responseLine. ].! !

!HumDialogAgent methodsFor: 'user interface' stamp: 'RichardAlexanderGreen 8/13/2014 13:25'!
sayToClient: aHumMarkupLine 	"Say something to the client. 	 Subtypes will override."	| systemResponse |	systemResponse := aHumMarkupLine source. 	(self stepLog) add: ('S: ', systemResponse ).	(self scribeProxy) systemSays: systemResponse. 	! !


!classDefinition: #HumDispatcher category: #'Hum-RunTime'!
HumActor subclass: #HumDispatcher
	instanceVariableNames: 'roleActor actorURI availableActors busyActors'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumDispatcher commentStamp: 'RichardAlexanderGreen 9/14/2014 13:18' prior: 0!
The dispatcher assigns actors to perform actions.An actor registers itself with a dispatcher and identifies the roles that it knows.When a running plan or dialog requires that an action be performed, the dispatcher finds an available actor that knows that role (has that capability) and assigns the requested action to that actor.When the actor has completed the role, it becomes available for further assignments.Instance Variables:	roleActor	<Set>	actorURI	<Dictionary>!


!HumDispatcher methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/20/2013 10:43'!
availableActors	^ availableActors ifNil: [ availableActors := Set new. ].! !

!HumDispatcher methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/20/2013 10:55'!
busyActors	^ busyActors ifNil: [ busyActors := Set new ].! !

!HumDispatcher methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/14/2014 13:49'!
checkInActor: actorID at: aURI withRoles: actorKnowsRoles 	"The Dispatcher should delegate finding the URI to messenger."	"For each actor role: 	. Add the actor to those that know that role."	self assert: ( actorKnowsRoles isKindOf: Array ).	actorKnowsRoles do: [ :aRole |		( self roleActor )  add: ( aRole -> actorID ).		( self availableActors ) add: actorID.		].		! !

!HumDispatcher methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 6/20/2013 10:40'!
roleActor	"Return the role->actor map set."	^ roleActor ifNil: [ roleActor := Set new. ].! !


!HumDispatcher methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/21/2014 10:34'!
actor: anActor completedAction: aHumStatement	"Dispatcher is informed that the actor completed the assigned action.	See: #assignRole: roleString action: actionStatement	"		| bookkeeperInstance |	(anActor sameAs: myID)		ifTrue: ["Dispatcher (self) cannot be busy and must always be available."]		ifFalse: [	"Actor is no longer busy."							( self busyActors ) remove: anActor.							( self availableActors ) add: anActor.							].	"Send charges to bookkeeper."	"For now, just call direct.	TODO: Make asynch call to bookkeeper.	"	bookkeeperInstance := (self messenger) getActorInstanceFromID: (self configuration bookkeeperID).	"TODO: Refactor this. It is by-passing the messenger."	bookkeeperInstance recordJobTicket: ( aHumStatement jobTicket ) .	! !

!HumDispatcher methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/11/2014 14:50'!
assignAction: aHumInstructionLine toRole: aByteString forJob: aHumJobTicket 	self shouldBeImplemented.! !

!HumDispatcher methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/15/2014 08:35'!
assignRole: roleString action: actionInstruction 	"Assign the given action to an actor advertising the given role."	| actor potentialActors assignableActors  |	self assert: ( roleString isKindOf: String ).	self assert: ( roleString notEmpty ).	self assert: ( actionInstruction isKindOf: HumInstructionLine ).	potentialActors := Set new.	"Find an actor that knows the role."	( self roleActor ) 		do: [ :map | 			map key = roleString asLowercase  				ifTrue: [ potentialActors add: map value. ].			].	"Filter potential actors to include only available actors."	assignableActors := potentialActors intersection: (self availableActors).	"Assign an actor at random."	assignableActors ifEmpty: [Error signal: 'Set of assignableActors is empty - Now what?'].	actor := assignableActors atRandom.	(actor sameAs: myID)		ifTrue: ["Manager (self) cannot be busy and must always be available."]		ifFalse: ["Mark actor busy and not available."							(self busyActors) add: actor.							(self availableActors) remove: actor.							].			"Send the action to the actor."	self sendMessage: actionInstruction to: actor.	"Simulating asynch: 	. The completion comes back via callback #actor: anActor completedAction: aStatement"		! !

!HumDispatcher methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/16/2014 10:11'!
runAction: anAction inRole: aRole onJob: aHumJobTicket	"Dispatch the action to an actor in the given role." 	|  |	self assert: ( aRole isKindOf: String ).	self assert: ( aRole notEmpty ).	self assert: (anAction isKindOf: HumInstructionLine).	( aRole = #dispatcher )		ifTrue: ["This action is for me as dispatcher."			self assert: (anAction statement translation notNil).			Compiler evaluate: (anAction statement translation) for: self logged: false.			^self.			].	"Otherwise: Assign action to an actor that has registered previously with that role."		anAction jobTicket: aHumJobTicket.	self assignRole: aRole action: anAction 	! !

!HumDispatcher methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/11/2014 15:55'!
sendMessage: aMessageObject to: recipientID.	"TODO: HumActor does not need to know that delegating a statement is a message send.	 Replace this with something like: self delegateAction: aStatement to: aRole.	"	"self checkID: recipientID."	self assert: (aMessageObject isKindOf: HumInstructionLine). 	( self messenger ) sendAction: aMessageObject toID: recipientID fromID: myID.		! !


!classDefinition: #HumMessenger category: #'Hum-RunTime'!
HumNode subclass: #HumMessenger
	instanceVariableNames: 'playbackLog uriToNodeID nodeIDtoURI network'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumMessenger commentStamp: 'RichardAlexanderGreen 9/7/2014 12:50' prior: 0!
The communication bus provides a message store and forward service with optional logging.If an actor is temporarily not available, a message will be held for some (TBD) time.The messages to a role may be replayed later.instanceVariableNames: - uriActor 		dictionary maps URI to actor instance (assumes actor is running in local VM)- actorURI 		dictionary maps ID to URI- uriActorID 	dictionary maps URI to ID- playbackLog  logs messages to enable playback and debugSeparation of function -- Messenger versus Network:  - The Messenger keeps track of which actors are online and where.- The Messenger also provides logging for playback and debug.- The Network wraps whatever technology is used for actor-to-actor communication.- If an actor is running in test mode, the convention is to start the URI with 'mock:'- The Network will skip the socket business when the URI starts with 'mock:'.- We will probably use Jabber technology for the network.   It provides a number of built-in operators including 'presence' that should come in handy.Configuration:. The messenger needs a place to write persistant logs (to support replay and debug).. The logs could be on the worldbase, but what if the worldbase is down?		!


!HumMessenger methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/11/2014 15:08'!
network	"Return the chosen physical implementation of network service."	^ network ifNil: [ network := HumNetwork new].! !

!HumMessenger methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/7/2014 14:38'!
nodeIDtoURI	"actorURI contains (actor->URI) maps"	^ nodeIDtoURI ifNil: [ nodeIDtoURI := Dictionary new ].! !

!HumMessenger methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/3/2014 07:43'!
playbackLog	^playbackLog ifNil: [ playbackLog := Dictionary new].! !

!HumMessenger methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/11/2014 13:59'!
playbackLogFromActor: aHumActor 	"Extract/Get log entries sent to/from a specific actor.	TODO: Should this be a URI instead of an Actor instance?"	| result |	result := (self playbackLog) at: (aHumActor uri) ifAbsent: [ OrderedCollection new].	"TODO: Add timestamp feature. 	 Someday, we may want to roll-forward from a given timestamp.	 Note: timestamps may be from simulated clock rather than system clock."	^result.	! !

!HumMessenger methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/11/2014 13:59'!
playbackLogFromURI: aURI 	"Extract/Get log entries sent to/from a specific actor.	TODO: Should this be a URI instead of an Actor instance?"	| result |	result := (self playbackLog) at: (aURI) ifAbsent: [ OrderedCollection new].	"TODO: Add timestamp feature. 	 Someday, we may want to roll-forward from a given timestamp.	 Note: timestamps may be from simulated clock rather than system clock."	^result.	! !

!HumMessenger methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/11/2014 14:18'!
playbackLogToURI: aURI 	"Extract/Get log entries sent to/from a specific actor.	TODO: Should this be a URI instead of an Actor instance?"	| result |	result := OrderedCollection new.	(self playbackLog) 		keysAndValuesDo: [:key :value |			| actorLog |			actorLog := value.			actorLog do: [ :record |				| toURI |				toURI := record at: 2.				(toURI = aURI)					ifTrue: [ result add: record ].				].			].	"TODO: Add timestamp feature. 	 Someday, we may want to roll-forward from a given timestamp.	 Note: timestamps may be from simulated clock rather than system clock."	^result.	! !

!HumMessenger methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/7/2014 14:36'!
uriToNodeID	"What actor ID is associated with URI?"	^ uriToNodeID ifNil: [ uriToNodeID := Dictionary new]! !


!HumMessenger methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/7/2014 14:34'!
ping: aURI	"MOCK: Return the ID of the given URI"	^ ( self uriToNodeID ) at: aURI ifAbsent: [ Error signal: 'Messenger has no ID entry for URI: ', aURI ].! !

!HumMessenger methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/7/2014 14:46'!
registerActor: anActor atURI: aURI 	"Track actor."	self assert: ( anActor isKindOf: HumActor ).	self assert: ( aURI isKindOf: String ).	"Track URI->actor association."	self registerNode: anActor atURI: aURI.! !

!HumMessenger methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/11/2014 15:33'!
registerNode: aNode atURI: aURI 	"Track actor."	self assert: ( aNode isKindOf: HumNode ).	self assert: ( aURI isKindOf: String ).	"Track URI->actor association."	(self network uriToNode) at: aURI put: aNode.	(self uriToNodeID) at: aURI put: (aNode id).	(self nodeIDtoURI) at: (aNode id) put: aURI.! !

!HumMessenger methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/10/2014 16:14'!
sendAction: anInstructionLine toID: recipientID fromID: senderID 	"Transmit action request between actors."		| recipientURI senderURI|	self assert: (anInstructionLine isKindOf: HumInstructionLine).	self assert: (recipientID isKindOf:String).	self assert: (senderID isKindOf:String).		"Translate ID to URI."	recipientURI := ( self nodeIDtoURI ) at: recipientID 														ifAbsent: [Error signal: 'Messenger has no URI for actor ID: ', recipientID].													senderURI := ( self nodeIDtoURI ) at: senderID 														ifAbsent: [Error signal: 'Messenger has no URI for actor ID: ', senderID].	"Send  . . ."	self sendAction: anInstructionLine toURI: recipientURI fromURI: senderURI.	! !

!HumMessenger methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/11/2014 15:06'!
sendAction: anInstruction toURI: recipientURI fromURI: senderURI 	"Send the (action) statement to the given actor."	| |	self assert: (anInstruction isKindOf: HumInstructionLine).	self logInstruction: anInstruction sentFrom: senderURI to: recipientURI. 	"Delegate implementation to HumNetwork"	self network sendAction: anInstruction toURI: recipientURI fromURI: senderURI. 		! !

!HumMessenger methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/7/2014 16:21'!
sendInstruction: anInstruction toURI: recipientURI fromURI: senderURI	"Send the (action) statement to the given actor."	"TODO: REFACTOR so that this pushes to a network. 	And so the network becomes the mock instead of the messenger.	This moves us toward using an actual network. (Likely a jabber network.)"	| actorInstance |	self assert: (anInstruction isKindOf: HumInstructionLine).	"Following only works when actor is local."	"TODO: Fix so that it works when actor is remote."	actorInstance := ( self uriToNode ) at: recipientURI 	                                       ifAbsent: [ Error signal: 'Messenger has no actor for URI: ', recipientURI ].	self logInstruction: anInstruction sentFrom: senderURI to: recipientURI. 	actorInstance runInstruction: anInstruction inRole: (anInstruction role) onJob: (anInstruction jobTicket).	"TODO: Need a better simulation of async."	"========================================"		! !


!HumMessenger methodsFor: 'events-registering' stamp: 'RichardAlexanderGreen 9/22/2014 16:47'!
logInstruction: aHumStatement sentFrom: senderURI to: recipientURI 	| timeNow logEntry |	"Get the clock time - may be a simulator clock"	timeNow := ( self clock ) now.	logEntry := (self playbackLog) at: senderURI ifAbsent: [ logEntry := OrderedCollection new. ].	logEntry add: { senderURI.  recipientURI. aHumStatement. timeNow. }.	playbackLog at: senderURI put: logEntry.! !


!HumMessenger methodsFor: 'URI to actor' stamp: 'RichardAlexanderGreen 9/11/2014 15:31'!
getActorInstanceFromID: actorID	"*** Backdoor *** during debug to bypass the messenger"	| actorInstance someURI |	self assert: (actorID notNil).	someURI := (self nodeIDtoURI) at: actorID ifAbsent: [Error signal: 'Trouble getting actorURI for: ', actorID ].	actorInstance := (self network uriToNode) at: someURI ifAbsent: [Error signal: 'Trouble getting actorInstance for: ', actorID ].	^actorInstance.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumMessenger class' category: #'Hum-RunTime'!
HumMessenger class
	instanceVariableNames: ''!

!HumMessenger class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 2/10/2012 13:49'!
uri: aString 	| instance |	instance := self basicNew.	instance uri: aString.	^instance.! !


!classDefinition: #HumScribe category: #'Hum-RunTime'!
HumActor subclass: #HumScribe
	instanceVariableNames: 'dialogAgent clientConnection jobID dialogAgentURI instructionInProgress'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumScribe commentStamp: 'RichardAlexanderGreen 8/13/2014 11:52' prior: 0!
A Scribe translates client/user inputs (sensors, gestures, keyboard, messages)into a form usable by a dialog agent.The Dialog Agent responds to user inputs according to dialog vignettes seen in an ontology.The response is returned to the client/user via the Scribe.The Scribe translates responses into the form required by the client/user interface framework.See: documentation for Dialog Agents, Vignette Frames.(HumDialogAgent, HumFrame4Vignette)Q: How/When/Where/Why is a Scribe instantiated? A: A Scribe instance must be in the channel when a client/user is communicating.. . A Scribe is basically a sensor-interpreter.. . In a web/chat application, a simple scribe would simply operate a chat pane.. . When a view frame is operated, a web scribe would translate it into an HTML form.. Therefore:. . A web application server will create a Scribe instance when it initiates a connection.. . In the Java vocabulary, the Scribe may be a kind of servlet or applet.. Also: A dialog-history is associated with a client/user.. Therefore: . . When a server establishes client/user identity, . . . the dialog-history must be fetched (from World Base).. . The dialog-history is needed to properly initialize a Dialog Agent.. . . So. that is when we need to instantiate the Dialog Agent.. . . The Dialog Agent is configured with Scribe, Ontology, World Base.. . . !


!HumScribe methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/3/2014 09:23'!
client: aClientConection 	"synonym"	self clientConnection: aClientConection.! !

!HumScribe methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/3/2014 08:50'!
clientConnection: aConnectionOfSomeKind 	"How does the Scribe connect to the user/client sensors?"	"TODO: THIS NEEDS DEEPER/MORE DETAILED THOUGHT."	clientConnection := aConnectionOfSomeKind ! !

!HumScribe methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/7/2014 19:40'!
dialogAgent	"Returns an instance of HumDialogAgent."	^dialogAgent ifNil: [ dialogAgent := HumActor dialogID: myID uri: myURI client: clientConnection configuration: self configuration ]! !

!HumScribe methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 8/13/2014 19:52'!
dialogAgent: aHumDialogAgent	self assert: (aHumDialogAgent isKindOf: HumDialogAgent).	dialogAgent := aHumDialogAgent. ! !

!HumScribe methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 8/13/2014 19:51'!
dialogAgentURI	"Returns an instance of HumDialogAgent."	^dialogAgentURI! !

!HumScribe methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 8/13/2014 19:51'!
dialogAgentURI: aHumDialogAgentURI 	self assert: (aHumDialogAgentURI isKindOf: String).	dialogAgentURI := aHumDialogAgentURI.! !

!HumScribe methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 8/13/2014 13:52'!
zdialogAgent: aHumDialogAgent 	self assert: (aHumDialogAgent isKindOf: HumDialogAgent).	dialogAgent := aHumDialogAgent. ! !


!HumScribe methodsFor: 'user interface' stamp: 'RichardAlexanderGreen 9/7/2014 16:09'!
handleHttpPostRequest: aHumHttpRequest 	"The scribe handles the post request by 	. placing data on a HumDataFrame	. and returning the data frame as a completion of the 'Ask viewName' task.	TODO: Eventually, this should be in a subtype 	      because we will probably also have XMPP, and virtual world interfaces.	"	| calc |	calc := HumCalculator new.	self assert: (aHumHttpRequest isKindOf: HumHttpRequest).	aHumHttpRequest		fields 			keysAndValuesDo: [:key :value |  				| entityName attributeName |				entityName := calc given: key extractUpto: ':'.				attributeName := calc given: key extractAfter: ':'.				"Put the data on my blackboard. 				 It will be sent back to caller in job-completion message. "			  (self blackboard) setEntityName: entityName attribute: attributeName toValue: value.			  ].	"I am ready to send data back to the dialog agent 	 that delegated 'Ask viewName.' task to me."	self askViewCompleted.  	! !


!HumScribe methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/8/2014 09:52'!
askViewCompleted	"Inform caller that the 'Ask viewName' task 	 that was delegated from dialog agent (caller)	 to scribe (this instance) has been completed."	| |	"Skip this if there was no dialog caller."	instructionInProgress ifNil: [^self].	"Get current task context and send task complete message."	self completedInstruction: instructionInProgress inRole: 'Scribe' onJob: jobID. 		! !

!HumScribe methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 8/30/2014 09:58'!
clientSays: aString 	"After a client sensor input is interpreted,	 this method is called with the equivalent speech act input.	The Scribe (me) then passes this to the dialog agent to stimulate a system response.	"	| vignette  |	(self stepLog) add: ('U: ', aString).	vignette := self sendToDialogAgent: aString.	self assert: (vignette isKindOf: HumFrame4Vignette ).	(vignette responseLines)		do: [:line |			(self stepLog) add: 'S: ', line source.			].	^vignette.	! !

!HumScribe methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/17/2014 11:13'!
runAction: anAction inRole: aRole onJob: aHumJobTicket	"Over-rise HumActor to handle Scribe actions."	self assert: ( aRole sameAs: 'scribe' ).	self runInstruction: anAction inRole: aRole onJob: aHumJobTicket.! !

!HumScribe methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/7/2014 21:27'!
runInstruction: anInstruction inRole: aRole onJob: aJobID	"Override the HumActor -- (Why?)"	| source |	"We cannot accept statement strings here because we need noun values."	self assert: ( anInstruction isKindOf: HumInstructionLine ).	instructionInProgress := anInstruction "statement".	jobID := aJobID.	"We are expecting 'Ask viewName.' or 'Show viewName.'"	source := instructionInProgress statement source.	( source beginsWith: 'Ask ')		ifTrue: [ "Send an active form for the given view to the attached client interface."			| ontology viewFrame html aHumHttpRequest |			ontology := self configuration ontology.			viewFrame := ontology getViewFrame: (HumCalculator given: source extractBetween: 'Ask ' and: '.' ).			self assert: (viewFrame isKindOf: HumFrame4View).			html := ontology codeGenerator generateHTMLforMarkupLines: (viewFrame frameLines) blackboard: (self blackboard).			self assert: (html size > 0) description: 'No HTML was produced!!'.			aHumHttpRequest := HumHttpRequest new.			self handleHttpPostRequest: aHumHttpRequest. 			].					! !

!HumScribe methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 8/17/2014 20:12'!
sendToDialogAgent: aClientSpeechString 	"Send the string to my Dialog Agent."	| myAgent vignette |	myAgent := self dialogAgent.	vignette := myAgent clientSays: aClientSpeechString.	^vignette.				! !

!HumScribe methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 8/13/2014 13:42'!
systemSays: aString 	"The Dialog Agent has responded with this String.	Implementations will display the response via the client/user interface.	But this (supertype) only logs the response for test-ability.	"	(self stepLog) add: 'System: ', aString.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumScribe class' category: #'Hum-RunTime'!
HumScribe class
	instanceVariableNames: ''!

!HumScribe class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 8/13/2014 20:11'!
dialogAgent: aHumDialogAgent	"Create an instance attached to the given Dialog Agent."	"TODO: REFACTOR. A Scribe is attached to an application.	The application instantiates the scribe.	The scribe can only initiate a dialog after the client is identified."	| instance |	instance := self basicNew.	instance dialogAgent: aHumDialogAgent;		roles: #('scribe').	^instance.! !


!classDefinition: #HumSimulator category: #'Hum-RunTime'!
HumConfiguration subclass: #HumSimulator
	instanceVariableNames: 'dialogSequence startingIntervalDistribution numberOfDialogs simulatedClockSecond queue dialogAgents log4Dialog clientScribes'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumSimulator commentStamp: 'RichardAlexanderGreen 8/13/2014 12:08' prior: 0!
Features:"The Simulator provides the means for 'regression testing'.	Hum dialogs / protocols may be exercised by sending a series of messages to one or more Dialog Agents.	Hum plans are initiated via such dialogs.	Evidence of execution may be found via the Bookkeeper, Messenger logs, and Agent logs.	""Simulations 'load' the system under test by starting dialog sequences 	. at random intervals as seen by the simulated clock.	==> We need a way to represent dialog sequences.	==> We need a way to represent random intervals.	==> We need a way to identify the number of dialogs to be run simultaneously.	==> Ideally, we will run the dialogs in independent threads.	""A simulation loads 'events' into a time-sorted queue and sends the events asynchronously.	. Agent/Actors respond to events by adding events of their own to the queue. 	. The timestamp on each event indicates its order, 	. . but does not determine the real-time duration of the simulation.	. There is no need to create real-time wait-times during the simulation.	""The simulator emulates a human response rate 	. of approximating 1 keystroke (or button press) per second of simulated clock time.	. It is not necessary to simulate the sensor, just the time between vignette inputs.	"Design Questions:"Q: Should the simulator act like a Scribe, or should it work through Scribes?	. In a TDD context, we will sometimes need to verify Scribe features.	. But a Simulator seems like over-kill for that purpose. (A set of Test Cases should do.)"	!


!HumSimulator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/15/2014 09:41'!
buildDialogAgent	"Build a dialog agent configured for our simulation."	| clientAgent clientID myURI clientURI aHumConfiguration |	clientAgent := HumActor dialogID: clientID uri: myURI client: clientURI configuration: self.	^clientAgent. ! !

!HumSimulator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 8/11/2014 11:17'!
buildDialogAgentNamed: clientID	"Build a dialog agent configured for our simulation."	| clientAgent myURI clientURI aHumConfiguration |	myURI := 'URI:DialogAgent.', clientID.	clientURI := 'URI:client.', clientID.	clientAgent := HumActor dialogID: clientID uri: myURI client: clientURI configuration: self.	(self dialogAgents) at: clientID put: clientAgent.	^clientAgent. ! !

!HumSimulator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 8/13/2014 14:36'!
clientScribes	^clientScribes ifNil: [ clientScribes := Dictionary new.]! !

!HumSimulator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/15/2014 09:36'!
dialogAgents	^ dialogAgents ifNil: [ dialogAgents := Dictionary new ].! !

!HumSimulator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/2/2014 10:07'!
dialogSequence: anArrayOfString 	"Identify the sequence of dialog responses to be sent during this simulation."	dialogSequence := anArrayOfString ! !

!HumSimulator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 8/17/2014 20:13'!
getDialogAgentNamed: aClientID 	| clientAgent |	self assert: ( aClientID isKindOf: String ).	clientAgent := (self dialogAgents) at: aClientID ifAbsent: [self buildDialogAgentNamed: aClientID ].	^clientAgent.! !

!HumSimulator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 8/17/2014 19:54'!
getScribeForClient: aClientID 	"Get the Scribe instance corresponding to the client ID."	| scribe |	scribe :=	(self clientScribes) at: aClientID 		                        ifAbsent: [ scribe := HumScribe configuration: self.			                                  scribe id: aClientID. 			                                 (self clientScribes) at: aClientID put: scribe. ].	^scribe! !

!HumSimulator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/14/2014 13:56'!
initialize	| messenger |	messenger := HumMessenger new.	messenger clock: self.	self messenger: messenger.	"Use factory methods to build singleton accomplices"	self messengerID: 'SimMessenger' dispatcherID: 'SimDispatcher' bookkeeperID: 'SimBookkeeper' worldbaseID: 'SimWorldBase'.	"self dispatcher: (HumActor dispatcherID: 'SimDispatcherID' uri: 'SimDispatcherURI' configuration: self)."  self dispatcherID: 'SimDispatcherID'.  	"self bookkeeper: (HumActor bookkeeperID: 'SimBookkeeperID' uri: 'SimBookkeeperURI' configuration: self)."	self bookkeeperID: 'SimBookkeeperID'.	"self worldBase: (HumWorldBase openWorldBase: 'SimWorldBase')."	self worldbaseID: 'SimWorldBaseID'.! !

!HumSimulator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/16/2014 11:29'!
log4Dialog	^ log4Dialog ifNil: [ log4Dialog := OrderedCollection new. ].! !

!HumSimulator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/10/2014 20:30'!
now: aDuration 	simulatedClockSecond := aDuration! !

!HumSimulator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/2/2014 10:06'!
numberOfDialogs: aSmallInteger 	"How many dialogs are to be run simulataneously?"	numberOfDialogs := aSmallInteger 	! !

!HumSimulator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/2/2014 18:01'!
queue	^ queue 			ifNil: [ queue := SortedCollection sortBlock: [:a :b | (a at: 1) < (b at: 1)] ].! !

!HumSimulator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/2/2014 10:01'!
randomStartingIntervals: aDistribution		"Express the distribution as an S-curve in seconds."		self assert: (aDistribution isKindOf: Dictionary).		startingIntervalDistribution := aDistribution.		! !

!HumSimulator methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/2/2014 17:59'!
simulatedClockSecond	^ simulatedClockSecond ifNil: [simulatedClockSecond := 0 seconds].! !


!HumSimulator methodsFor: 'events-registering' stamp: 'RichardAlexanderGreen 9/22/2014 17:13'!
after: aDuration sendSpeech: aString from: aClientID 	"Put this event into my queue."	| |	(self queue) add: { aDuration. #speech. aClientID. aString. }.	! !


!HumSimulator methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 9/22/2014 17:48'!
step	"Send all events with timing that matches the top event."	| readyEvents remainingEvents whenNow  |	"If the queue is empty, do nothing."	whenNow := (self queue at: 1) at: 1.	"Update my clock."	self now: whenNow.	"Pull the events for this clock-time from the queue."	readyEvents     := (self queue) select: [:event | (event at: 1) = whenNow ].	remainingEvents := (self queue) reject: [:event | (event at: 1) = whenNow ].	queue := remainingEvents.	"Send those events"	readyEvents do: [:event | "For each event scheduled at this time."    | eventType clientID speechString scribe dialogVignette |		eventType := event at: 2.  clientID := event at: 3.  speechString := event at: 4.		"Someday we will have more than one type of event. But, currently, we just do speech events."		self assert: (eventType = #speech ).		scribe := self getScribeForClient: clientID.		dialogVignette := scribe clientSays: speechString. 		self assert: ( dialogVignette isKindOf: HumFrame4Vignette ).		self logDialogWhen: whenNow who: clientID why: speechString what: dialogVignette.		"TODO: And then what? . . ."		(dialogVignette instructionLines)			do: [ :instruction |				(instruction role = 'Goal')					ifTrue: ["Fork a process to run the goal."						| process coordinator runParallel |						coordinator := HumActor coordinatorID: 'coordinatorID' 						                                  uri: 'coordinatorURI' 						                                 goal: (instruction statement source) 						                               dialog: (self getDialogAgentNamed: clientID) 						                        configuration: self. 						process := [  													coordinator checkIn.							coordinator runPlan.							"Note: At this point, coordinator job ticket has charges for this goal."							].						"For initial debug: we will just run it, not fork it."						runParallel := false. 						"debug ifTrue: [Transcript cr; show: 'HumSimulator runing: ', instruction asString]."						runParallel ifTrue: [process value. ] ifFalse: [process fork.].						].							].			].	! !

!HumSimulator methodsFor: 'events-triggering' stamp: 'RichardAlexanderGreen 8/20/2014 11:58'!
stepUntilDone	[ self queue notEmpty ]		whileTrue: [ self step. ]! !


!HumSimulator methodsFor: 'as yet unclassified' stamp: 'RichardAlexanderGreen 7/10/2014 20:30'!
now	^ self simulatedClockSecond.! !


!HumSimulator methodsFor: 'logging' stamp: 'RichardAlexanderGreen 7/16/2014 11:13'!
logDialogWhen: aDuration who: aClientID why: clientSaid what: systemSaid	(self log4Dialog) add: { aDuration. aClientID. clientSaid. systemSaid. }.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumSimulator class' category: #'Hum-RunTime'!
HumSimulator class
	instanceVariableNames: ''!

!HumSimulator class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 7/15/2014 10:08'!
ontology: aHumOntology 	| instance |	instance := self basicNew.	instance ontology: aHumOntology.	instance initialize.	^instance.! !


!classDefinition: #HumText category: #'Hum-RunTime'!
Object subclass: #HumText
	instanceVariableNames: 'string lines'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumText commentStamp: 'RichardAlexanderGreen 10/14/2014 13:11' prior: 0!
HumText models a text.Text is multi-line and potentially enhanced with color, emphasis, fonts, and font weights.( Also known as "Attributed String" )The immediate intent is to support a code editor and rich text without going "over-board".See: HumTextPrettyToken.*** TODO: The current implementation is far from complete. ***Note: Text updates are primarily implemented via HumEditor.Instance Variables:	string	< String >	lines	< OrderedCollection of HumTextLine >!


!HumText methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/13/2014 19:25'!
= anotherHumText	"Does this text have same content as the other"	| isSame |	isSame := (self name) = (anotherHumText name).	^isSame.! !

!HumText methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/17/2014 09:11'!
addLine: aString 	"Append given line at bottom of text."	| newLine tempLines |	self assert: ( aString isKindOf: String ).	newLine := HumTextLine new.	newLine string: aString.	tempLines := self lines.	((tempLines size = 1) and: [( tempLines at: 1) string isEmpty])		ifTrue: [tempLines := OrderedCollection new. ].	tempLines add: newLine.	self lines: tempLines.	self changed: self.! !

!HumText methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/13/2014 18:35'!
copy	| newInstance newLines|	newInstance := self class new.	newLines := self lines class new.	self lines do: [:line | newLines add: (line copy) ].	newInstance lines: newLines.	^newInstance.! !

!HumText methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/14/2014 12:13'!
insertEmptyLineAfter: lineIndex 	| currentLines tempLines |	currentLines := self lines.	tempLines := currentLines copyFrom: 1 to: lineIndex.	tempLines add: ( HumTextLine new).	(lineIndex < currentLines size )		ifTrue: [ tempLines addAll: ( currentLines copyFrom: ( lineIndex + 1 ) to:  currentLines size ). ].	"Note: Following will call self changed."		self lines: tempLines.! !

!HumText methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/13/2014 12:05'!
lines	"Return the HumText list of  lines"	lines 		ifNil: [ "initialize the list"			lines := OrderedCollection new. 			lines add: ( HumTextLine new ). "NOTE: never empty"			].	^lines. ! !

!HumText methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/17/2014 09:07'!
lines: anOrderedCollection 	( anOrderedCollection isKindOf:  OrderedCollection )		ifFalse: [ Error signal: 'Bad value sent to HumText>>lines: _']		ifTrue: [ |firstElement| firstElement := anOrderedCollection at: 1.			(firstElement isKindOf: HumTextLine) 			ifFalse: [ Error signal: 'First line should be a HumTextLine'] 			].	lines := anOrderedCollection.	self changed: self.! !

!HumText methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/13/2014 18:55'!
printOn: aStream	"Append to the argument, aStream, a sequence of characters that  	identifies the receiver."	| title s |	title := self class name.	s := title, ':'.	lines do: [ :line | s := s, line string, '/'.].	aStream		nextPutAll: (title first isVowel ifTrue: ['an '] ifFalse: ['a ']);		nextPutAll: s! !

!HumText methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/13/2014 11:45'!
string	"Return self as a string. (Lines with CR inserted as needed.)"	| result |	result := String new.	( self lines )		do: [ :line |			result := result, line string, String cr.			].	^result.! !


!classDefinition: #HumTextLine category: #'Hum-RunTime'!
Object subclass: #HumTextLine
	instanceVariableNames: 'string indentLevel'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumTextLine commentStamp: 'RichardAlexanderGreen 3/12/2013 11:35' prior: 0!
A text is assumed have a collection of text-lines.Each text line is assumed to be a collection of tokens.Each token may have attributes that affect how it is rendered.For example, rendering attributes may include emphasis, color, highlight, link, editable.  (ToDo)Emphasis in turn might include isBold, isItalic, isUnderlined, relative height. (ToDo)Note -- Lines might be re-flowed during the rendering if the context permits / requires it.But the source lines in the text remain the same regardless of the rendering.We don't want to surprise the author by changing the source.(TODO: There is some conceptual conflict here that I have to resolve.)Instance Variables:	string	<String>	indentLevel	<Integer>!


!HumTextLine methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/13/2014 11:35'!
copy	| newInstance |	newInstance := self class new.	newInstance		indentLevel: (self indentLevel copy);		string: (self string copy).	^newInstance.! !

!HumTextLine methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/31/2012 20:54'!
indentLevel	"The indent level indicates the level of indentation,	  but not the rendering of the indentation."	^ indentLevel ifNil: [ indentLevel := 0 ].! !

!HumTextLine methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/31/2012 20:53'!
indentLevel: aSmallInteger	indentLevel := aSmallInteger.! !

!HumTextLine methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/8/2014 23:16'!
size	^ self string size! !

!HumTextLine methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/30/2012 17:51'!
string	string ifNil: [ string := String new. ].	^string.! !

!HumTextLine methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/30/2012 18:21'!
string: aByteString 	string := aByteString! !


!classDefinition: #HumTextToken category: #'Hum-RunTime'!
ProtoObject subclass: #HumTextToken
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumTextToken commentStamp: 'RichardAlexanderGreen 1/20/2014 10:44' prior: 0!
A text is assumed have a collection of text-lines.Each text line is assumed to be a collection of tokens.Each token may have parameters that affect how it is rendered.Rendering parameters include emphasis, color, highlight, font, relative height, and behavior.Emphasis  parameters include isBold, isItalic, isUnderlined. Behavior  parameters include link, edtable.Note: This design does NOT encourage renderings that change mid-word. For example: It will require some trick to underline or bold part of a word and not the whole word.The trick could be a "no-space" token that serves to separate the parts of a "word" with partial word rendering.!



!classDefinition: #HumVM category: #'Hum-RunTime'!
Object subclass: #HumVM
	instanceVariableNames: 'slots transferVector measure'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumVM commentStamp: 'RichardAlexanderGreen 9/20/2012 07:57' prior: 0!
HumVM is a thought experiment for a virtural machine and byte code.After some consideration, I (Richard Alexander Green) decided that a byte code is not a good idea at this time.If compiled code is necessary for efficiency, it would make more sense at this time to translate to a language that has a compiler. Byte Code Advantages:- The resulting code may be more compact than the source and therefore it would require less delivery time.- - counter: Delivery time for an agent`s code is generally not an important factor except possibly for a dialog agent.- A byte code might be more easily compiled to a native ISA.- - counter: It is easier to translate to another language.Disadvantages:- If the normal delivery is byte code the ecology may discourage transparency.- An existing VM such as JVM or BEAM would be more acceptable to many audiences.Instance Variables:	slots	<Dictionary>	transferVector	<Dictionary>	measure	<HumMeasure>!


!HumVM methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/26/2012 10:30'!
measureRegister	^ measure ifNil: [ measure := HumMeasure new. ].! !

!HumVM methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/26/2012 10:10'!
setSlot: slotIndex to: aHumObject 	(self slots) at: slotIndex put: aHumObject.! !

!HumVM methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/26/2012 10:11'!
slots	"slots allow objects to be referenced by byte-code indices."	^ slots ifNil: [slots := Dictionary new. ].! !

!HumVM methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/26/2012 10:39'!
transferVector	transferVector ifNil: [ transferVector := Dictionary new.		transferVector 			at: 001 put: [ :x | measure := x  ];			at: 002 put: [ :x | measure := measure + x ];			at: 003 put: [ :x | measure := measure - x ];			at: 000 put: [ :x | self halt ].		].	^transferVector.! !


!HumVM methodsFor: 'self evaluating' stamp: 'RichardAlexanderGreen 6/20/2013 09:41'!
runInstruction: aHumInstruction 	| microCode |	"Get the microCode. (a block)"	microCode := ( self transferVector ) at: (aHumInstruction operation) 	                                                     ifAbsent: [ Error signal: 'No such opCode: ', (aHumInstruction operation)].	"Run the microCode. (a block)"	microCode value: ( self slots at: (aHumInstruction operand)).	"Assure cascade."	^self. ! !


!classDefinition: #HumVMInstruction category: #'Hum-RunTime'!
Object subclass: #HumVMInstruction
	instanceVariableNames: 'operation operand'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumVMInstruction commentStamp: 'RichardAlexanderGreen 9/20/2012 07:59' prior: 0!
HumVM and HumVMInstruction are artifacts of a thought experiment for a virtural machine and byte code.See the HumVM class comment for further information.Instance Variables:	operation	<Integer>	operand	<Integer>Class Instance Variables:	codeNames	<Dictionary>!


!HumVMInstruction methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/24/2012 16:12'!
operand	^ operand ifNil: [ Error signal: 'operand not set in HumInstruction'.  operand := 000].! !

!HumVMInstruction methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/24/2012 16:10'!
operand: objectIndex 	operand := objectIndex! !

!HumVMInstruction methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/24/2012 16:11'!
operation	^ operation ifNil: [ Error signal: 'op code not set in HumInstruction'.  operation := 000].! !

!HumVMInstruction methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/24/2012 16:09'!
operation: opCode 	self assert: ( opCode < 256 ).	self assert: ( opCode >= 0 ).	operation := opCode.! !


!HumVMInstruction methodsFor: 'associating' stamp: 'RichardAlexanderGreen 9/20/2012 07:37'!
opCodeName	| name |	name := ( HumVMInstruction codeNames ) at: (self operation) ifAbsent: ['Unknown'].	^name.! !

!HumVMInstruction methodsFor: 'associating' stamp: 'RichardAlexanderGreen 7/25/2012 10:18'!
slotName	( (self operand) = 000 ) ifTrue: [^ 'None' ].	Error signal: 'Instruction slot name is not defined.'.	^'Undefined.'! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumVMInstruction class' category: #'Hum-RunTime'!
HumVMInstruction class
	instanceVariableNames: 'codeNames'!

!HumVMInstruction class methodsFor: 'instance creation' stamp: 'RichardAlexanderGreen 7/24/2012 16:27'!
opCode: opCode value: objectIndex 	| instruction |	instruction := self basicNew.	instruction operation: opCode.	instruction operand: objectIndex.	^instruction.! !


!HumVMInstruction class methodsFor: 'associating' stamp: 'RichardAlexanderGreen 7/24/2012 16:26'!
opCodeName	name := (self codeNames ) at: (self operation).	^name.! !


!HumVMInstruction class methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/24/2012 16:33'!
codeNames	codeNames ifNotNil: [ ^codeNames ].	"Otherwise, initialize . . ."	codeNames := Dictionary new.	codeNames at: 000 put: 'Halt'.! !


!classDefinition: #HumVector category: #'Hum-RunTime'!
FloatArray variableWordSubclass: #HumVector
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumVector commentStamp: 'RichardAlexanderGreen 4/26/2013 14:23' prior: 0!
A vector to be used in geometry and Physics. Also implements functional programming concepts that enable cascading operations on large arrays.Extends FloatArray.Uses FloatArray dot: for dot product.Adds cross product:The three scalar components of the vector s=s1i+s2j+s3k = u×v are:s1 = u2*v3 - u3*v2s2 = u3*v1 - u1*v3s3 = u1*v2 - u2*v1!


!HumVector methodsFor: 'as yet unclassified' stamp: 'RichardAlexanderGreen 4/26/2013 14:49'!
cross: v	"Return the 3-dimensional vector cross product U x V	where U is self and V is the argument.	The three scalar components 		of the vector s=s1i+s2j+s3k = u×v 		are:			s1 = u2*v3 - u3*v2			s2 = u3*v1 - u1*v3			s3 = u1*v2 - u2*v1	"	| u s |	self assert: ( self size = 3 ).	self assert: ( v size = 3 ).	u := self copy.	s := self class ofSize: 3.	s at: 1 put: ((u at: 2)*(v at: 3)) - ((u at: 3)*(v at: 2)).	s at: 2 put: ((u at: 3)*(v at: 1)) - ((u at: 1)*(v at: 3)).	s at: 3 put: ((u at: 1)*(v at: 2)) - ((u at: 2)*(v at: 1)).	^s.		! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumVector class' category: #'Hum-RunTime'!
HumVector class
	instanceVariableNames: ''!

!HumVector class methodsFor: 'as yet unclassified' stamp: 'RichardAlexanderGreen 4/26/2013 15:12'!
ones: n	"Create a unit vector (all ones) of given size"	| v  |	v := self new: n withAll: 1.0.	^v.! !

!HumVector class methodsFor: 'as yet unclassified' stamp: 'RichardAlexanderGreen 4/26/2013 15:17'!
zero: n	"Create a unit vector (all ones) of given size"	| v  |	v := self new: n withAll: 0.0.	^v.! !


!classDefinition: #HumWorldBase category: #'Hum-RunTime'!
HumActor subclass: #HumWorldBase
	instanceVariableNames: 'title quads history priorID'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-RunTime'!
!HumWorldBase commentStamp: 'RichardAlexanderGreen 9/7/2014 12:37' prior: 0!
The world base is a data base for a "world".Typically, a "world" is an enterprise.But, it could be a game or a simulation.A world base is a temporal database.All stored values are versioned.For an entity, each stored attribute has a value and a time-span.The time-span, in turn, has two event-stamps corresponding to the event which populated or updated the value and the event which changed the value.A world base entry is a quad (4-tuple) of pointers:. ( entity, attribute, value, time-span ).Entity Schema:. Entity has attributes.. Attribute has value and time-span.. Time-span has start-event, stop-event.Event Schema:. Event has client, portal, context, date-time.. . . . . . . who . where . . why . . . when (what is the data affected). Client has identifier, client-type, credentials, ongoing-dialog.. Client-type categories include person, robot.. Context has job, ontology, frame, statement.Configuration:- A worldbase is known to a messenger. But it does not need to know any other actors.!


!HumWorldBase methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/24/2014 09:49'!
getEntityID: entityID attribute: attributeType 	" Get requested value (if any) from the world base instance "	| valueAndTau value tau |	self assert: (entityID isKindOf: HumIdentifier ).	self assert: (attributeType asSymbol isKindOf: Symbol ).		valueAndTau := (self quads ) at: ( entityID -> attributeType ) ifAbsent: [ ^nil ].	value := valueAndTau at: 1.	tau := valueAndTau at: 2.	^ value.! !

!HumWorldBase methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 7/24/2013 10:55'!
history	^ history ifNil: [ history := Dictionary new. ].! !

!HumWorldBase methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 4/21/2014 18:51'!
initialize	priorID := #( 0 0 0 ).! !

!HumWorldBase methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/18/2012 07:37'!
quads	^ quads ifNil: [ quads := Dictionary new. ].! !

!HumWorldBase methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/19/2014 11:53'!
setEntityID: entityID attribute: attributeType toValue: aValue	" Get requested value (if any) from the world base instance "	| tau priorValueTau |	self assert: (entityID isKindOf: HumIdentifier ).	"self assert: (attributeType asSymbol isKindOf: Symbol )."	self assert: ( aValue notNil ).	tau := Time primSecondsClock. "seconds since 00:00 on 1 Jan 1901"	"If there is a different prior value, archive in history."	priorValueTau := ( self quads ) at: ( entityID -> attributeType ) ifAbsent: [].	(( priorValueTau notNil ) and: [ ((priorValueTau at: 1) = aValue) not ] )		ifTrue: [ | historyKey |			historyKey :=	{ entityID. attributeType. (priorValueTau at: 2) }.			(self history) at: historyKey put: (priorValueTau at: 1).			].	"Put value of entity attribute and the timestamp."	( self quads ) at: ( entityID -> attributeType ) put: { aValue. tau. }.	! !

!HumWorldBase methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/12/2012 10:32'!
title	^ title ifNil: [ Error signal: 'A world base instance must have a title.'].! !

!HumWorldBase methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 10/12/2012 10:34'!
title: aWorldBaseName 	self assert: ( aWorldBaseName isKindOf: String ).	title := aWorldBaseName.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'HumWorldBase class' category: #'Hum-RunTime'!
HumWorldBase class
	instanceVariableNames: ''!

!HumWorldBase class methodsFor: 'accessing instances and variables' stamp: 'RichardAlexanderGreen 9/7/2014 12:32'!
openWorldBase: aWorldBaseName	"Open the world base instance with the given name.	If it does not already exist, create a new instance." 	"TODO: Should a world base be an actor or configuration? 	If not, how do we communicate with a remote world base?"	| instance |	self assert: ( aWorldBaseName isKindOf: String ).	instance := self new.	instance title: aWorldBaseName.	^instance.! !
