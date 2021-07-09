\version "2.14.1"

\header {
  title = "Boo's Going Home"
  composer = "Randy Newman"
	arranger = \markup \fontsize #-4 "arr. J. Jusman"
}


melody = \relative c''' {
  \clef treble
  \key e \major
  \time 6/8
  \tempo 4 = 80

  b2 r8 gis8
  b2 r8 gis8
  b8 a8~ a2
  r2.
  c2 r8 b8
  cis2 r8 b8
  cis8 b8~ b2
  r2.
  e2 r8 dis8
  e2 r8 dis8
  e8 cis8~ cis2
  r2 fis8 e8
  dis2 r8 b8
  cis2 r8 a8
  b2 r8 gis8
  a2.
  r2.

  b2 r8 gis8
  b2 r8 gis8
  b8 a8~ a2
  r2.
  cis2 r8 a8
  cis2 r4
  cis8 b8~ b2
  r2 r8 fis8
  e2 r8 dis8
  e2 r8 dis8
  e8 cis8~ cis2
  r2 fis8 e8
  dis2 r8 b8
  cis2 r8 ais8
  b2 r8 gis8
  a2.
  r2.
}

lower = \relative c' {
  \clef bass
  \key e \major
  \time 6/8

  r2.
  r2.
  r2.
}

upper = \relative c'' {
  \clef treble
  \key e \major
  \time 6/8

  e,8 b'8~ b2
  e,8 b'8 e2
  b,8 c f b c f
  a,2.
  b,8 a' <c f>2
  b,8 a' <cis fis>2
  b,8 e fis gis e' fis
  gis2.
  cis,,8 gis' e'2
  b,8 gis' fis'4 gis
  ais,,4 cis fis
  fis,2.
  b8 fis' dis'2
  b,8 a' e'2
  b,8 f' d'4 c
  b,8 c f a b4
  c2.

  e,8 b'8~ <b fis'>2
  e,8 b'8 <e g>4~ <e gis>4
  b,8 c f b c f
  a,2.
  b,8 f' d'2
  b,8 fis' dis'2
  b,8 e fis gis e' fis
  gis2.
  cis,,8 gis' e'2
  b,8 gis' fis'4 gis
  ais,,4 cis fis
  fis,2.
  b8 fis' dis'2
  b,8 a' e'2
  b,8 f' d'4 c
  b,8 c f a b4
  c2.
}

\book {
  \bookOutputName "boo-guitar"
  \paper {
    system-system-spacing #'basic-distance = #20
  }
  \score {
    \new Staff <<
      \new Voice = "melody" { \set midiInstrument = #"music box" \voiceOne \melody }
      \new Voice = "upper" { \set midiInstrument = #"orchestral harp" \voiceTwo \upper }
    >>
    \layout {
      \context {
        \Staff
        \RemoveEmptyStaves
      }
    }
    \midi {
      \context { \Staff \remove "Staff_performer" }
      \context { \Voice \consists "Staff_performer" }
    }
  }
}
