\version "2.14.1"

\header {
	title = "Akippoi Koukou"
	composer = "Nichijou"
	arranger = \markup \fontsize #-4 "trans. J. Jusman"
}

upper = \relative c' {
	\clef treble
	\key g \major
	\time 1/4

	r1 r1 r1 r1

}

lower = \relative c {
	\clef bass
	\key g \major

	<g d' e b'>4-1
	<g d' e b'>-5
	<fis cis' d a'>-7
	<g d' e bes'>-11

	<b fis' g d'>-13
	<b f' gis cis>-15
	<ais fis' gis cis>-16
	<a fis' gis cis>-17

	<gis e' fis b>-18
	<g d' e bes'>-19
	<c g' aes es'>-20
	<f a d fis>-21

	<a d fis>-22
	<b, fis' g d'>-23
	<bes e g c>-24
	<a f' g c>-26

	<gis e' fis b>-27
	<cis fis gis dis'>-28
	<fis a b gis'>-30
	<b, e fis cis'>-32
	
	<d fis gis cis>-33
	d-37\fermata
	\bar "||"

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
			\override SpacingSpanner.base-shortest-duration = #(ly:make-moment 1/16)
		}
	}
	\midi { }
}
