\version "2.18.2"

#(set-global-staff-size 25)

\header {
  title = "Prelude in C Major (Deconstructed)"
  subsubtitle = "aka \"Ave Maria\""
  composer = "J.S. Bach"
  arranger = \markup \fontsize #-3 "arr. J. Jusman"
}

lower = \relative c {
  \clef bass
  \key c \major
  \time 4/4

  <c' e>2 <c e> <c d> <c d>
  <b d> <b d> <c e> <c e>
  <c e> <c e> <c d> <c d>
  <b d> <b d> <b c> <b c>

  <a c> <a c> <d, a'> <d a'>
  <g b> <g b> <g bes> <g bes>
  <f a> <f a> <f aes> <f aes>
  <e g> <e g> <e f> <e f>

  <d f> <d f> <g, d'> <g d'>
  <c e> <c e> <c g'> <c g'>
  <f, f'> <f f'> <fis c'> <fis c'>
  <g c> <g c> <gis d'> <gis d'>

  <g d'> <g d'> <g e'> <g e'>
  <g f'> <g f'> <g f'> <g f'>
  <g dis'> <g dis'> <g e'> <g e'>
  <g f'> <g f'> <g f'> <g f'>

  <c, c'> <c c'>

  c16 c'16 r4. r2
  c,16 b'8.~ b4~ b2
  r2 r2

  \bar "|."
}

upper = \relative c'' {
  \clef treble
  \key c \major
  \time 4/4

  <g c e>2 <g c e> <a d f> <a d f>
  <g d' f> <g d' f> <g c e> <g c e>
  <a e' a> <a e' a> <fis a d> <fis a d>
  <g d' g> <g d' g> <e g c> <e g c>

  <e g c> <e g c> <d fis c'> <d fis c'>
  <d g b> <d g b> <e g cis> <e g cis>
  <d a' d> <d a' d> <d f b> <d f b>
  <c g' c> <c g' c> <a c f> <a c f>

  <a c f> <a c f> <g b f'> <g b f'>
  <g c e> <g c e> <bes c e> <bes c e>
  <a c e> <a c e> <a c ees> <a c ees>
  <b c ees> <b c ees> <b c d> <b c d>

  <g b d> <g b d> <g c e> <g c e>
  <g c f> <g c f> <g b f'> <g b f'>
  <a c fis> <a c fis> <g c g'> <g c g'>
  <g c f> <g c f> <g b f'> <g b f'>

  <g bes e> <g bes e>

  r8 f16 a c
  f16 c a c
  a16 f a f d f d
  r8 g'16 b d
  f16 d b d
  b16 g b d, f \acciaccatura f32 e8
  d2
  <c e g c>2
}

\book {

  \bookOutputName "avedeconstructed"
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
