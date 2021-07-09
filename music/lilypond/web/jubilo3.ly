%lilypond input for Ich hab' dich lieb, mein Wien!


\version "2.10.10"
#(set-default-paper-size "a4")
#(set-global-staff-size 19)

\header {
	title = "In dulci jubilo"
	composer = "Michael Praetorius (1571-1621), 1607"

  enteredby = "Reinhold Kainhofer"
  maintainer = "R. Kainhofer"
  maintainerEmail = "reinhold@kainhofer.com"
  copyrightyear = "2006"
  lastupdated = "Dezember 2006"
  copyright = \markup \center-align { \small \italic \line{Copyright © \copyrightyear by \with-url #"mailto:reinhold@kainhofer.com" {\enteredby} "("\with-url #"http://reinhold.kainhofer.com/" {http://reinhold.kainhofer.com/}")" }
   \small \italic \line{"Edition may be freely edited, distributed, duplicated, performed, or recorded."} }
   
  tagline = \markup { \center-align { \small \teeny \line { Computersatz von \with-url #"mailto:reinhold@kainhofer.com" {\maintainer} mit \with-url #"http://www.LilyPond.org" {LilyPond #(ly:export (lilypond-version))}\hspace #-1.0 , \lastupdated\hspace #-1.0 . } } }
}


\paper {
% 	between-system-space = 0.3\cm
	between-system-padding = 0.3\cm
	after-title-space = 0.05\cm
% 	ragged-bottom = ##f
% 	ragged-last-bottom = ##f
}

\include "deutsch.ly"

ScoreSettings = {
% 	\set Score.skipBars = ##t
% 	\override Staff.VerticalAxisGroup #'minimum-Y-extent = #'(-0 . 0)
% 	\set Staff.midiInstrument = "acoustic grand"
% 	\override Lyrics.VerticalAxisGroup #'minimum-Y-extent = #'(-0 . 0)
	% left-align all rehearsal marks
% 	\override Score.RehearsalMark #'self-alignment-X = #-1
% 	\override Score.RehearsalMark #'padding = #2.8
% 	\override Score.RehearsalMark #'font-size = #1
% 	\override Score.RehearsalMark #'font-shape = #'italic
%
	\override Score.BarNumber  #'break-visibility = #end-of-line-invisible
	\set Score.barNumberVisibility = #(every-nth-bar-number-visible 5)
}

GlobalSettings = \notemode
{	
	\key g \major
	\time 6/4
	\partial 4
% 	\autoBeamOff
	\revert Rest #'direction
	\revert MultiMeasureRest #'staff-position
}

dynamik = {
% 	s4 | s2.*7 \repeat volta 2 {
% 		s4 s s\f | s2.*23 | s2.*28 | 
% 		s4\< s s\! | s2.*3 | s4 s
% 	}
}

tempos = {
% 	s4 | s2.*7  \repeat volta 2 {
% 		\override Script #'padding = #3
% 		\mark\markup{"M�iges Tempo (dem Wort anpassend)"}
% 		s4 s s | s2.*23 | 
% 		
% 		\mark\markup{\bold \italic \bigger Refrain: Langsames Walzertempo}
% 		s2.*8 | s4 s s \once \override Score.RehearsalMark #'self-alignment-X = #0 \mark\markup{rascher werden} |
% 		s2.*4 | \mark\markup{molto rit.}s2. | s s | \mark\markup{rit.} s |
% 		\mark\markup{a tempo} s | \mark\markup{(flottes Walzertempo)} s2.*14 | s4 s
% 	}
}

sopMusic = \relative c'' {
  g4 | g2 g4 h2 c4 | d2( e4 d2) d4 | g,2 g4 h2 c4 |
  d2( e4 d2.) | \break d2 e4 d2 c4 | h2. g2 g4 | a2 a4 h2 a4 |
  g2( a4 h2) h4 | \break d2 e4 d2 c4 | h2. g2 g4 | a2 a4 h2 a4 |
  g2( a4 h2.) | \break e,2 e4 fis2 fis4 | g2.( d'2.) | h2 h4 a2 a4 | g2.~ g2 \bar"|."
}

altoMusic = \relative c' {
  d4 | d2 d4 d( g) g | a2.( fis2) fis4 | h,2 d4 d2 a'4| 
  fis2( a4 a2.) | g2 g4 g2 e4 | e2. e2 e4 | fis2 fis4 g2 fis4 |
  e2.( d2) e4 | fis2 e4 g2 e4 | e2. e2 e4 | e2 fis4 g2 fis4 |
  e4( d2~ d2.) | c2 c4 d2 d4 | e2.( a2.) | g4 d2 d4( e) d | d2.~ d2 \bar"|."
}

tenorMusic = \relative c' {
  g4 | h2 h4 h8( c8 d4) e4 | fis4( e8 d8 cis4 d2) a4 | e'4( d) h h2 e4 |
  d2( cis4 d2.) | h2 c4 h2 a4 | g2. h2 h4 | d2 d4  d2 d4 |
  h2( a4 fis2) g4 | h2 g4 h2 a4 | g2. h2 h4 | cis2 d4 d2 d4 |
  h2( fis 4 g2.) | g2 a4 a2 h4 | h2.( fis2.) | g4( a) h fis( e) fis | g2.( h2) \bar"|."
}


bassMusic = \relative c {
  g4 | g2 g4  g'2 e4 | d2( a'4 d,2) d4 | e8( fis g4) g,4 g'2 a4 |
  h2( a4 d,2.) | g2 c,4 g2 a4 | e'2. e2 e4 | d2 d4 g2 d4 |
  e4.( d8 c4 h2) e4 | h2 c4 g2 a4 | e'2. e2 e4 | a,2 d4 g,2 d'4 |
  e8( fis g4 d g,2.) | c2 a4 d2 h4 | e2.( d2.) | e4( fis) g d( cis) d | g,2.~ g2 \bar"|."
}

VerseI = \lyricmode
{
  \set stanza = "1."
  In dul -- ci ju -- bil -- lo, __ nun sin -- get und seid
  froh! __ Uns -- res Her -- zens Won -- ne leit in prae -- se -- pi -- 
  o __ und leuch -- tet als die Son -- ne ma -- tris in gre -- mi -- 
  o. __ Al -- pha es et O, __ Al -- pha es et O. __
}

VerseII = \lyricmode
{
  \set stanza = "2."
  O Je -- su par -- vu -- le, __
  nach dir ist mir so weh. __
  Tröst mir mein Ge -- mü -- te, 
  o pu -- er op -- ti -- me, __
  durch al -- le dei -- ne Gü -- te, 
  o prin -- ceps glo -- ri -- ae. __
  Tra -- he me post te, __ tra -- he me post te. __
}

VerseIII = \lyricmode
{
  \set stanza = "3."
  U -- bi sunt gau -- di -- a? __
  \skip4 Nir -- gend mehr denn da, __
  da die En -- gel sin -- gen __
  \skip4 no -- va can -- ti -- ca __
  \skip4 und die Schel -- len klin -- gen
  in re -- gis cu -- ri -- a. __
  E -- ia, wärn wir da, __
  e -- ia, wärn wir da! __
}


\score {

	\context ChoirStaff <<
		\ScoreSettings
		\context Staff = women <<
			\dynamik
			\tempos
			\dynamicUp
			\context Voice = sopranos { \voiceOne << \GlobalSettings \sopMusic >> }
			\context Voice = altos { \voiceTwo << \GlobalSettings \altoMusic >> }
      \set Staff.instrumentName = \markup { \column { "S" \line {"A"} } }
		>>
		\context Lyrics = sopranosI \lyricsto sopranos \VerseI
		\context Lyrics = sopranosII \lyricsto sopranos \VerseII
		\context Lyrics = sopranosIII \lyricsto sopranos \VerseIII

		\context Staff = men <<
			\clef bass
			\dynamik
			\dynamicDown
			\context Voice = tenors { \voiceOne <<\GlobalSettings \tenorMusic >> }
			\context Voice = basses { \voiceTwo <<\GlobalSettings \bassMusic >> }
      \set Staff.instrumentName = \markup { \column { "T" \line {"B"} } }
		>>
	>>


	\layout {
		\context {
			% a little smaller so lyrics
			% can be closer to the staff
%			\Staff \override VerticalAxisGroup #'minimum-Y-extent = #'(-3 . 3)
		}
	}

	\midi {
		\context {
			\ChoirStaff
			\accepts Dynamics
		}
	}
}

