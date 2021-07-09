\version "4.14.1"

\header {
  title = "Married Life (from Up)"
  composer = "Michael Giacchino"
	arranger = \markup \fontsize #-4 "arr. J. Jusman"
}

melody = \relative c'' {
  \clef treble
  \key f \major
  \time 6/8
  \tempo 4 = 90

  r2.
  r4 r8 r8. f16 a f
  e4.~ e8. f16 a e
  d8. d16 f d c4~ c16. d32
  a'8 g8~ g16. d32 a'8 g f
  d2 r16 f16 g f
  e4.~ e8. e16 g e
  c8. c16 e c bes4.
  r8 a bes c d e
  r8 c d e8 r16 f16 a f 

  e4.~ e8. f16 a e
  d8. f16 a d e4~ e16. d32
  f8 e16 r8 d16 a8 b16 r8. \acciaccatura { c16 [cis d] }
  f4~ f16. \acciaccatura { e16 [dis] } d8. r16 f16 g f
  e4.~ e8. e16 g e
  c8. c16 e c bes c d fis g a 
  <<
    { bes2^\trill_ ( }
    { s4 \grace { bes16[ c] } }
  >>
  bes2)
}

lower = \relative c {
  \clef bass
  \key f \major
  \time 6/8

  f4. c4.
  d4. c8 d e
  f4. e4.
  d4. c4.
  g'4. d4~ d16 d16
  g4. d4.
  c2.~
  c2.
  f2.
  c2.

  f4. c4.
  d4. c4.
  b4. g'4.
  b,4. d4.
  e4. d4.
  c4. bes4.
  c4. g4.
  c,4.
}

upper = \relative c' {
  \clef treble
  \key f \major
  \time 6/8

  f8 <a c> <a c> e16. e32 <e a c>8 <e a c>
  <d f>8 <a' c> <a c> e16. e32 <e a c>8 <e a c>
  f8 <a c> <a c> e16. e32 <e a c>8 <e a c>
  <d f>8 <a' c> <a c> e16. e32 <e a c>8 <e a c>
  r8 <g b d> <g b d> r8 <a c e> <a c e>
  r8 <g b d> <g b d> r8 <f b d> <f b d>
  <e g c'>4. <e g b>4.
  <c' g bes>4. <c g>4.
  <f a c>2.
  <c g bes>2.

  f,8 <a c> <a c> e <a c> <a c>
  d8 <a c> <a c> e <a c> <a c>
  g8 <f b d> <f b d> d8 <f b d> <f b d>
  g8 <f b d> <f b d> d8 <f b d> <f b d>
  r2.
  r2.
  r8 <g bes e> <g bes e> r8 <g bes e> <g bes e>
  r8 <g bes e> <g bes e> r4.
}

\book {
  \bookOutputName "marriedlife"
  \paper {
    system-system-spacing #'basic-distance = #20
  }
  \score {
    \new Staff <<
      \new Voice = "melody" { \set midiInstrument = #"music box" \voiceOne \melody }
      \new PianoStaff <<
        \new Voice = "upper" { \set midiInstrument = #"vibraphone" \voiceTwo \upper }
        \new Voice = "lower" { \set midiInstrument = #"vibraphone" \voiceTwo \lower }
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
