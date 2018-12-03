Class {
	#name : #SRTEncoder,
	#superclass : #Object,
	#category : #SolidityTestingResources
}

{ #category : #'as yet unclassified' }
SRTEncoder class >> encodeFile: aFile into: aClass [  
	aClass compile: (self generateBase64Content: aFile) classified: #base64.
	aClass compile: (self generateAccessorContent: aFile) classified: #accessing.


]

{ #category : #'as yet unclassified' }
SRTEncoder class >> generateAccessorContent: aFile [
	^ '
content{1}
	^ (ZnBase64Encoder new decode: self base64{1} ) utf8Decoded.
' format: {(self nameFor: aFile basename)}





]

{ #category : #'as yet unclassified' }
SRTEncoder class >> generateBase64Content: aFile [
	^ '
base64
	^ ''{2}''.
	
'
		format:
			{ self nameFor: aFile basename .
			(ZnBase64Encoder new encode: aFile readStream upToEnd utf8Encoded)}





]

{ #category : #'as yet unclassified' }
SRTEncoder class >> loading [
	| entries instance base64 futures |
	entries := '/Users/sbragagn/git-repositories/ContractsDB/etherscan/' asFileReference
		entries.
	instance := SRTContracts new.
	entries := entries
		reject: [ :e | instance respondsTo: ('content' , (SRTEncoder nameFor: e basename)) asSymbol ].
"	TKTConfiguration runner poolMaxSize: 40."
	base64 := Array new: entries size.
	futures := (1 to: entries size)
		collect: [ :id | 
			[ base64 at: id put: (SRTEncoder generateBase64Content: (entries at: id) asFileReference) ]
				future ].
	base64 do: [ :b | SRTContracts compile: b classified: #base64 ].
	SRTEncoder generateBase64Content: (entries at: 1) asFileReference.
	SRTContracts recompile
]

{ #category : #'as yet unclassified' }
SRTEncoder class >> nameFor: aFileName [
		^( aFileName copyReplaceAll: '0x' with: '' ) copyReplaceAll:'.sol' with:''




]
