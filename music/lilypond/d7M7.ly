\version "2.14.1"

melody = \relative c'' {
  \clef treble
  \key d \major
  \time 4/4
  \tempo 4 = 75

  a4 a'2. r8
  a8 a g g fis d e g4 fis2. r2.
  a,4 b'4 a2. r8
  a8 a g g fis d e g4 fis8 e8~ e4 r8
  e16 fis g4 a8 fis8~ fis r8
  fis e cis8 d~ d fis~ fis a r8 cis~ cis c~ c b4. r8
  b b4 d8 \acciaccatura a16 b8 r cis, d e fis4 a8 \acciaccatura e16 fis8 r8
  cis~ cis d~ d1
  r2. d4 |

  d'1 r8 d8 d cis cis a fis b a2. r8 a8
  fis d d e d cis b r8
  b'1 r8 b8 b d cis a fis e fis1 r2. d4
  e'4 d2. r8 d e fis cis a fis a a1 r2. r8 fis
  g4 a a r8 fis a4 b d cis d1
}

\book {
  \bookOutputName "d7M7"
  \score {
    \new Staff <<
      \new Voice = "melody" { \set midiInstrument = #"flute" \voiceOne \melody }
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
