\version "2.19.59"

melody = \relative c'' {
	\clef treble
	\key c \major
	\time 3/4
	\tempo 4 = 70

	
}

lower = \relative c' {
	\clef bass
	\key c \major
	\time 3/4


}

upper = \relative c' {
	\clef treble
	\key c \major
	\time 3/4

}

\book {
	\bookOutputName "Fleurs"
	\score {
		\new Staff <<
			\new Voice = "melody" { \set midiInstrument = #"cello" \voiceOne \melody }
			\new PianoStaff <<
				\new Voice = "upper" { \set midiInstrument = #"orchestral harp" \voiceTwo \upper }
				\new Voice = "lower" { \set midiInstrument = #"orchestral harp" \voiceTwo \lower }
			>>
		>>
		\layout {
			\context { \Staff \RemoveEmptyStaves }
		}
		\midi {
			\context { \Staff \remove "Staff_performer" }
			\context { \Voice \consists "Staff_performer" }
		}
	}
}

