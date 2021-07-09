\version "2.14.1"

melody = \relative c'' {
  \clef treble
  \key c \major
  \time 4/4
  \tempo 4 = 75

  e2~ e2 f2~ f4 r8 f8
  g2~ g4 d4 e2~ e4. r8

  a2~ a16 r16 a,8 b8 c8
  d4. e8 d4. r8

  g2~ g8 g,8 a8 b8
  c4. d8 c4~ c16 r8.

  c'2~ c8 c,8 d8 e8
  fis4~ fis16 r16 e8 d4 a4

  b2~ b8 r8 d4
  e2~ e8 e8 f8 g8

  a2 a,4. r8
  d2~ d8 d8 e8 f8

  g2 g,4. r8
  c2~ c8 c8 d8 e8

  f2~ f16 r16 f8 g8 a8
  b4. a8 g4 d4

  e2~ e4~ e8 r16 g16
  g2 e4~ e8 r16 e16

  a2 a,4~ a8 r16 a'16
  a2 c,4~ c8 r16 a'16

  c2 c,4~ c8 r16 c'16
  c2 d,4. r8

  d2~ d8 d8 c8 b8
  g'4. e8 c4. r8

  f2~ f8 f8 e8 d8
  d'4. b8 g4. r8

  a2~ a8 a8 b8 c8
  e2~ e16 r16 c8 g8 e8

  d2~ d16 r16 a'8 b8 a8
  g8 d'8 b8 g8 f8 d8 b8 g8

  c2~ c4.~ c16 r16 c2~ c2
}

lower = \relative c {
  \clef bass
  \key c \major
  \time 4/4

  c'16 e16 r4. c16 e16 r4.
  c16 d16 r4. c16 d16 r4.

  b16 d16 r4. b16 d16 r4.
  c16 e16 r4. c16 e16 r4.

  c16 e16 r4. c16 e16 r4.
  c16 d16 r4. c16 d16 r4.

  b16 d16 r4. b16 d16 r4.
  b16 c16 r4. b16 c16 r4.

  a16 c16 r4. a16 c16 r4.
  d,16 a'16 r4. d,16 a'16 r4.

  g16 b16 r4. g16 b16 r4.
  g16 bes16 r4. g16 bes16 r4.

  f16 a16 r4. f16 a16 r4.
  f16 aes16 r4. f16 aes16 r4.

  e16 g16 r4. e16 g16 r4.
  e16 f16 r4. e16 f16 r4.

  d16 f16 r4. d16 f16 r4.
  g,16 d'16 r4. g,16 d'16 r4.

  c16 e16 r4. c16 e16 r4.
  c16 g'16 r4. c,16 g'16 r4.

  f,16 f'16 r4. f,16 f'16 r4.
  fis,16 c'16 r4. fis,16 c'16 r4.

  g16 c16 r4. g16 c16 r4.
  gis16 c16 r4. gis16 c16 r4.

  g16 d'16 r4. g,16 d'16 r4.
  g,16 e'16 r4. g,16 e'16 r4.

  g,16 f'16 r4. g,16 f'16 r4.
  g,16 f'16 r4. g,16 f'16 r4.

  g,16 fis'16 r4. g,16 fis'16 r4.
  g,16 e'16 r4. g,16 e'16 r4.

  g,16 f'16 r4. g,16 f'16 r4.
  g,16 f'16 r4. g,16 f'16 r4.

  c,16 c'16 r4. c,16 c'16 r4.
  c,16 c'16 r4. r2

  c,16 b'16 r4. r2
  r2 r2
}

