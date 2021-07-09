\version "2.14.1"

melody = \relative c'' {
  \clef treble
  \key c \major
  \time 4/4
  \tempo 4 = 100

  bes a c b
}

lowerer = \relative c, {
  \clef bass
  \key e \major
  \time 4/4

}

lower = \relative c {
  \clef bass
  \key e \major
  \time 4/4
}

upper = \relative c'' {
  \clef treble
  \key e \major
  \time 4/4

}

\book {
  \score {
    \new Staff <<
      \new Voice = "melody" { \set midiInstrument = #"choir aahs" \voiceOne \melody }
      \new PianoStaff <<
        \new Voice = "upper" { \set midiInstrument = #"music box" \voiceTwo \upper }
        \new Voice = "lower" { \set midiInstrument = #"pizzicato strings" \voiceTwo \lower }
        \new Voice = "lowerer" { \set midiInstrument = #"cello" \voiceTwo \lowerer }
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
