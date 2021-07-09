\version "2.14.1"

melody = \relative c'' {
  \clef treble
  \key c \major
  \time 4/4

  c e e
}

\book {
  \score {
    \new Staff <<
      \new Voice = "melody" { \set midiInstrument = #"grand piano" \voiceOne \melody }
    >>
    \layout {
      \context { \Staff \RemoveEmptyStaves }
    }
    \midi {
      \context { \Score midiChannelMapping = #'instrument }
    }
  }
}