upper = \relative c'' {
  \clef treble
  \key c \major
  \time 4/4

  r8 g16 c16 e16 g,16 c16 e16 r8 g,16 c16 e16 g,16 c16 e16
  r8 a,16 d16 f16 a,16 d16 f16 r8 a,16 d16 f16 a,16 d16 f16

  r8 g,16 d'16 f16 g,16 d'16 f16 r8 g,16 d'16 f16 g,16 d'16 f16
  r8 g,16 c16 e16 g,16 c16 e16 r8 g,16 c16 e16 g,16 c16 e16

  r8 a,16 e'16 a16 a,16 e'16 a16 r8 a,16 e'16 a16 a,16 e'16 a16
  r8 fis,16 a16 d16 fis,16 a16 d16 r8 fis,16 a16 d16 fis,16 a16 d16

  r8 g,16 d'16 g16 g,16 d'16 g16 r8 g,16 d'16 g16 g,16 d'16 g16
  r8 e,16 g16 c16 e,16 g16 c16 r8 e,16 g16 c16 e,16 g16 c16

  r8 e,16 g16 c16 e,16 g16 c16 r8 e,16 g16 c16 e,16 g16 c16
  r8 d,16 fis16 c'16 d,16 fis16 c'16 r8 d,16 fis16 c'16 d,16 fis16 c'16

  r8 d,16 g16 b16 d,16 g16 b16 r8 d,16 g16 b16 d,16 g16 b16
  r8 e,16 g16 cis16 e,16 g16 cis16 r8 e,16 g16 cis16 e,16 g16 cis16

  r8 d,16 a'16 d16 d,16 a'16 d16 r8 d,16 a'16 d16 d,16 a'16 d16
  r8 d,16 f16 b16 d,16 f16 b16 r8 d,16 f16 b16 d,16 f16 b16

  r8 c,16 g'16 c16 c,16 g'16 c16 r8 c,16 g'16 c16 c,16 g'16 c16
  r8 a,16 c16 f16 a,16 c16 f16 r8 a,16 c16 f16 a,16 c16 f16

  r8 a,16 c16 f16 a,16 c16 f16 r8 a,16 c16 f16 a,16 c16 f16
  r8 g,16 b16 f'16 g,16 b16 f'16 r8 g,16 b16 f'16 g,16 b16 f'16

  r8 g,16 c16 e16 g,16 c16 e16 r8 g,16 c16 e16 g,16 c16 e16
  r8 bes16 c16 e16 bes16 c16 e16 r8 bes16 c16 e16 bes16 c16 e16

  r8 a,16 c16 e16 a,16 c16 e16 r8 a,16 c16 e16 a,16 c16 e16
  r8 a,16 c16 ees16 a,16 c16 ees16 r8 a,16 c16 ees16 a,16 c16 ees16

  r8 b16 c16 ees16 b16 c16 ees16 r8 b16 c16 ees16 b16 c16 ees16
  r8 b16 c16 d16 b16 c16 d16 r8 b16 c16 d16 b16 c16 d16

  r8 g,16 b16 d16 g,16 b16 d16 r8 g,16 b16 d16 g,16 b16 d16
  r8 g,16 c16 e16 g,16 c16 e16 r8 g,16 c16 e16 g,16 c16 e16

  r8 g,16 c16 f16 g,16 c16 f16 r8 g,16 c16 f16 g,16 c16 f16
  r8 g,16 b16 f'16 g,16 b16 f'16 r8 g,16 b16 f'16 g,16 b16 f'16

  r8 a,16 c16 fis16 a,16 c16 fis16 r8 a,16 c16 fis16 a,16 c16 fis16
  r8 g,16 c16 g'16 g,16 c16 g'16 r8 g,16 c16 g'16 g,16 c16 g'16

  r8 g,16 c16 f16 g,16 c16 f16 r8 g,16 c16 f16 g,16 c16 f16
  r8 g,16 b16 f'16 g,16 b16 f'16 r8 g,16 b16 f'16 g,16 b16 f'16

  r8 g,16 bes16 e16 g,16 bes16 e16 r8 g,16 bes16 e16 g,16 bes16 e16

  \tempo 4 = 70
  r8 f,16 a16 c16
  \tempo 4 = 65
  f16 c16 a16 c16
  \tempo 4 = 60
  a16 f16 a16 f16 d16 f16 d16
  \tempo 4 = 55
  r8 g'16 b16 d16
  \tempo 4 = 50
  f16 d16 b16 d16
  \tempo 4 = 45
  b16 g16 b16 d,16 f16 \acciaccatura f32 e8.
  d2
  <c e g c>2
}

\book {
  \bookOutputName "AveMaria"
  \score {
    \new Staff <<
      \new Voice = "melody" { \set midiInstrument = #"flute" \voiceOne \melody }
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
