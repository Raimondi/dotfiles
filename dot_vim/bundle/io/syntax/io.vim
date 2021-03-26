" Vim Syntax File
" Language:     Io
" Creator:      Scott Dunlop <swdunlop@verizon.net>
" Fixes:        Manpreet Singh <junkblocker@yahoo.com>
"               Jonathan Wright <quaggy@gmail.com>
"               Erik Garrison <erik.garrison@gmail.com>
"
" Packaging:    Andrei Maxim <andrei@andreimaxim.ro>
" Last Change:  2013 Dec 11
" Configuration:
"
"  "g:io_syntax_hl_all_protos"  When 0 only highlight prototypes listed here.
"                               When 1 (default) highlight all prototypes.
"
"  "g:io_syntax_hl_all_methods" When 0 only highlight methods listed here.
"                               When 1 (default) highlight all methods.

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syntax case match

" equivalent to io-mode-prototype-names in io-mode.el
syntax keyword IoProtos Array AudioDevice AudioMixer Block Box Buffer CFunction
syntax keyword IoProtos CGI Color Curses DBM DNSResolver DOConnection DOProxy
syntax keyword IoProtos DOServer Date Directory Duration DynLib Error Exception
syntax keyword IoProtos FFT File Fnmatch Font Future GL GLE GLScissor GLU
syntax keyword IoProtos GLUCylinder GLUQuadric GLUSphere GLUT Host Image Importer
syntax keyword IoProtos LinkList List Lobby Locals MD5 MP3Decoder MP3Encoder Map
syntax keyword IoProtos Message Movie Notification Number Object
syntax keyword IoProtos OpenGL Point Protos Regex SGML SGMLElement SGMLParser SQLite
syntax keyword IoProtos Server ShowMessage SleepyCat SleepyCatCursor Socket
syntax keyword IoProtos Sequence SocketManager Sound Soup Store String Tree UDPSender
syntax keyword IoProtos UPDReceiver URL User Warning WeakLink
syntax keyword IoProtos Random BigNum Sequence

" Object methods
syntax keyword IoMethods activate activeCoroCount actorProcessQueue actorRun
syntax keyword IoMethods addTrait ancestorWithSlot ancestors and appendProto
syntax keyword IoMethods apropos argIsActivationRecord argIsCall asSimpleString
syntax keyword IoMethods asString asyncSend become block break call catch clone
syntax keyword IoMethods cloneWithoutInit collectGarbage compare compileString
syntax keyword IoMethods contextWithSlot continue coroDo coroDoLater coroFor
syntax keyword IoMethods coroWith currentCoro deprecatedWarning do doFile
syntax keyword IoMethods doMessage doRelativeFile doString else elseif evalArg
syntax keyword IoMethods evalArgAndReturnNil evalArgAndReturnSelf exit for
syntax keyword IoMethods foreach foreachSlot forward futureSend
syntax keyword IoMethods getEnvironmentVariable getLocalSlot getSlot
syntax keyword IoMethods handleActorException hasDirtySlot hasLocalSlot hasProto
syntax keyword IoMethods hasSlot if ifError ifFalse ifNil ifNilEval ifNonNil
syntax keyword IoMethods ifNonNilEval ifTrue in init inlineMethod isActivatable
syntax keyword IoMethods isActive isError isIdenticalTo isKindOf isLaunchScript
syntax keyword IoMethods isNil isResumable isTrue justSerialized launchFile
syntax keyword IoMethods lazySlot lexicalDo list loop markClean memorySize
syntax keyword IoMethods message method newSlot not or ownsSlots parent pass
syntax keyword IoMethods pause perform performWithArgList prependProto print
syntax keyword IoMethods println proto protos raise raiseIfError raiseResumable
syntax keyword IoMethods relativeDoFile removeAllProtos removeAllSlots
syntax keyword IoMethods removeProto removeSlot resend resume return
syntax keyword IoMethods returnIfError returnIfNonNil schedulerSleepSeconds self
syntax keyword IoMethods sender serialized serializedSlots
syntax keyword IoMethods serializedSlotsWithNames setIsActivatable setProto
syntax keyword IoMethods setProtos setSchedulerSleepSeconds setSlot
syntax keyword IoMethods setSlotWithType shallowCopy slotDescriptionMap
syntax keyword IoMethods slotNames slotSummary slotValues stopStatus super
syntax keyword IoMethods switch system then thisBlock thisContext
syntax keyword IoMethods thisLocalContext thisMessage try type uniqueHexId
syntax keyword IoMethods uniqueId updateSlot wait while write writeln yield

