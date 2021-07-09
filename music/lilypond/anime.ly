\version "2.14.1"

melody = \relative c'' {
  \clef treble
  \tempo 4 = 170
  \key e \major
  \time 4/4

  r1 r r r r r r r

  r4 e e8 fis gis b~
  b4 gis gis8 fis e4
  c~ c r2 r1

  r4 e e8 fis gis b~
  b4 gis gis8 fis e4
  fis2. g8 fis r1

  r4 e e8 fis gis cis
  r4 gis gis8 fis e4
  dis2. e8 fis r1

  r4 e fis8 gis b4 cis
  b gis8 fis e4

  \key c \major
  e'1~ e2.
  \set midiInstrument = #"piccolo"
  d4 d4. b4 g4. d'4. c4 a g8~
  g2. e8 b'8~ b2.
  
  e,4 f4. c'8~ c4 c b a8 gis~ gis8 a b4~
  b1 r2.

  c4 c4. a4 e4. d4. c'4 e, b'8~
  b4. gis4 d c8~ c4 r2.

  a4. b c d4. e f
}

lowerer = \relative c, {
  \clef bass
  \key e \major
  \time 4/4

  r1 r r r 
  e1~ e e~ e

  e~ e c~ c
  cis~ cis a fis
  e'~ e c~ c
  cis~ cis

  \key c \major
  d1 g,
  f' f' e a, d g c, c,
  fis f e a d d g g, g, g'
}

lower = \relative c {
  \clef bass
  \key e \major
  \time 4/4

  e4 r8 e r4 e e r8 e r4 e
  fis r8 fis r4 fis fis r8 fis r4 fis

  e4 r8 e r4 e e r8 e r4 e
  fis r8 fis r4 fis fis r8 fis r4 fis

  e4 r8 e r4 e e r8 e r4 e
  fis r8 fis r4 fis fis r8 fis r4 fis

  e r8 e r4 e e r8 e r4 e
  a, r8 <c e> r4 a
  <dis, fis>4. dis'4. e,4

  <e e'> r8 <e' b'> r4 <e, e'> <e e'> r8 <e' b'> r4 <e, e'>
  <c fis'> r8 <fis' c'> r4 <c, fis'> <c fis'> r8 <fis' c'> r4 <c, fis'>

  <cis e'> r8 <e' b'> r4 <cis, e'> <cis e'> r8 <e' b'> r4 <cis, e'>

  \key c \major
  f4 r8 <f' c'> r4 f, f r8 <f' b> r4 f,

  a'8 b c e d b g f
  g a b d c a e a
  b g e g b c d b
  c b a g e g b d
  d f c a c e c a
  g f c' b c e b f

  
}

upper = \relative c'' {
  \clef treble
  \key e \major
  \time 4/4

%  r8 b dis r dis b e dis r b dis r dis b e dis
%  r a dis r dis a e' dis r a dis r dis a e' dis
%
%  r8 b dis r dis b e dis r b dis r dis b e dis
%  r a dis r dis a e' dis r a dis r dis a e' dis
%
%  r8 b dis r dis b e dis r b dis r dis b e dis
%  r a dis r dis a e' dis r a dis r dis a e' dis
%
%  r8 b dis r dis b e dis r b dis r dis b e dis
%  r e, g r c e, e' c r a cis r c a dis, e'
%
%  r8 b dis r dis b e dis r b dis r dis b e dis
%  r a dis r dis a e' dis r a dis r dis a e' dis
%
%  r8 b dis r dis b e dis r b dis r dis b e dis
%
%  \key c \major
  d,8 f c' r c f, e' c d, f c' r c f, e' d

  \set midiInstrument = #"french horn"
  <b, d g>1 <a c g'> <g b g'> <e g b>
  <f c' e> <f b e> <e gis b e> <e a d e>
  <fis e' c> <f gis c> <e gis d> <a e c>
  <d a c' g> <d fis a c> <g, c f a> <g b e gis>
  <g bes dis g> <g b e gis>
}

\book {
  \score {
    \new Staff <<
      \new Voice = "melody" { \set midiInstrument = #"recorder" \voiceOne \melody }
      \new PianoStaff <<
        \new Voice = "upper" { \set midiInstrument = #"music box" \voiceTwo \upper }
        \new Voice = "lower" { \set midiInstrument = #"pizzicato strings" \voiceTwo \lower }
        \new Voice = "lowerer" { \set midiInstrument = #"cello" \voiceTwo \lowerer }
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
