\version "2.14.1"

\header {
  title = "Like Love"
  subsubtitle = "[Not Concert Pitch]"
  composer = "Maya Jusman"
  tagline = "6 February 2013"
}

instrumentOne = \relative c''' {
  \key g \major
  \time 4/4
  \tempo 4 = 100
  r2 g8 fis a g | b,1~ | b2 g'8 fis a g | c,1~ |
  c2 g'8 fis a g | c,1~ | c2 fis8 e g fis | b,1~ |
  b2 g'8 fis a g | b,1~ | b2 g'8 fis a g | c,1~ |
  c2 c8 b d c | fis,2.~ fis8 g | a2 a8 b fis a \breathe | g1~ |
  g1 | g\fermata \bar "|."
}

instrumentTwo = \relative c'' {
  \key g \major
  r1 | b8 d fis g~ g2 | b,8 d fis g~ g2 | c,8 e g b~ b2 |
  c,8 e g b~ b2 | a,8 c e fis~ fis2 | a,8 c e fis~ fis2 | b,8 d fis g~ g2 |
  b,8 d fis g~ g2 | b,8 d fis g~ g2 | b,8 d fis g~ g2 | c,8 e g b~ b2 |
  c,8 e g b~ b2 | d,8 fis a c~ c2 | d,8 fis a c d, b a fis \breathe | g b d g~ g2 |
  g,8 b d g~ g2 | d1\fermata |
}

instrumentThree = \relative c'' {
  \key g \major
  r1 | r2 b8 a c b | b2 b8 a c b | c2 c8 b d c |
  c2 c8 b d c | a2 a8 gis b a | a2 a8 gis b a | g2 g8 fis a g |
  g2 g8 fis a g | b2 b8 a c b | b2 b8 a c b | c2 c8 b d c |
  c2 c8 b d c | c2 d8 c b c | a2 d8 c b a \breathe | g2 g8 fis a g |
  g2 g8 fis a g | b1\fermata |
}

\book {
  \score {
    <<
      \new Staff { \set Staff.instrumentName = #"Clarinet 1" \set midiInstrument = #"vibraphone" \instrumentOne }
      \new Staff { \set Staff.instrumentName = #"Clarinet 2" \set midiInstrument = #"orchestral harp" \instrumentTwo }
      \new Staff { \set Staff.instrumentName = #"Clarinet 3" \set midiInstrument = #"celesta" \instrumentThree }
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
