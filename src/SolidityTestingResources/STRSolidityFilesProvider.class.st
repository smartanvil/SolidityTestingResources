Class {
	#name : #STRSolidityFilesProvider,
	#superclass : #Object,
	#instVars : [
		'cache'
	],
	#classInstVars : [
		'default'
	],
	#category : #SolidityTestingResources
}

{ #category : #accessing }
STRSolidityFilesProvider class >> default [
	^ default ifNil: [ default := self new ]
]

{ #category : #initialization }
STRSolidityFilesProvider >> at: index [
	^ cache at: index ifAbsentPut: [ (self entries at: index) asFileReference readStream upToEnd ]
]

{ #category : #initialization }
STRSolidityFilesProvider >> copyFrom: aPosition to: anOtherPosition [
	^ (aPosition to: anOtherPosition) collect: [ :i | self at: i ]
]

{ #category : #initialization }
STRSolidityFilesProvider >> entries [
	^ ((IceRepository registry detect: [ :r | r name = #SolidityTestingResources ]) workingCopy fileSystem / #db) entries
]

{ #category : #convenience }
STRSolidityFilesProvider >> generateNexts [
	^ (1 to: self size) 
]

{ #category : #initialization }
STRSolidityFilesProvider >> initialize [
	super initialize. 
	cache := OrderedCollection new.
]

{ #category : #initialization }
STRSolidityFilesProvider >> readStream [
	^ ReadStream on: self
]

{ #category : #initialization }
STRSolidityFilesProvider >> size [
	^ self entries size 
]
