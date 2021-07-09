\version "2.14.1"

melody = \relative c'' {
  \clef treble
  \key c \major
  \time 4/4
  \tempo 4 = 200

}

lower = \relative c {
  \clef bass
  \key c \major
  \time 4/4

  a4 <b c>8 g8 
}

upper = \relative c'' {
  \clef treble
  \key c \major
  \time 4/4

}

\book {
  \score {
    \new Staff <<
      \new Voice = "melody" { \set midiInstrument = #"lead 1 (square)" \voiceOne \melody }
      \new PianoStaff <<
        \new Voice = "upper" { \set midiInstrument = #"lead 2 (sawtooth)" \voiceTwo \upper }
        \new Voice = "lower" { \set midiInstrument = #"lead 2 (sawtooth)" \voiceTwo \lower }
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
