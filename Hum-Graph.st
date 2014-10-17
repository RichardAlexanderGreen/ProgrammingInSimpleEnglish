!classDefinition: #HumGraph category: #'Hum-Graph'!
Object subclass: #HumGraph
	instanceVariableNames: 'connectionLabels nodeLabels'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-Graph'!

!HumGraph methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/22/2013 19:32'!
addConnection: anAssociation 	self addConnection: anAssociation label: 'unknown'.! !

!HumGraph methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/22/2013 19:36'!
addConnection: anAssociation label: aString	( self connections ) add: anAssociation.	( self connectionLabels ) add: { aString. anAssociation.  }.! !

!HumGraph methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/22/2013 19:35'!
addNode: anObject 	"Add the given object to the set of nodes"	" Note that each object / node is unique"	self addNode: anObject label: 'unknown'.! !

!HumGraph methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/22/2013 19:36'!
addNode: anObject label: aString	"Add the given object to the set of nodes"	" Note that each object / node is unique"	( self nodeLabels ) add: { aString. anObject. }! !

!HumGraph methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/22/2013 19:18'!
connectionLabels	^ connectionLabels ifNil: [ connectionLabels := Set new ].! !

!HumGraph methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/22/2013 19:37'!
connections	"Return the connections (associations) in this graph."	| bagConnections |	bagConnections := Bag new.	(self connectionLabels)		do: [ :entry |			"entry looks like {  label. association. }"			bagConnections add: (entry at: 2 ).			].	^bagConnections.! !

!HumGraph methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/22/2013 19:38'!
nodeLabels	^nodeLabels ifNil: [ nodeLabels := Set new ].! !

!HumGraph methodsFor: 'accessing' stamp: 'RichardAlexanderGreen 9/22/2013 19:45'!
nodes	"Return the nodes in this graph."	| bagNodes |	bagNodes := Bag new.	(self nodeLabels)		do: [ :entry |			"entry looks like {  label. object. }"			bagNodes add: (entry at: 2 ).			].	^bagNodes.! !


!classDefinition: #HumGraphTests category: #'Hum-Graph'!
TestCase subclass: #HumGraphTests
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Hum-Graph'!

!HumGraphTests methodsFor: 'access tests' stamp: 'RichardAlexanderGreen 1/22/2014 17:31'!
test110GraphHasNodes	"A graph has a collection (set) of nodes"	| graph |	graph := HumGraph new.	self assert: ( graph nodes isEmpty ).! !

!HumGraphTests methodsFor: 'access tests' stamp: 'RichardAlexanderGreen 1/22/2014 17:31'!
test120GraphHasConnections	"A graph has a collection (set) of nodes"	| graph |	graph := HumGraph new.	self assert: ( graph connections isEmpty ).! !

!HumGraphTests methodsFor: 'access tests' stamp: 'RichardAlexanderGreen 1/22/2014 17:31'!
test130PutGetNode	"A graph has a collection (set) of nodes"	| graph node node2 |	graph := HumGraph new.	self assert: ( graph nodes isEmpty ).		node := 'My content just happens to be a string but I could be any kind of object'.	graph addNode: node.	self assert: ( graph nodes size = 1 ).		graph nodes do: [ :entry | self assert: (entry == node )].! !

!HumGraphTests methodsFor: 'access tests' stamp: 'RichardAlexanderGreen 1/22/2014 17:31'!
test140PutGetConnector	"A graph has a collection (set) of nodes"	| graph node node2 |	graph := HumGraph new.	self assert: ( graph nodes isEmpty ).		node := 'My content just happens to be a string but I could be any kind of object'.	graph addNode: node.	self assert: ( graph nodes size = 1 ).		node2 := 'My content also just happens to be a string but I could be any kind of object'.	graph addNode: node2.	self assert: ( graph nodes size = 2 ).		graph addConnection: ( node -> node2 ).	self assert: ( graph connections size = 1 ).! !

!HumGraphTests methodsFor: 'access tests' stamp: 'RichardAlexanderGreen 1/22/2014 17:31'!
test150PutGetLabeledConnections	"A graph has a collection (set) of nodes"	| graph nodeA nodeB |	graph := HumGraph new.	self assert: ( graph nodes isEmpty ).		nodeA := 'My content just happens to be a string but I could be any kind of object'.	graph addNode: nodeA.	self assert: ( graph nodes size = 1 ).		nodeB := 'My content also just happens to be a string but I could be any kind of object'.	graph addNode: nodeB.	self assert: ( graph nodes size = 2 ).		graph addConnection: ( nodeA -> nodeB ) label: 'A to B'.	self assert: ( graph connections size = 1 ).		graph addConnection: ( nodeB -> nodeA ) label: 'B to A'.	self assert: ( graph connections size = 2 ).		graph addConnection: ( nodeA -> nodeB ) label: 'A to B again'.	self assert: ( graph connections size = 3 ).! !
