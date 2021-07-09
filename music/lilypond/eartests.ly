\version "2.14.1"

\header {
  title = "Ear Tests for Maya"
  composer = "Jus Jusman"
  tagline = "22 July 2014"
}

intervaltest = \relative c' {
  \key c \major
  \time 4/4
  \tempo 4 = 60
  
	d~ <d fis>
}

chordtest = \relative c' {
  \key c \major
}

othertest = \relative c'' {
  \key c \major
}

\book {
  \score {
    <<
      \new Staff { \set midiInstrument = #"piano" \intervaltest }
      \new Staff { \set midiInstrument = #"piano" \chordtest }
      \new Staff { \set midiInstrument = #"piano" \othertest }
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
