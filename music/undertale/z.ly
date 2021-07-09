\version "2.19.42"

\header {
	title = "Undertale"
	subtitle = "Piano Medley"
	%: Memory, Megalovania, Fallen Down, Undertale"
	composer = "Toby Fox"
	arranger = \markup \fontsize #-3 "arr. ThePandaTooth, LyricWulf, AnakBawang"
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Memory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
memoryUpper = \relative c''' {
	\key a \major
	\ottava #1
	\time 4/4
	\set Timing.beamExceptions = #'()
	\set Timing.baseMoment = #(ly:make-moment 1/4)

	\tempo 4 = 80
	\repeat volta 2 {
		\set Timing.beatStructure = 2,2
		e8^"\"Memory\"" b'8 a8 e8 gis8. gis8. a8
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
		{ r8 <b e>8 <cis a'>8 <e cis'>8 <fis b>8. <cis a'>8. b'8 }
	}

	<<
		\new Voice { \voiceOne
			\set Timing.beatStructure = 2,2
			e,8 b'8 a8 e8 gis8. gis8. a8
			\set Timing.beatStructure = 1,1,1,1
			r8 <b, e>8 <cis a'>8 e8 <b gis'>8. <cis gis'>8. <e a>8
			\set Timing.beatStructure = 2,2
			e8 b'8 a8 e8 gis8. gis8. a8
			\set Timing.beatStructure = 1,1,1,1
			r8 <b, e>8 <cis a'>8 <e cis'>8 <fis b>8. <cis a'>8. b'8
			\set Timing.beatStructure = 2,2
			e,8 b'8 a8 e8 gis8. gis8. a8
			\set Timing.beatStructure = 1,1,1,1
			r8 <b, e>8 <cis a'>8 e8 <b gis'>8. <cis gis'>8. <e a>8
			\set Timing.beatStructure = 2,2
			e8 b'8 a8 e8 gis8. gis8. a8
			\set Timing.beatStructure = 1,1,1,1
			r8 <b, e>8 <cis a'>8 <e cis'>8 <fis b>8. <cis a'>8. b'8
		}
		\new Voice { \voiceTwo
			b,2 cis2
			r1
			b2 cis2
			r1
			b2 cis2
			r1
			b2 cis2
			r1
		}
	>>

	\ottava #0
}

memoryLower = \relative c'' {
	\key a \major

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
		{ r8 d8 r8 d8 r8 d8 r8 <d a'>8 }
	}

	\repeat volta 2 {
		r8 cis8 r8 cis8 r8 cis8 r8 cis8
	}
	\alternative {
		{ r8 cis8 r8 cis8 r8 cis8 r8 cis8 }
		{ r8 fis8 r8 fis8 r8 fis8 r8 <fis a>8 }
	}

% With melody
	<<
		\new Voice { \voiceOne
			r8 d8 r8 d8 r8 d8 r8 d8
			r8 d8 r8 d8 r8 d8 r8 d8
			r8 cis8 r8 cis8 r8 cis8 r8 cis8
			r8 cis8 r8 cis8 r8 cis8 r8 cis8
			r8 d8 r8 d8 r8 d8 r8 d8
			r8 d8 r8 d8 r8 d8 r8 <d a'>8
			r8 cis8 r8 cis8 r8 cis8 r8 cis8
			r8 fis8 r8 fis8 r8 fis8 r8 <fis a>8
		}
		\new Voice { \voiceTwo
			e,2 e'2
			b1
			a2 e'2
			e,1
			e2 a2
			e'2 fis2
			e2 b2
			a1
		}
	>>

	\ottava #0
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
upper = \relative c {
	\clef treble
	\memoryUpper
}

lower = \relative c {
	\clef bass
	\memoryLower
}

\paper {
	size = "letter"
	top-margin = 20
	bottom-margin = 20
}
\score {
	\new PianoStaff
	<<
		\new Staff = "upper" \upper
		\new Staff = "lower" \lower
	>>
	\layout {
		\context {
			\Score
			\override SpacingSpanner #'base-shortest-duration = #(ly:make-moment 1 16)
		}
	}
	\midi {
	}
}
