\version "2.14.1"

\header {
  title = "The Entertainer"
  composer = "Scott Joplin"
	arranger = \markup \fontsize #-4 "arr. J. Jusman"
}

upper = \relative c' {
  \clef treble
  \key c \major
  \time 4/4

	\partial 8*2
	d8 dis8
	e8 c'4 e,8 c'4 e,8 c'8~
	c2~ c8 c8 d8 dis8
	e8 c8 d8 e8~ e8 b8 d4
	c2.
	
	d,8 dis8
	e8 c'4 e,8 c'4 e,8 c'8~
	c2. a8 g8
	fis8 a8 c8 e8~ e8 d8 c8 a8
	d2.
	
	d,8 dis8
	e8 c'4 e,8 c'4 e,8 c'8~
	c2~ c8 c8 d8 dis8
	e8 c8 d8 e8~ e8 b8 d4
	c2.
	
	c8 d8
	e8 c8 d8 e8~ e8 c8 d8 c8
	e8 c8 d8 e8~ e8 c8 d8 c8
	e8 c8 d8 e8~ e8 b8 d4
	c2~ c8 \bar "|."
}

lower = \relative c {
  \clef bass
  \key c \major
  \time 4/4

	r4
	c <e g> g, <e' g>
	f <a c> f fis
	g <c e> g <b d>
	c g c, r

	c <e g> g, <e' g>
	f <a c> e dis
	d <fis a> a, <fis' a>
	<g, b d> g a b

	c <e g> g, <e' g>
	f <a c> e dis
	d <fis a> g, <b d>
	<c e g> g c, r

	c' <e g> bes <e g>
	a, <c f> aes <c f>
	g <c e> g <b d>
	<c e g> g c,8 \bar "|."
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
      \override SpacingSpanner
        #'base-shortest-duration = #(ly:make-moment 1 16)
		}
	}
  \midi { }
}
