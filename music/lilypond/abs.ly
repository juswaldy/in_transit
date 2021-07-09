\version "2.14.1"

displayLilyMusicWithExplicitDuration =
#(define-music-function (parser location music) (ly:music?)
   (newline)
   (display-lily-music music parser #:force-duration #t)
   music)

\displayLilyMusicWithExplicitDuration \transpose c c' {
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

  ges,4~ ges,8 aes8 bes8 ces8
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