syntax keyword IoBoolean true false nil

if get(g:, 'io_syntax_hl_all_protos', 1)
  syntax match IoProtos     +\<\u[^ \t=]*\>(\@!+
endif
if get(g:, 'io_syntax_hl_all_methods', 1)
  syntax match IoMethods    +[^ \t()]\+(\@=+
endif
syntax match IoDelimiters +[][{}()]+

syntax match IoOperator +\s\([@?;.]\)\1\?\%([ (]\|\_w\)\@=+
syntax match IoOperator +\s:\{,2}=\%([ (]\|\_w\)\@=+
syntax match IoOperator +\s[<>!=]=\%([ (]\|\_w\)\@=+
syntax match IoOperator +\s[*/<>+-]\%([ (]\|\_w\)\@=+

syntax match IoHexNumber +\<0[xX]\>+ display
syntax match IoHexNumber +\<0[xX]\x\+[lL]\?\>+ display
syntax match IoOctNumber +\<0[oO]\>+ display
syntax match IoOctNumber +\<0[oO]\o\+[lL]\?\>+ display
syntax match IoFloat     +\.\d\+\([eE][+-]\?\d\+\)\?[jJ]\?\>+ display
syntax match IoFloat     +\<\d\+\%(\.\d*\)\?\%([eE][+-]\?\d\+\)\?[jJ]\?\>+ display
syntax match IoNumber    +\<\d\+[lLjJ]\?\>+ display

syntax match IoOctalError "\<0[oO]\o*\O\d*[lL]\=\>" display
syntax match IoHexError   "\<0[xX]\x*\X\+[lL]\=\>" display

syntax region  IoCommentSlash     start=+//+ end=+$+
syntax region  IoCommentHash      start=+#+ end=+$+
syntax region  IoCommentMultiline start=+/\*+ end=+\*/+
syntax keyword IoTodo TODO XXX NOTE FIXME BUG HACK containedin=IoComment.* contained
syntax match   IoCommentTitle -\%(^\|/[/*]\|#\)\s*\%(\u\w*\s*\)\+:- containedin=IoComment.* contained contains=IoCommentLead
syntax match   IoCommentLead +/[*/]\|#+ contained

syntax region IoSingleString matchgroup=IoStringDelim start=+"+ skip=+\\"+ end=+"+
syntax region IoTripleString matchgroup=IoStringDelim start=+"""+ end=+"""+
syntax region IoInterpolate matchgroup=IoInterpolateDelim start=+#{+ end=+}+ containedin=IoSingleString contains=TOP,IoSingleString,IoTripleString,IoComment.* keepend contained
syntax region IoInterpolate matchgroup=IoInterpolateDelim start=+#{+ end=+}+ containedin=IoTripleString contains=TOP,IoTripleString,IoComment.* keepend contained

highlight link IoProtos           Type
highlight link IoBoolean          Boolean
highlight link IoMethods          Function
highlight link IoSingleString     String
highlight link IoTripleString     String
highlight link IoDelimiters       Delimiter
highlight link IoCommentSlash     Comment
highlight link IoCommentHash      Comment
highlight link IoCommentMultiline Comment
highlight link IoTodo             Todo
highlight link IoCommentLead      Comment
highlight link IoCommentTitle     PreProc
highlight link IoOperator         Operator
highlight link IoInterpolate      Normal
highlight link IoInterpolateDelim Delimiter
highlight link IoHexNumber        Number
highlight link IoOctNumber        Number
highlight link IoNumber           Number
highlight link IoFloat            Float
highlight link IoOctalError       Error
highlight link IoHexError         Error

let b:current_syntax = "io"
" vim: set sw=2 sts=2 et fdm=marker:
