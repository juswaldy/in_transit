\version "2.14.1"

\header {
  title = "You Got a Friend in Me"
  composer = "Randy Newman"
	arranger = \markup \fontsize #-4 "arr. J. Jusman"
}

melody = \relative c'' {
  \clef treble
  \key c \major
  \time 4/4
  \tempo 4 = 75

  e2~ e2 f2~ f4 r8 f8
  g2~ g4 d4 e2~ e4. r8
}

lower = \relative c {
  \clef bass
  \key c \major
  \time 4/4

  c'16 e8.~ e4 c16 e8.~ e4
  c16 d8.~ d4 c16 d8.~ d4
}

upper = \relative c'' {
  \clef treble
  \key c \major
  \time 4/4

  r8 g16 c e g, c e r8 g,16 c e g, c e
  r8 a,16 d f a, d f r8 a,16 d f a, d f
}

\book {
  \bookOutputName "friendinme.pdf"
  \score {
    \new Staff <<
      \new Voice = "melody" { \set midiInstrument = #"music box" \voiceOne \melody }
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
