\version "2.19.54"

\header {
	title = "Undertale"
	subtitle = "Piano Medley"
	composer = "Toby Fox"
	arranger = \markup \fontsize #-4 { \column {
		"arr. CrystalChameleon, LyricWulf,"
		"ThePandaTooth, J. & Mira Jusman"
		}
	}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Megalovania
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
megaUpper = \relative c'' {
	\key a \major
	\time 4/4
	\tempo 4 = 100

	<cis fis a>1~^\markup \fontsize #-2 { \hspace #5 "\"Megalovania\"" } \arpeggio
	<cis fis a>1
	<cis fis gis>1~ \arpeggio
	<cis fis gis>1

	\ottava #1

	fis4 fis'4 cis4 cis8 c8~
	c8 b4 a4 fis8 a8 b8
	e,4 fis'4 cis4 cis8 c8~
	c8 b4 a4 fis8 a8 b8
	d,4 fis'4 cis4 cis8 c8~
	c8 b4 a4 fis8 a8 b8

	cis,4. dis4. f4~
	f8 fis4. gis4 a4

%	\ottava #0

	a4 a8 a4 a4 a8~
	a8 fis4 fis8~ fis2
	a4 a8 a4 b4 c8~
	c8 b8 a8 fis8 a8 b4 r8

	a4 a8 a4 b4 c8~
	c8 cis4 e4 cis4 e8
	fis4 fis4 fis8 cis8 fis8 eis8~
	eis4 <gis,,, cis eis>4 <gis cis eis>4 <gis cis eis>4

%	\ottava #1

	<a'' cis>4 <a cis>8 <a cis>4 <a cis>4 <a cis>8~
	<a cis>8 <fis b>4 <fis b>8~ <fis b>2
	<a cis>4 <a cis>8 <a cis>4 <a cis>4 <e b'>8~
	<e b'>8 <fis cis'>4 <a fis'>4 <fis cis'>8 <e b'>8~ <e a>8

	fis'4 cis4 b4 a4
	e'4 b4 a4 gis4

	<a, d>4 e'8 fis8 <d a'>8 <fis cis'>4 <gis e'>8~
	<gis e'>2 fis'4 b8~ b8
}

