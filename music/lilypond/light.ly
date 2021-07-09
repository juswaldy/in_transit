\version "2.19.37"

melody = \relative c''' {
  \tempo 4 = 130
  g4 f4 e4 r4  d8 e8 r8 d16 b16 c8 g4 r8
  r8 g'8 f4 e4 r4  d8 e8 r8 d16 b16 c4 r4
  a'4 g4 f4 r4  g8 c8 e,8 c8 e4 d4
  g4 f4 e4 c4  d2 r2

  g4 f4 e4 r4  d8 e8 r8 d16 b16 c8 g4 r8
  r8 g'8 f4 e4 r4  d16 e16 d8 r8 b8 c4 r4
  a'4 g4 f4 r8 c8  b'8( a8) r8 g8 g4 r8 c,8
  c'4. b8 a4 r8 e8  g2
}

words = \lyricmode {

All those days  watch ing from the win dows
All those years  out side look ing in
All that time ne ver e ven know ing
Just how blind I've been

Now I'm here blink ing in the star light
Now I'm here sud den ly I see
Stand ing here it's all so clear I'm
where I'm meant to be

And at last I see the light
And it's like the fog has lifted
And at last I see the light
And it's like the sky is new
And it's warm and real and bright
And the world has somehow shifted
All at once everything looks different
Now that I see you

All those days chasing down a daydream
All those years living in a blur
All that time never truly seeing
Things, the way they were
Now she's here shining in the starlight
Now she's here suddenly I know
If she's here it's crystal clear
I'm where I'm meant to go

And at last I see the light
And it's like the fog has lifted
And at last I see the light
And it's like the sky is new

And it's warm and real and bright
And the world has somehow shifted
All at once everything is different
Now that I see you

Now that I see you
}

% \book {
%   \bookOutputName "I See the Light"
%   \score {
% 	<<
% 	  \new Voice = "one" {
% 		\time 4/4
% 		\melody
% 	  }
% 	  \new Lyrics \lyricsto "one" {
% 		\words
% 	  }
% 	>>
%   }
%   \midi {
% 	\context { \Staff \remove "Staff_performer" }
% 	\context { \Voice \consists "Staff_performer" }
%   }
% }

\book {
  \score {
    \new Staff <<
      \new Voice = "melody" { \time 4/4 \set midiInstrument = #"recorder" \voiceOne \melody }
	  \new Lyrics \lyricsto "melody" { \words }
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
