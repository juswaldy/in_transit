\version "2.19.37"

\header {
  title = "When She Loved Me"
  subsubtitle = "From Toy Story 2 - Jesse's Song"
  composer = "Randy Newman"
  tagline = "Arr. J.Jusman"
}

melody = \relative c'' {
  \clef treble
  \key d \major
  \time 4/4
  \tempo 4 = 75

}

upper = \relative c' {
  \clef treble
  \key d \major
  \time 4/4

  <fis d' fis>2 <fis cis' fis>2
  <e b' d>2 <d bes' d>2 \fermata

  \clef bass
  << {d1} \\ {fis,8 a a g g fis fis e} >>
  << {d'2 a2} \\ {fis8 a a g g fis e4} >>

  \clef treble
  <fis a>4 <g d'>4 <a d>2
  <g b>4 <b d>4 << {e2} \\ {b4 cis4} >>

}

lower = \relative c {
  \clef bass
  \key d \major
  \time 4/4

  b2 a2
  gis2 g2 \fermata

  << {d1} \\ {d'8 cis cis b b a a g} >>
  << {d1} \\ {d'8 cis cis b b a g4} >>

  <d d'>4 <e d'>4 <fis d'>2
  <g d'>4 <gis e'>4 <a e'>2

}

\book {
  \bookOutputName "WhenSheLovedMe"
  \score {
    \new Staff <<
      \new Voice = "melody" { \set midiInstrument = #"flute" \voiceOne \melody }
      \new PianoStaff <<
        \new Voice = "upper" { \set midiInstrument = #"music box" \voiceTwo \upper }
        \new Voice = "lower" { \set midiInstrument = #"music box" \voiceTwo \lower }
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
