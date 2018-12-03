Class {
	#name : #SRTSolidityFilesProvider,
	#superclass : #Object,
	#instVars : [
		'dictionary',
		'cache'
	],
	#category : #SolidityTestingResources
}

{ #category : #initialization }
SRTSolidityFilesProvider >> at: index [
	^ cache at: index ifAbsentPut: [ (self entries at: index) asFileReference readStream upToEnd ]
]

{ #category : #initialization }
SRTSolidityFilesProvider >> copyFrom: aPosition to: anOtherPosition [
	^ (aPosition to: anOtherPosition) collect: [ :i | self at: i ]
]

{ #category : #initialization }
SRTSolidityFilesProvider >> entries [
	^ (IceRepository registry detect: [ :r | r name = #SolidityTestingResources ]) workingCopy fileSystem / #db
]

{ #category : #initialization }
SRTSolidityFilesProvider >> initialize [
	super initialize. 
	cache := OrderedCollection new.
]

{ #category : #initialization }
SRTSolidityFilesProvider >> readStream [
	^ ReadStream on: self
]

{ #category : #initialization }
SRTSolidityFilesProvider >> size [
	^ self entries size 
]
