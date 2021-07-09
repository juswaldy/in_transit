\version "2.14.1"

melody = \relative c'' {
  \clef treble
  \key c \major
  \time 3/4
  \tempo 4 = 70

  R2.*2
  g4 fis b,
  e d g,

  a4~ a4. b8
  c2~ c8 r8

  e,2 fis8 g8
  a8 b8 c8 d8 e8 fis8

  b2.~
  b2 r4

  g4 fis b,
  e d g,

  bes4~ bes4. ces8
  des2~ des8 r8

  ges,4~ ges8 aes8 bes8 ces8
  des8 d8 fes8 ges8 aes8 bes8

  d2.~
  d2 r4

  d4 b g
  e fis g

  d4~ d4. e8
  fis2~ fis8 r8

  c'4 a f
  d e f

  c4~ c4. d8
  e2~ e8 r8

  e4 a, b
  c4~ c8. r16 d8 e

  fis2.
  e2~ e8 r8

  e4 a, b
  cis4~ cis8. r16 d8 e

  f2.
  fis2~ fis8 r8
}

lower = \relative c' {
  \clef bass
  \key c \major
  \time 3/4

  g,8 d' g d g, d'
  g, d' g d g, d'

  g, d' g d g, d'
  g, d' g d g, d'

  g, e' a e g, e'
  g, e' a e g, e'

  g, e' a e g, e'
  g, d' a' d, g, d'

  g, d' g d g, d'
  g, d' g d g, d'

  g, d' g d g, d'
  g, d' g d g, d'

  g, des' g des g, des'
  ges, des' ges des ges, des'

  ges, des' ges des ges, des'
  ges, des' ges des ges, des'

  b fis' b fis b, fis'
  b, fis' b fis b, fis'

  b, d b' d, b d
  bes d bes' d, bes d

  a d a' d, a d
  d, d' a' d, d, d'

  a c a' c, a c
  aes c aes' c, aes c

  g c g' c, g c
  c, c' g' c, c, c'

  f, a e' a, f a
  e a e' a, e a

  d, a' e' a, d, a'
  e a e' a, e a

  f a e' a, f a
  e a e' a, e a

  d, a' d a d, a'
  c d, b' d, a' d,
}

upper = \relative c' {
  \clef treble
  \key c \major
  \time 3/4

  b16 d b' g b, d b' g b, d b' g
  b, d b' g b, d b' g b, d b' g

  b, d b' g b, d b' g b, d b' g
  b, d b' g b, d b' g b, d b' g

  c, e c' a c, e c' a c, e c' a
  c, e c' a c, e c' a c, e c' a

  c, e c' a c, e c' a c, e c' a
  c, fis c' a c, e c' a c, e c' a

  b, d b' g b, d b' g b, d b' g
  b, d b' g b, d b' g b, d b' g

  b, d b' g b, d b' g b, d b' g
  b, d b' g b, d b' g b, d b' g

  des fes des' bes des, fes des' bes des, fes des' bes 
  des, fes des' bes des, fes des' bes des, fes des' bes 

  b, d b' fis b, d b' fis b, d b' fis 
  ais, cis ais' fis ais, cis ais' fis ais, cis ais' fis 

  b, fis' b fis b, fis' b, fis' b fis b, fis' 
  b, fis' b fis b, fis' b, fis' b fis b, fis' 

  d g d' b d, g d' b d, g d' b
  des, e des' bes des, e des' bes des, e des' bes

  c, d c' g c, d c' g c, d c' g
  c, d c' ges c, d c' ges c, d c' ges

  c, f c' a c, f c' a c, f c' a
  ces, f ces' aes ces, f ces' aes ces, f ces' aes

  bes, c c' f, bes, c c' f, bes, c c' f,
  bes, c c' e, bes c c' e, bes c c' e,

  a, b a' d, a b a' d, a b a' d,
  a c a' e a, c a' e a, c a' e

  a, d a' fis a, d a' fis a, d a' fis
  a, c a' e a, c a' e a, c a' e

  a, b a' d, a b a' d, a b a' d,
  a cis a' e a, cis a' e a, cis a' e

  a, d a' f b, d a' f c d a' f
  a, c a' fis a, c b' fis a, c c' fis,
}

\book {
  \bookOutputName "Swan"
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

