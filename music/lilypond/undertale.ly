\version "2.19.42"

\header {
	title = "Undertale"
	subtitle = "Piano Medley"
	%: Memory, Megalovania, Fallen Down, Search Up Undertale"
	composer = "Toby Fox"
	arranger = \markup \fontsize #-3 "arr. Mira & J. Jusman"
}

upper = \relative c'' {
	\clef treble
	\key d \major

	fis8 cis8 fis8 cis8 fis8 cis8
	fis8 cis8 fis8 cis8 fis8 cis8
	b8 a8 cis4 a8 b8
	e8 es8 e8 fis8 es8 b8
	fis'8 b,8 fis8 b8 fis8 b8
	fis8 bes8 fis8 bes8 g4
	fis8 d8 fis8 d8 e8 fis8
	e4 d4 cis4
}

lower = \relative c {
	\clef bass
	\key d \major

	d8
}

\score {
	\new PianoStaff
	<<
		\new Staff = "upper" \upper \time 3/4
	\set Timing.beamExceptions = #'()
	\set Timing.baseMoment = #(ly:make-moment 1/4)
	\set Timing.beatStructure = 1,1,1
		\new Staff = "lower" \lower
	>>
	\layout {
		\context {
			\Score
			\override SpacingSpanner #'base-shortest-duration = #(ly:make-moment 1 16)
		}
	}
	\midi { }
}
