
\version "2.12.3"

\header {
	title = "The Girl in the Drawing"
	subtitle = "From the Durarara!! Soundtrack"
	composer = "Composed by Makoto Yoshimori"
	arranger = \markup \right-column {
		\line {Transcription by Joel Spadin}
		\line \teeny {http://chaosinacan.com}}
}

\include "english.ly"


hideNote = {
	\once \override NoteHead #'transparent = ##t
	\once \override Stem #'transparent = ##t
	\once \override Rest #'transparent = ##t
	\once \override Accidental #'transparent = ##t
	\once \override Dots #'transparent = ##t
}

shift = {
	\override DynamicText #'self-alignment-X = #LEFT
	\override DynamicText #'X-offset = #-2
	\override Hairpin #'X-offset = #-0.8
}

unshift = {
	\revert DynamicText #'self-alignment-X
	\revert DynamicText #'X-offset
	\revert Hairpin #'X-offset
}

shiftY = {
	\override TextSpanner #'Y-offset = #-3
}
unshiftY = {
	\override TextSpanner #'Y-offset = #0
}

longGliss = {
	\once \override Glissando #'minimum-length = #3
	\once \override Glissando #'springs-and-rods = #ly:spanner::set-spacing-rods
}

longerGliss = {
	\once \override Glissando #'minimum-length = #4
	\once \override Glissando #'springs-and-rods = #ly:spanner::set-spacing-rods
}

ritSpan = {
	\override TextSpanner #'(bound-details left text) = \markup { \upright "rit. " }
	\revert TextSpanner #'(bound-details right text)
}

ritATempo = {
	\ritSpan
	\override TextSpanner #'(bound-details right text) = " a tempo"
}

moltoRitATempo = {
	\override TextSpanner #'(bound-details left text) = \markup { \upright "molto rit. " }
	\override TextSpanner #'(bound-details right text) = " a tempo"
}

ritEDim = {
	\override TextSpanner #'(bound-details left text) = \markup { \upright "rit. e dim. " }
	\revert TextSpanner #'(bound-details right text)
	\override TextSpanner #'(bound-details right-broken text) = ##f
}

crescPocoAPoco = {
	\crescTextCresc
	\set crescendoText = \markup { \italic { cresc. poco a poco } }
}

crescNormal = {
	\crescHairpin
}

subp = #(make-dynamic-script
  (markup
	#:hspace 0 #:translate (cons -8 0 )
    #:line( #:normal-text #:italic "sub." #:dynamic "p"))
)

%% vertical space skip
#(define-markup-command (vspace layout props amount) (number?)
  "This produces a invisible object taking vertical space."
  (let ((amount (* amount 3.0)))
    (if (> amount 0)
        (ly:make-stencil "" (cons -1 1) (cons 0 amount))
        (ly:make-stencil "" (cons -1 1) (cons amount amount)))))


KeyA = { \bar "||" \key g \major }
KeyB = { \bar "||" \key e \major }
KeyC = { \bar "||" \key g \major }
KeyD = { \bar "||" \key e \major }
KeyDCoda = { \key e \major }
%coda
KeyE = { \bar "||" \key ef \major }
KeyF = { \bar "||" \key df \major }
KeyG = { \bar "||" \key gf \major }
KeyH = { \bar "||" \key g \major }
KeyI = { \bar "||" \key e \major }
KeyJ = { \bar "||" \key g \major }
KeyK = { \bar "||" \key e \major }
KeyL = { \bar "||" \key ef \major }
KeyM = { \bar "||" \key df \major }
KeyN = { \bar "||" \key gf \major }

tempoRubato = \markup \dir-column {
	\general-align #X #CENTER
	"(Tempo rubato)"
	\general-align #X #CENTER
	\concat { \fontsize #-2 \general-align #Y #DOWN 
		\note #"4" #1 " ≈ 112" }
}

Global = {
	\tempo 4 = 112
	\tempo \tempoRubato
	
	\numericTimeSignature
	\time 3/4
	\key g \major


	#(override-auto-beam-setting '(end 1 8 * *) 1 4)
	#(override-auto-beam-setting '(end 1 8 * *) 2 4)
	#(override-auto-beam-setting '(end 1 8 * *) 3 4)
	#(override-auto-beam-setting '(end 1 12 * *) 1 4)
	#(override-auto-beam-setting '(end 1 12 * *) 2 4)
	#(override-auto-beam-setting '(end 1 12 * *) 3 4)
	\set tupletSpannerDuration = #(ly:make-moment 1 4 )

	\set Staff.printKeyCancellation = ##f
	\override MultiMeasureRest #'expand-limit = #1

	\override Glissando #'(bound-details left padding) = #1.1
	\override Glissando #'(bound-details right padding) = #1.1
	\override Glissando #'thickness = #1.8
	
	\override TextSpanner #'(bound-details left-broken text) = ##f
	\override TextSpanner #'(bound-details left-broken padding) = #3
	\override TextSpanner #'(bound-details right-broken text) = ##f
	\override TextSpanner #'(bound-details right-broken padding) = #1
	
	\override TextSpanner #'(bound-details left stencil-align-dir-y) = #0
	\override TextSpanner #'(bound-details right stencil-align-dir-y) = #0

	%\override TextSpanner #'style = #'dotted-line
	%\override DynamicTextSpanner #'style = #'dotted-line

	%\override TextSpanner #'after-line-breaking = ##t
}


CodaBreak = {
	\cadenzaOn
	\stopStaff
	s2.
	\startStaff
	\cadenzaOff
	
	\bar ""
	\break

	\once \set Staff.explicitKeySignatureVisibility = #end-of-line-invisible
	\once \override Staff.KeySignature #'break-visibility = #end-of-line-invisible
    \once \override Staff.Clef #'break-visibility = #end-of-line-invisible
}

SegnoMark = {
	\once \override Score.RehearsalMark #'font-size = #3
    \mark \markup { \musicglyph #"scripts.segno" }
}

ToCodaMark = {
	\once \override Score.RehearsalMark #'font-size = #2
	\once \override Score.RehearsalMark #'self-alignment-X = #RIGHT
	\mark \markup { \bold "to Coda" \hspace #1 \musicglyph #"scripts.coda" }
}

DSalCoda = {
	\once \override Score.RehearsalMark #'padding = #2
	\once \override Score.RehearsalMark #'font-size = #2
	\once \override Score.RehearsalMark #'break-visibility = #begin-of-line-invisible
    \once \override Score.RehearsalMark #'self-alignment-X = #RIGHT
	\mark \markup { \bold "D.S. al Coda" }
}

CodaMark = {
	\once \override Score.RehearsalMark #'font-size = #3
	\once \override Score.RehearsalMark #'break-visibility = #end-of-line-invisible
    \once \override Score.RehearsalMark #'self-alignment-X = #LEFT
	\mark \markup { \musicglyph #"scripts.coda" }
}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%				START MUSIC				%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


ViolinA = \relative c''' {
	\once \override MultiMeasureRest #'minimum-length = #20
	R2.*4 |
	%5
	\SegnoMark
	g4 fs\glissando( cs) |
	%6
	e d cs | \acciaccatura a8 b2. | a2. |
	gs2. | a2. | bf2. | c2. |
	\override NoteColumn #'ignore-collision = ##t
	<<
		{ \voiceOne cs2.( | e2) d4 | }
		\\
		{ \voiceOne s4 \hideNote b2\glissando | \hideNote e2. | }
	>>
	\revert NoteColumn #'ignore-collision

	%15
	\KeyB
	cs2 r4 | cs,4-> ds es | fs gs a |

	b2 ~ \times 2/3 { \longGliss b4\glissando( gs8) } | e2 r4 |
	%20
	\KeyC
	ef'2. | d2 c4 | b2 c4 | d2. | g,2. |
	c,4 d e | f g a |
	%27
	\KeyD
	b2 ~ \times 2/3 { \longGliss b4\glissando( gs8) } | e2 ~ e8 r |
	%29
	r4 gs cs( | e2.) ~ | e4 ds cs | b2. ~ | b2 \acciaccatura gs8 a4 |
	%33
	\ToCodaMark
	gs2. ~ | gs2. |

	R2. | r2.\fermata
	%39, 38
	\KeyA
	R2.*3 |
	#(define afterGraceFraction (cons 15 16))
	\afterGrace R2. { g'16([ a] \hideNotes a) \unHideNotes }

	\DSalCoda
	\bar "||"

	\CodaBreak
	\CodaMark

}

ViolinDynamicsA = \relative c {

	s2.*4 |
	%5 Segno
	s4^\markup { \dynamic {mp}, \dynamic mf } s2 | s2.*3 |
	s2. | s2.\< | s2.*3 | s2.\> | s2.\! |
	%15
	s2.*5 |
	%20
	s2. |
	\ritATempo
	s2.\startTextSpan | s2.\stopTextSpan | s2.*3 |
	%27
	s2.*7 |
	\ritSpan
	s2.\> | s2.\! | s2.\startTextSpan | s2.\stopTextSpan |
	%38
	s2-\markup { \italic "a tempo" } s4 |
	s2.*3 |
	\CodaBreak
}

PianoTrebleA = \relative c' {
	%1
	R2.*4

	\SegnoMark

	%5
	R2.*10 |
	%15
	\KeyB
	R2.*5 |
	%20
	\KeyC
	R2.*7 |
	%27
	\KeyD
	R2.*3
	%30
	s2. | s2. |
	%32
	R2.*2 |
	%34

	\ToCodaMark

	R2.*4
	\KeyA

	%39, %38
	R2.*4 |

	\DSalCoda

	\bar "||"

	\CodaBreak
	\CodaMark
}

PianoDynamicsA = \relative c {
	s4\p s2 | R2.*3 |
	%5 Segno
	s4^\markup { \dynamic {p}, \dynamic mf } s2 | s2.*3 |
	%9
	s2.*6 |
	%15
	s2.^\markup { \dynamic {mp}, \dynamic mf } | s2.*4 |
	%20
	s2.*2 |
	\ritATempo
	s2.\startTextSpan | s2.\stopTextSpan | s2. |
	%25
	s2.*8 |
	%33
	s2. |
	\ritEDim
	s2.\startTextSpan |
	s2.*2 | s2.\stopTextSpan | s2-\markup { \italic "a tempo" } s4\mf |
	%39
	s2.*3 |
	\CodaBreak
}

PianoBassA = \relative c {
	\times 2/3 {
		%1
		g8_\markup { \italic "with pedal" } d' e  
		\override TupletNumber #'stencil = ##f  b' e, d  b' e, d |
		\override TupletBracket #'bracket-visibility = ##f
		\repeat unfold 3 { g, d' e  b' e, d  b' e, d | }
		%5
		\repeat unfold 2 { g, d' e  b' e, d  b' e, d | }
		\repeat unfold 4 { fs, cs' d  a' d, cs  a' d, cs | }
		%11
		\repeat unfold 2 { g d' e  bf' e, d  bf' e, d | }
		%13
		\repeat unfold 2 { b fs' g  d' g, fs  d' g, fs | }
		%15
		\KeyB
		b, es gs cs gs es cs' gs es |
		as, fs' gs cs gs fs cs' gs fs |
		%17
		a, fs' gs cs gs fs cs' gs fs |
		gs, e' fs b fs e b' fs e |
		%19
		g, d' e bf' e, d bf' e, d |
		\KeyC
		c g' af ef' af, g ef' af, g |
		%21
		f a d fs d a fs' d a |
		fs' d a fs' d a fs' d a |
 		%23
		b, fs' g d' g, fs d' g, fs |
		\repeat unfold 2 { bf, e g c g e c' g e | }
		a, f' g c g f c' g f |
		%27
		\KeyD
		gs, e' fs b fs e b' fs e |
		\repeat unfold 2 { cs fs gs ds' gs, fs ds' gs, fs | }
		%30
		\repeat unfold 2 { fs a b \change Staff=upper gs' b, a gs' b, a \change Staff=lower | }
		%32
		\repeat unfold 2 { b, e fs cs' fs, e cs' fs, e | }
		\repeat unfold 3 { d fs gs cs gs fs cs' gs fs | }
		%37
	}
	d2\fermata r4
	
	\KeyA
	%39, 38 Lead in to DS al coda
	\times 2/3 {
		\repeat unfold 4 { g,8 d' e b' e, d b' e, d | }
	}

	\bar "||"
	\CodaBreak
}




ViolinB = \relative c'' {
	%CODA
	%72, 42
	\KeyDCoda
	gs2. ~ | gs4 a b | cs d e | fs gs a | b cs d ~ |
	%77, 47
	\KeyE
	\appoggiatura d8  ef2 ~ \times 2/3 { ef8 f( ef\glissando } |
	ef,,2.)-> ~ | ef4 f g | af bf c | d e f ~ |
	%82, 52
	\KeyF
	\appoggiatura f8 gf2 ~ \times 2/3 { \longGliss gf4(\glissando ef8) } |
	gf,2.~ | gf4 af bf |  

	\time 4/4
	df gf af bf |
	\time 3/4
	%86, 56
	\KeyG
	\tupletUp
	cf2. ~ | cf4 bf ~ \times 2/3 { bf8 af4 } |
	\tupletNeutral
	gf2. ~ | gf4 gf af | \acciaccatura a8 bf2. ~ | bf2. ~ | bf2. |
	%93, 63
	R2.*5
}

ViolinDynamicsB = \relative c {
	%42
	s2. | s4 s4\< s4 | s2.*3 | s2.\ff |
	%48
	s2.\mf | s4 s4\< s4 | s2.*2 | s2\! s4\> | s2.\!
	\ritATempo
	s4 s2\startTextSpan |
	\time 4/4
	s1 |
	\time 3/4
	%56
	s2.\stopTextSpan | s2.*2 |
	\shiftY
	s2.\startTextSpan | s2.\stopTextSpan |
	%61
	s2.\> | s2. | s2.*4 |
	s2.\startTextSpan | s2\stopTextSpan s4\mf | s2.*9 |
	%78
	\unshiftY
	s2.*6
	%84
	s2 s4\p | s2. | s2.\< | s2.*2 | s2.\! | s4. s4.\mp |
	%91
	\crescPocoAPoco
	s2.\< | s2.*5 | s2.\f | s2. |
	%99
	\crescNormal
	\moltoRitATempo
	\shiftY
	<<
		{ s4 s2\mf\< | s2.*3 | s2.\subp\< }
		{ s2. | s2.*2 | s2.\startTextSpan | s2.\stopTextSpan }
	>> |
	\ritATempo
	s2.\> | s4 s2\< | s2. | s2.\startTextSpan | s\mf\stopTextSpan\> |
	%109
	s2.\! | s4 s2\<
	\time 4/4
	s1\startTextSpan |
	\time 3/4
	s2.\mf\stopTextSpan | s2.*2 | 
	\unshiftY
	s2\startTextSpan s8 s8\stopTextSpan | s2. |
	%117
	s2.\> | s4\! s2 | s2 s4\pp\< | s2 s4\> | s2. | s2.\! |
	\ritSpan
	s2.\startTextSpan | s2.\stopTextSpan
}

PianoTrebleB = \relative c' {
	%CODA
	%72, 42
	\KeyDCoda
	R2.*5 | 
	%77, 47
	\KeyE
	\grace s8
	R2.*5 |
	%82, 52
	\KeyF
	\grace s8
	R2.*3

	\time 4/4
	R1
	\time 3/4
	%86, 56
	\KeyG
	R2.*12
}

PianoDynamicsB = \relative c {
	%42
	s2. | s2.\< | s2.*3 | s2.\f\> | s8 s\mf s2 |
	%49
	s2.*3 | s2.\> | s8 s\mp s2 |
	%55
	\ritATempo
	s2.\startTextSpan |
	\time 4/4
	s1 |
	\time 3/4
	%56
	s2.\stopTextSpan |
	s2. | s2.\<
	s4\mf s2\startTextSpan | s2.\stopTextSpan |
	s2.\> | s8 s8\mp s2 | s2.*4 |
	%67
	s2.\startTextSpan | s2.\stopTextSpan |
	s2.*9 |
	%78
	s2.*8 | s2.\< | s2.*4 |
	%91
	s2.\mf | s2.*7 | s4 s2\< | s2.*2 |
	%102
	\moltoRitATempo
	s8\f s8\startTextSpan s2 | s2.\stopTextSpan |
	s2.\> | s4\mf s2 | s2. |
	%108
	\ritATempo
	s2.\startTextSpan | s2.\stopTextSpan | s2.\> | s8 s\mp s2
	%111
	\time 4/4
	s1\startTextSpan |
	\time 3/4
	s32 s\stopTextSpan s8. s2 |
	%113
	s2.*2 |
	s2.\startTextSpan | s32 s\stopTextSpan s8. s2 |
	%117
	s2.*6
	\ritSpan
	s2.\startTextSpan | s32 s\stopTextSpan s8. s2 |

}

PianoBassB = \relative c {
	%CODA
	\KeyDCoda

	\times 2/3 {
		%72, 42
		\repeat unfold 5 { d8 fs gs cs gs fs cs' gs fs | }
	}
		%77, 47
		\KeyE
		\grace s8
	\times 2/3 {
		g,-> ef' f bf f ef bf' f ef |
		\repeat unfold 2 { c g' af ef' af, g ef' af, g | }
		%80, 50
		c, af' bf ef bf af ef' bf af |
		c, af' b e b af f' b, af |
	}
		%82, 52
		\KeyF
		\grace s8
	\times 2/3 {
		bf, gf' af df af gf df' af gf |
		\repeat unfold 2 { ef gf af f' af, gf f' af, gf | }
		%85, 55

		\time 4/4
		ef gf af f' af, gf f' af, gf f' af, gf |

		\time 3/4
		%86, 56
		\KeyG
		\repeat unfold 2 { d gf af df af gf df' af gf | }
		\repeat unfold 2 { b, gf' af d af gf d' af gf | }
		%90, 60
		\repeat unfold 2 { gf, df' af' bf af df, bf' af df, | }
		\repeat unfold 2 { gf, d' af' bf af d, bf' af d, | }
		\repeat unfold 2 { gf, df' af' bf af df, bf' af df, | }
		\repeat unfold 2 { gf, d' af' bf af d, bf' af d, | }

		%98, 68
	}
}

ViolinC = \relative c'' {
	%98, 68
	\KeyH
	r4 b4 d8 fs | a4 g8 fs d b | g fs ~ fs2 | \acciaccatura g8 a2. |
	%102, 72
	r4 r8 fs8 ~ fs4 | a8 d fs a ~ \times 2/3 { a8 g fs } |
	d8 bf ~ bf a ~ a g ~ | g e ~ e2 |
	%106, 76
	r4 d8. fs16 ~ fs8 b8 | cs d8 ~ d4 cs8 \tieDown b8 ~  |
	%108, 78
	\KeyI

	\longGliss
	\appoggiatura b8\glissando cs2. ~ | cs2.
	\tieNeutral
	%110, 80
	r4 fs, gs8 a | b4 ~ b8 e,8 ~ e4 | \longerGliss e8\glissando( d8) ~ d4 g4 ~ | g2. |
	%114, 84
	\KeyJ
	r4 r fs ~ | fs2. ~ |
	%116, 86
	fs8 g ~ g4 ~ g8 \times 2/3 { a16 b8 } | c2 d8( e ~ |
	e) e ~ e4 g | f4\glissando( \times 2/3 { d8) f,4-> ~ } f8 r | r4 r8 e8 ~ e4 |
	%121, 91
	\KeyK
	fs8 gs ~ gs4 a8 b ~ | b cs ~ cs ds e fs | gs a ~ a4 b ~ |
	b8 cs ~ cs4 ~ cs8 ds ~ | ds2 e4 ~ | e8 ds8 ~ ds2 | e4 ~ e8 fs8 ~ fs4 ~ | fs8 gs ~ gs2 |
	%129, 99
	r4 a,,4 b | cs d e | fs gs a | b cs d ~ | 
	%133, 103
	\KeyL
	\appoggiatura d8 ef2 ~ \times 2/3 { \longGliss ef4\glissando a,8 } | ef,2.-^ ~ |
	ef4 f g | af bf c | d e f |
	%138, 108
	\KeyM
	gf2 ~ \times 2/3 { \longGliss gf4\glissando( ef8) } | gf,2. |
	r4 af bf |
	%141, 111
	\time 4/4
	df gf af bf |
	\time 3/4
	%142, 112
	\KeyN

	\tupletUp
	cf \acciaccatura df16 cf2 ~ | cf4 bf ~ \times 2/3 { bf8 af4 } |
	\tupletNeutral
	gf2. ~ | gf4 gf af | \acciaccatura a8 bf2. ~ | bf2. ~ | bf4 r r |
	%149, 119
	\ottava #1
	r r bf'4 ~ | bf2. ~ | bf2. |
	\ottava #0
	R2.*2 | r2.^\fermata
}

PianoTrebleC = \relative c' {
	%98, 68
	\KeyH
	R2.*10 |
	%108, 78
	\KeyI
	\grace s8
	R2.*6 |
	%114, 84
	\KeyJ
	R2.*7|
	%121, 91
	\KeyK
	R2.*2 |
	s2. | s2. |
	%125, 95
	R2.*8 |
	%133, 103
	\KeyL
	\grace s8
	R2.*5 |
	%138, 108
	\KeyM
	R2.*3
	\time 4/4
	R1 |
	\time 3/4
	%142, 112
	\KeyN
	R2.*13
}

PianoBassC = \relative c {

	\times 2/3 {
		%98, 68
		\KeyH
		\repeat unfold 2 { g8 d' e b' e, d b' e, d | }
		\repeat unfold 2 { fs, cs' d a' d, cs a' d, cs | }
		r cs d a' d, cs a' d, cs |
		fs, cs' d a' d, cs a' d, cs |
		%104, 74
		\repeat unfold 2 { g d' e bf' e, d bf' e, d | }
		\repeat unfold 2 { b fs' g d' g, fs d' g, fs | }
	}
		%108, 78
		\KeyI
		\grace s8
	\times 2/3 {
		b, es gs cs gs es cs' gs es |
		bf fs' gs cs gs fs cs' gs fs |
		a, fs' gs cs gs fs cs' gs fs |
		gs, e' fs b fs e b' fs e |
		%112, 82
		g, d' e bf' e, d bf' e, d |
		c g' af ef' af, g ef' af, g |
		%114, 84
		\KeyJ
		f a d fs d a fs' d a |
		r a d fs d a fs' d a |
		%116, 86

		b, fs' g d' g, fs d' g, fs |
		\repeat unfold 2 { bf, e g c g e c' g e | }
		a, f' g c g f c' g f 
		af, e' fs b fs e b' fs e
		
		%121, 91
		\KeyK
		\repeat unfold 2 { cs fs gs ds' gs, fs ds' gs, fs | }
		\repeat unfold 2 { fs a b \change Staff=upper gs' b, a gs' b, a \change Staff=lower | }
		%125, 95
		\repeat unfold 2 { b, e fs cs' fs, e cs' fs, e | }
		\repeat unfold 6 { d fs gs cs gs fs cs' gs fs | }
	}
		%133, 103
		\KeyL
		\grace s8
	\times 2/3 {
		g,-> ef' f bf f ef bf' f ef |
		\repeat unfold 2 { c g' af ef' af, g ef' af, g | }
		c, af' bf ef bf af ef' bf af |
		c, af' b e b af f' b, af |

		%138, 108
		\KeyM
		bf, gf' af df af gf df' af gf |
		ef gf af f' af, gf f' af, gf |
		r gf af f' af, gf f' af, gf |

		%141, 111
		\time 4/4
		ef gf af f' af, gf f' af, gf f' af, gf |
		\time 3/4

		%142, 112
		\KeyN
		\repeat unfold 2 { d gf af df af gf df' af gf | }
		\repeat unfold 2 { b, gf' af d af gf d' af gf | }

		%146, 116
		\repeat unfold 2 { gf, df' af' bf af df, bf' af df, | }
		\repeat unfold 2 { gf, d' af' bf af d, bf' af d, | }
		\repeat unfold 2 { gf, df' af' bf af df, bf' af df, | }
		\repeat unfold 2 { gf, d' af' bf af d, bf' af d, | }
	}

	%153, 124
	\acciaccatura gf,8 <gf gf' bf>2.^\fermata
}


ViolinStaff = {
	\set Staff.instrumentName = #"Violin "
	\set Staff.midiInstrument = #"violin"
	\Global
	\ViolinA
	\ViolinB
	\ViolinC
	\bar "|."
}

ViolinDynamics = {
	\Global
	\shift
	\ViolinDynamicsA
	\ViolinDynamicsB
	\unshift
}

UpperStaff = {
	%\override Score.MetronomeMark #'transparent = ##t
	\Global
	\clef treble
	\PianoTrebleA |
	\PianoTrebleB |
	\PianoTrebleC |
	\bar "|."
}

PianoDynamics = {
	\Global
	\PianoDynamicsA
	\PianoDynamicsB
}

LowerStaff = {
	\Global
	\clef bass

 	\PianoBassA |
 	\PianoBassB |
 	\PianoBassC |
	\bar "|."
}

ScoreViolinStaff = {
	<<
		\new Staff = "vln"
		{
			\set Staff.instrumentName = #"Violin "
			\set Staff.midiInstrument = #"violin"
			\ViolinStaff
		}
		\new Dynamics = "vlndynamics" \ViolinDynamics
	>>
}

PartViolinStaff = {
	<<
		\new Staff = "vln" \with { \remove Instrument_name_engraver }
		{
			\compressFullBarRests
			\ViolinStaff
		}
		\new Dynamics = "vlndynamics" \ViolinDynamics
	>>
}



FullPianoStaff = {
	\set PianoStaff.instrumentName = #"Piano "
	\set PianoStaff.midiInstrument = #"acoustic grand"
	<<
		\new Staff = "upper" \UpperStaff
		\new Dynamics = "dynamics" \PianoDynamics
		\new Staff = "lower" \LowerStaff
	>>
}

\layout {
	\context {
		\type "Engraver_group"
		\name Dynamics
		\alias Voice
		\consists "Output_property_engraver"
		\consists "Piano_pedal_engraver"
		\consists "Script_engraver"
		\consists "New_dynamic_engraver"
		\consists "Dynamic_align_engraver"
		\consists "Text_engraver"
		\consists "Text_spanner_engraver"
		\consists "Skip_event_swallow_translator"
		\consists "Axis_group_engraver"
	
		\override DynamicLineSpanner #'Y-offset = #0
		\override TextScript #'font-size = #0
		\override TextScript #'font-shape = #'italic
		\override TextScript #'Y-extent = #'(1 . -1)
	  	\override TextScript #'Y-offset = #0
		\override VerticalAxisGroup #'minimum-Y-extent = #'(-1 . 1)
	}
	\context {
		\StaffGroup \accepts Dynamics
	}
	\context {
		\PianoStaff \accepts Dynamics
	}
}

\book {
	\score {
		<<
			\new Staff = "vln" {
				\ViolinStaff
			}

			\new PianoStaff = "piano" {
				\FullPianoStaff
			}

		>>
		%\midi { }
		\layout { }
	}
}

#(define output-suffix "Violin")
\book {
	\score {
		\new StaffGroup \with{systemStartDelimiter = #'SystemStartBar }
			\PartViolinStaff
		\header { piece = "Violin" }
		\layout {
			indent = 0\mm
			between-system-padding = #8
		}
	}
}

#(define output-suffix "Piano")
\book {
	\score {
		\new PianoStaff = "piano" \with { \remove Instrument_name_engraver }
		{
			\FullPianoStaff
		}
		\header { piece = "Piano" }
		\layout {
			indent = 0\mm
		}
	}
}