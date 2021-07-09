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

  c'16 e8.~ e4 c16 e8.~ e4
  c16 d8.~ d4 c16 d8.~ d4

  b16 d8.~ d4 b16 d8.~ d4
  c16 e8.~ e4 c16 e8.~ e4

  c16 e8.~ e4 c16 e8.~ e4
  c16 d8.~ d4 c16 d8.~ d4

  b16 d8.~ d4 b16 d8.~ d4
  b16 c8.~ c4 b16 c8.~ c4

  a16 c8.~ c4 a16 c8.~ c4
  d,16 a'8.~ a4 d,16 a'8.~ a4

  g16 b8.~ b4 g16 b8.~ b4
  g16 bes8.~ bes4 g16 bes8.~ bes4

  f16 a8.~ a4 f16 a8.~ a4
  f16 aes8.~ aes4 f16 aes8.~ aes4

  e16 g8.~ g4 e16 g8.~ g4
  e16 f8.~ f4 e16 f8.~ f4

  d16 f8.~ f4 d16 f8.~ f4
  g,16 d'8.~ d4 g,16 d'8.~ d4

  c16 e8.~ e4 c16 e8.~ e4
  c16 g'8.~ g4 c,16 g'8.~ g4

  f,16 f'8.~ f4 f,16 f'8.~ f4
  fis,16 c'8.~ c4 fis,16 c'8.~ c4

  g16 c8.~ c4 g16 c8.~ c4
  gis16 c8.~ c4 gis16 c8.~ c4

  g16 d'8.~ d4 g,16 d'8.~ d4
  g,16 e'8.~ e4 g,16 e'8.~ e4

  g,16 f'8.~ f4 g,16 f'8.~ f4
  g,16 f'8.~ f4 g,16 f'8.~ f4

  g,16 fis'8.~ fis4 g,16 fis'8.~ fis4
  g,16 e'8.~ e4 g,16 e'8.~ e4

  g,16 f'8.~ f4 g,16 f'8.~ f4
  g,16 f'8.~ f4 g,16 f'8.~ f4

  c,16 c'8.~ c4 c,16 c'8.~ c4
  c,16 c'8.~ c4~ c2

  c,16 b'8.~ b4~ b2
  r2 r2
}

upper = \relative c'' {
  \clef treble
  \key c \major
  \time 4/4

  r8 g16 c e g, c e r8 g,16 c e g, c e
  r8 a,16 d f a, d f r8 a,16 d f a, d f

  r8 g,16 d' f g, d' f r8 g,16 d' f g, d' f
  r8 g,16 c e g, c e r8 g,16 c e g, c e

  r8 a,16 e' a a, e' a r8 a,16 e' a a, e' a
  r8 fis,16 a d fis, a d r8 fis,16 a d fis, a d

  r8 g,16 d' g g, d' g r8 g,16 d' g g, d' g
  r8 e,16 g c e, g c r8 e,16 g c e, g c

  r8 e,16 g c e, g c r8 e,16 g c e, g c
  r8 d,16 fis c' d, fis c' r8 d,16 fis c' d, fis c'

  r8 d,16 g b d, g b r8 d,16 g b d, g b
  r8 e,16 g cis e, g cis r8 e,16 g cis e, g cis

  r8 d,16 a' d d, a' d r8 d,16 a' d d, a' d
  r8 d,16 f b d, f b r8 d,16 f b d, f b

  r8 c,16 g' c c, g' c r8 c,16 g' c c, g' c
  r8 a,16 c f a, c f r8 a,16 c f a, c f

  r8 a,16 c f a, c f r8 a,16 c f a, c f
  r8 g,16 b f' g, b f' r8 g,16 b f' g, b f'

  r8 g,16 c e g, c e r8 g,16 c e g, c e
  r8 bes16 c e bes c e r8 bes16 c e bes c e

  r8 a,16 c e a, c e r8 a,16 c e a, c e
  r8 a,16 c ees a, c ees r8 a,16 c ees a, c ees

  r8 b16 c ees b c ees r8 b16 c ees b c ees
  r8 b16 c d b c d r8 b16 c d b c d

  r8 g,16 b d g, b d r8 g,16 b d g, b d
  r8 g,16 c e g, c e r8 g,16 c e g, c e

  r8 g,16 c f g, c f r8 g,16 c f g, c f
  r8 g,16 b f' g, b f' r8 g,16 b f' g, b f'

  r8 a,16 c fis a, c fis r8 a,16 c fis a, c fis
  r8 g,16 c g' g, c g' r8 g,16 c g' g, c g'

  r8 g,16 c f g, c f r8 g,16 c f g, c f
  r8 g,16 b f' g, b f' r8 g,16 b f' g, b f'

  r8 g,16 bes e g, bes e r8 g,16 bes e g, bes e

  \tempo 4 = 70
  r8 f,16 a c
  \tempo 4 = 65
  f16 c a c
  \tempo 4 = 60
  a16 f a f d f d
  \tempo 4 = 55
  r8 g'16 b d
  \tempo 4 = 50
  f16 d b d
  \tempo 4 = 45
  b16 g b d, f \acciaccatura f32 e8.
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