megaLower = \relative c' {
	\key a \major
	\time 4/4

	r2. fis4~
	fis1
	r2. e4~
	e2 <gis, cis>2

	\ottava #1

	<<
		\new Voice { \voiceOne
			<fis' a>1
			r1
			<e gis>1
			r1
			<d a'>1
			r1

			<cis eis>1
			r1
		}
		\new Voice { \voiceTwo
			r8 cis'8 r8 cis8 r8 cis4 r8
			cis8 r8 cis8 r8 cis4. r8
			r8 b8 r8 b8 r8 b4 r8
			b8 r8 b8 r8 b4. r8
			r8 fis8 r8 fis8 r8 fis4 r8
			fis8 r8 fis8 r8 fis4. r8

			r8 gis8 eis8 r8 gis8 eis8 r8 gis8
			eis8 r8 gis8 eis8 r8 eis8 r8 eis8
		}
	>>

	\ottava #0

	fis,,4 <a' cis fis>4 <a cis fis>4 <a cis fis>4
	<a cis fis>4 <a cis fis>4 <a cis fis>4 <a cis fis>4
	e,4 <gis' b fis'>4 <gis b fis'>4 <gis b fis'>4
	<gis b fis'>4 <gis b fis'>4 <gis b fis'>4 <gis b fis'>4

	d,4 <a'' d fis>4 <a d fis>4 <a d fis>4
	<a d fis>4 <a d fis>4 <a d fis>4 <a d fis>4
	cis,,4 <gis'' cis fis>4 <gis cis fis>4 <gis cis fis>4
	cis,,4. dis4 eis4 r8

	fis8 a'8 cis8 a8 fis8 a8 cis8 a8
	fis8 a8 cis8 a8 fis8 a8 cis8 a8
	e,8 a'8 cis8 a8 e8 a8 cis8 a8
	e8 a8 cis8 a8 e8 a8 cis8 a8

	\ottava #1
	<<
		\new Voice { \voiceOne
			r8 cis'8 b8 a8 gis8 a8 b8 cis8
			r8 a8 gis8 a8 b8 a8 gis8 e8
		}
		\new Voice { \voiceTwo
			<d fis>1
			<cis e>1
		}
	>>
	<d, fis a d>1
	<<
		\new Voice { \voiceOne
			\override TextSpanner.bound-details.left.text = "rit."
			gis4. \startTextSpan a8~ a8 gis8 e'8 \stopTextSpan e'8
		}
		\new Voice { \voiceTwo
			<b, e>1
		}
	>>
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Memory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
memoryUpper = \relative c''' {
%	\key a \major
%	\time 4/4
	\tempo 4 = 110
	\set Timing.beamExceptions = #'()
	\set Timing.baseMoment = #(ly:make-moment 1/4)

	\ottava #1

	\repeat volta 2 {
		\set Timing.beatStructure = 2,2
		e8^\markup \fontsize #-2 { \hspace #9 "\"Memory\"" } b'8 a8 e8 gis8. gis8. a8
	}
	\alternative {
		{ 
			\set Timing.beatStructure = 1,1,1,1
			r8 e8 a8 e8 gis8. gis8. a8
		}
		{ r8 e8 a8 cis8 b8. a8. b8 }
	}

	\repeat volta 2 {
		\set Timing.beatStructure = 2,2
		e,8 b'8 a8 e8 gis8. gis8. a8
	}
	\alternative {
		{ 
			\set Timing.beatStructure = 1,1,1,1
			r8 e8 a8 e8 gis8. gis8. a8
		}
		{ r8 e8 a8 cis8 b8. a8. b8 }
	}

	\repeat volta 2 {
		\set Timing.beatStructure = 2,2
		<<
			\new Voice { \voiceOne e,8 b'8 a8 e8 gis8. gis8. a8 }
			\new Voice { \voiceTwo b,2 cis2 }
		>>
	}
	\alternative {
		{ 
			\set Timing.beatStructure = 1,1,1,1
			r8 <b e>8 <cis a'>8 e8 <b gis'>8. <cis gis'>8. <e a>8
		}
		{ r8 <b e>8 <cis a'>8 <e cis'>8 <fis b>8. <cis a'>8. b'8 }
	}

	\repeat volta 2 {
		\set Timing.beatStructure = 2,2
		<<
			\new Voice { \voiceOne e,8 b'8 a8 e8 gis8. gis8. a8 }
			\new Voice { \voiceTwo b,2 cis2 }
		>>
	}
	\alternative {
		{ 
			\set Timing.beatStructure = 1,1,1,1
			r8 <b e>8 <cis a'>8 e8 <b gis'>8. <cis gis'>8. <e a>8
		}
		{ r8 <b e>8 <cis a'>8 <e cis'>8 <fis b>8. <cis a'>8. <a e'>8~ }
	}

	\time 3/4
	<a e'>8 <e cis'>8. <cis a'>16~ <cis a'>4 r8 \fermata

	\ottava #0
}

memoryLower = \relative c'' {
%	\key a \major

	\ottava #2

	\repeat volta 2 {
		r8 d8 r8 d8 r8 d8 r8 d8
	}
	\alternative {
		{ r8 d8 r8 d8 r8 d8 r8 d8 }
		{ r8 d8 r8 d8 r8 d8 r8 d8 }
	}

	\repeat volta 2 {
		r8 cis8 r8 cis8 r8 cis8 r8 cis8
	}
	\alternative {
		{ r8 cis8 r8 cis8 r8 cis8 r8 cis8 }
		{ r8 fis8 r8 fis8 r8 fis8 r8 fis8 }
	}

	\repeat volta 2 {
		r8 d8 r8 d8 r8 d8 r8 d8
	}
	\alternative {
		{ r8 d8 r8 d8 r8 d8 r8 d8 }
		{ r8 d8 r8 d8 r8 d8 r8 d8 }
	}

	\repeat volta 2 {
		r8 cis8 r8 cis8 r8 cis8 r8 cis8
	}
	\alternative {
		{ r8 cis8 r8 cis8 r8 cis8 r8 cis8 }
		{ r8 fis8 r8 fis8 r8 fis8 r8 fis8 }
	}

	\override TextSpanner.bound-details.left.text = "rit."
	r8 \startTextSpan r2 r8 \stopTextSpan \fermata

	\ottava #0
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fallen Down
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fallenUpper = \relative c'' {
	\key d \major
	\time 3/4
	\tempo 4 = 100
	\set Timing.beamExceptions = #'()
	\set Timing.baseMoment = #(ly:make-moment 1/4)
	\set Timing.beatStructure = 1,1,1

	\repeat volta 2 {
		fis8^\markup \fontsize #-2 { \hspace #5 "\"Fallen Down\"" } cis8 fis8 cis8 fis8 cis8
		fis8 cis8 fis8 cis8 fis8-5 cis8-3
		b8-2 a8-1 cis4 a8 b8
		e8-4 es8 e8 fis8 es8 b8
		fis'8 b,8 fis'8 b,8 fis'8 b,8
		fis'8 bes,8 fis'8 bes,8 g'4
		fis8 d8 fis8 d8 e8 fis8
	}
	\alternative {
		{ e4 d4 cis4 }
		{ e4 d4 cis4 }
	}

	\repeat volta 2 {
		fis8 cis8 fis8 cis8 fis8 cis8
		fis8 cis8 fis8 cis8 fis8-5 cis8-3
		b8-2 a8-1 cis4 a8 b8
		e8-4 es8 e8 fis8 es8 b8
		fis'8 b,8 fis'8 b,8 fis'8 b,8
		fis'8 bes,8 fis'8 bes,8 g'4
		fis8 d8 fis8 d8 e8 fis8
	}
	\alternative {
		{ e4 d4 cis4 }
		{ cis4 fis4 cis4 }
	}

	d4 g,8 a8 b8 cis8
	d4 cis4 d4
	a4. b8 a8 g8
	fis4 fis'4 e4
	d4 g,8 a8 b8 cis8
	d4 cis d4
	fis4. g8 fis8 e8
	d4 e4 cis4

	<g b d>4 g8 a8 b8 cis8
	<e, a d>4 cis'4 d4
	<d, fis a>4. b'8 a8 g8
	<a, fis'>4 <a' fis'>4 <g e'>4
	<fis d'>4 g8 a8 b8 cis8
	<e, a d>4 cis'4 d4
	fis8 d8 fis8 d8 fis8 d8
	e4 d4 cis4
}

fallenLower = \relative c' {
	\key d \major
	\override Beam.auto-knee-gap = #6

	\repeat volta 2 {
		d8 fis8 a8 fis8 a8 fis8
		d8 fis8 a8 fis8 a8 fis8
		b,8 es8 fis8 es8 fis8 es8
		b8 es8 fis8 es8 fis8 es8
		g,8 b8 d8 b8 d8 b8
		g8 bes8 d8 bes8 d8 bes8
		d8 fis8 a8 fis8 a8 fis8
	}
	\alternative {
		{ cis8 e8 a8 e8 a8 e8 }
		{ cis8 e8 a8 cis,,8 a'8 cis8 }
	}

	\repeat volta 2 {
		d,8 a'8 d8 d,,8 a'8 d8
		a8-5 d8-3 a'8-1 d,8-3 cis8-4 d8
		b8 fis'8 b8 fis8 b8 fis8
		fis,8 fis'8 b8 fis8 b8 fis8
		g,8 d'8 g8 d8 g8 d8
		bes8 d8 g8 d8 g8 d8
		a8 d8 g8 d8 g8 d8
	}
	\alternative {
		{ a8 e'8 a8 e8 a8 e8 }
		{ a,8 e'8 b8 e8 a,8 e'8 }
	}

	g,8 d'8 g8-1 b8-2 g8-1 d8
	a8 e'8 a8 cis8 a8 e8
	d,8 a'8 d8-1 fis8-3 a8-1 fis8-3
	fis,8 cis'8 fis8-1 a8-2 cis8-1 a8-2
	g,8 d'8 g8 b8 g8 d8
	a8 e'8 a8 e8 bes8 e8
	b8 fis'8 b8 d8 b8 fis8
	a,8 fis'8 a8 cis8 a8 fis8

	g,8 d'8 g8 b8 g8 d8
	a8 e'8 a8 cis8 a8 e8
	d,8 a'8 d8 fis8 a8 fis8
	fis,8 cis'8 fis8 a8 cis8 a8
	g,8 d'8 g8 b8 g8 d8
	a8 e'8 a8 e8 bes8 e8
	b8 fis'8 b8 d8 b8 fis8
	<a, a'>2.
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Theme Waltz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
waltzUpper = \relative c'' {
%	\key d \major
	\time 6/8
%	\tempo 4 = 100

	a8^\markup \fontsize #-2 { "\"Theme Waltz\"" } r4 a'4.
	e2.
	d4. a'4.
	a,2.
	a4. d4.
	a'2 r8 b8
	a4. e4.
	d2.

	a4. a'4.
	e8-2 d8 e8 fis16-3 e16-2 d8-1 e8
	d4. a'4.
	a,8-1 d8-2 e8-3 fis8-4 e8-2 a8
	fis4. g4 fis8
	e4. d4 e8
	fis4. g4-1 b8
	a2.
}

waltzLower = \relative c' {
%	\key d \major

	d8 <fis a>8 <fis a>8 d8 <fis a>8 <fis a>8
	cis8 <e a>8 <e a>8 cis8 <e a>8 <e a>8
	b8 <d fis>8 <d fis>8 b8 <d fis>8 <d fis>8
	a8 <cis e>8 <cis e>8 a8 <cis e>8 <cis e>8
	g8 <b d>8 <b d>8 g8 <b d>8 <b d>8
	fis8 <a d>8 <a d>8 fis8 <a d>8 <a d>8
	e8 <g b>8 <g b>8 e8 <g b>8 <g b>8
	a8 <cis e>8 <cis e>8 a8 <cis e>8 <cis e>8

	d,8 <fis a d>8 <fis a d>8 d8 <fis a d>8 <fis a d>8
	cis8 <e a cis>8 <e a cis>8 cis8 <e a cis>8 <e a cis>8
	b8 <d fis b>8 <d fis b>8 b8 <d fis b>8 <d fis b>8
	a8 <cis e a>8 <cis e a>8 a8 <cis e a>8 <cis e a>8
	g8 <b d g>8 <b d g>8 g8 <b d g>8 <b d g>8
	fis8 <a d fis>8 <a d fis>8 fis8 <a d fis>8 <a d fis>8
	e'8 <g b e>8 <g b e>8 e8 <g b e>8 <g b e>8
	a,8 <cis e a>8 <cis e a>8 a8 <cis e a>8 <cis e a>8
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Theme
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
themeUpper = \relative c'' {
%	\key d \major
	\time 6/8
	\tempo 4 = 95

	<a, a'>4.^\markup \fontsize #-2 { \hspace #5 "\"Main Theme\"" } <a' a'>4.
	<e e'>2.
	<d d'>4. <a' a'>4.
	<fis fis'>2.
	<a, a'>4. <cis cis'>4.
	<a' a'>2 r8 <b b'>8
	<a a'>4. <e e'>4.
	<d d'>2.

	<a d a'>4. <a' d a'>4.
	<e a cis e>2.
	<d a' d>4. <a' d a'>4.
	<fis b d fis>2.
	<a, d a'>4. <cis cis'>4.
	<a' a'>2 r8 <b b'>8
	<a d a'>4. <e e'>4.
	<e e'>4 <d d'>8 <cis cis'>4 <d d'>8

	<b b'>4. <b' b'>4.
	<fis fis'>4. <f f'>4.
	<e e'>4. <d d'>4.
	<b b'>4 <d d'>8 <e e'>4 r8
	e2.
	r2.
}

themeLower = \relative c {
%	\key d \major

	g8 d'8 g8 b8 g8 d8
	a8 e'8 a8 cis8 a8 e8
	fis,8 d'8 fis8 a8 fis8 d8
	b8 fis'8 b8 d8 b8 fis8
	g,8 d'8 g8 b8 g8 d8
	a8 e'8 a8 cis8 a8 e8
	fis,8 d'8 fis8 a8 fis8 d8
	b8 fis'8 b8 d8 b8 fis8

	g,8 d'8 g8 b8 g8 d8
	a8 e'8 a8 cis8 a8 e8
	fis,8 d'8 fis8 a8 fis8 d8
	b8 fis'8 b8 d8 b8 fis8
	g,8 d'8 g8 b8 g8 d8
	a8 e'8 a8 cis8 a8 e8
	fis,8 d'8 fis8 a8 fis8 d8
	b8 fis'8 b8 a,8 fis'8 a8

	gis,8 e'8 gis8 b8 gis8 e8
	g,8 d'8 g8 bes8 g8 d8
	fis,8 d'8 fis8 a8 fis8 d8
	b8 fis'8 b8 a,8 fis'8 a8
	<e g b>2.
	<fis ais cis>2.
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ending
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
endingUpper = \relative c'' {
	\time 4/4

	b4 b'4 fis4 fis8 f8~
	f8 e4 d4 b8 d8 e8
	b8 b8 b'4 <b, d fis>2~ \arpeggio
	<b d fis>4 r2. \fermata \bar "|."
}

endingLower = \relative c' {
	\ottava #1

	\override TextSpanner.bound-details.left.text = "rit."
	<b fis'>8 \startTextSpan fis'8 r8 fis8 r8 fis4 r8
	fis8 r8 fis8 r8 fis4. r8
	<b, fis'>1~
	<b fis'>4 \stopTextSpan
	
	\ottava #0
	r2. \fermata
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
upper = \relative c {
	\clef treble
	\megaUpper
	\memoryUpper
	\fallenUpper
	\waltzUpper
	\themeUpper
	\endingUpper
}

lower = \relative c {
	\clef bass
	\megaLower
	\memoryLower
	\fallenLower
	\waltzLower
	\themeLower
	\endingLower
}

\paper {
	size = "letter"
	top-margin = 20
	bottom-margin = 20
	tagline = \markup \fontsize #-3 \center-column {
		\line { "Copyright 2017" \char ##x00A9 "Mira Jusman" }
		\line { "Music engraving by LilyPond 2.19.54—www.lilypond.org" }
	}
}
\score {
	\new GrandStaff
	<<
		\new Staff = "upper" \with { midiInstrument = #"acoustic grand" } \upper 
		\new Staff = "lower" \with { midiInstrument = #"acoustic grand" } \lower 
	>>
	\layout {
		\context {
			\Score
			\override SpacingSpanner #'base-shortest-duration = #(ly:make-moment 1 8)
		}
	}
	\midi { }
}

