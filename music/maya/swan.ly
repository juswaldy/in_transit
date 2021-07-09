\version "2.19.59"

lower = \relative c' {
  \clef bass
  \key c \major
  \time 1/4

  <g, d' g>
  <g, d' g>

  <g, d' g>
  <g, d' g>

  <g, e' a>
  <g, e' a>

  <g, e' a>
  <g, d' a>

  <g, d' g>
  <g, d' g>

  <g, d' g>
  <g, d' g>

  <g, des' g>
  <ges, des' ges>

  <ges, des' ges>
  <ges, des' ges>

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

  <b d g b>
  <b d g b>

  <b d g b>
  <b d g b>

  <c, e a c>
  <c, e a c>

  <c, e a c>
  <c, fis a c>

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
  \bookOutputName "swan"
  \score {
	  \new PianoStaff <<
		\new Voice = "upper" { \set midiInstrument = #"orchestral harp" \voiceTwo \upper }
		\new Voice = "lower" { \set midiInstrument = #"orchestral harp" \voiceTwo \lower }
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

