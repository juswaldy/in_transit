\version "2.14.1"

\header {
	title = "Deconstructed Accompaniments"
	composer = "Various Composers"
	arranger = \markup \fontsize #-4 "trans. J. Jusman"
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Girl in the Drawing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
girlUpper = \relative c' {
	\clef treble
	\key g \major
	\time 1/4

	\repeat volta 2 {
		r1^"The Girl in the Drawing - Makoto Yoshimori" r1 r1 r1 r1
	}
	\alternative {
		{
			r2
		}
		{
			r4
			\key es \major
			r4
		}
	}

	r2
	r4
	\key ges \major
	r4
	
	r1 r1

}

girlLower = \relative c {
	\clef bass
	\key g \major

	<g d' e b'>4-1
	<g d' e b'>-68-5
	<fis cis' d a'>-70-7
	<g d' e bes'>-74-11

	<b fis' g d'>-76-13
	<b f' gis cis>-78-15
	<ais fis' gis cis>-79-16
	<a fis' gis cis>-80-17

	<gis e' fis b>-81-18
	<g d' e bes'>-82-19
	<c g' aes es'>-83-20
	<f a d fis>-84-21

	<a d fis>-85-22
	<b, fis' g d'>-86-23
	<bes e g c>-87-24
	<a f' g c>-89-26

	<gis e' fis b>-90-27
	<cis fis gis dis'>-91-28
	<fis a b gis'>-93-30
	<b, e fis cis'>-95-32
	
	<d fis gis cis>-34
	d-37 \fermata

	<d fis gis cis>-97-42

	\key es \major
	<g, e' f bes>-103-47
	<c g' aes es'>-104-48
	<c aes' bes es>-106-50
	<c aes' b e>8-107-51 f'8

	\key ges \major
	<bes,, ges' aes des>4-108-52
	<es ges aes f'>-109-53
	<d ges aes des>-112-56
	<b ges' aes d>-114-58

	<ges des' aes' bes>-116-60
	<ges d' aes' bes>-118-62
	<ges des' aes' bes>-120-64
	<ges d' aes' bes>-122-66

	\acciaccatura ges8 <ges ges' bes>4

}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Le Cygne
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
swanUpper = \relative c' {
	\clef treble
	\key g \major
	\time 1/4

	\repeat volta 2 {
		<b d g b>-1^"Le Cygne - Camille Saint-Saëns"
		<c e a c>-3
		<c e\=1( a c>8-4 fis8\=1)
		<b, d g b>4-5
		
		<cis e ais cis>-7
		<b d fis b>8-8 <ais e' fis ais>8
		<d fis b>4-9
		<d g b d>8-10 <des e g des'>8

		r1 r1
	}
	\alternative {
		{
			r2
		}
		{
			r2
		}
	}

}

swanLower = \relative c {
	\clef bass
	\key g \major

	<g d' g>4
	<g e' a>
	<g e' a>8( <d' a>)
	<g d' g>4

	<g e' ais>8 fis8
	<fis d' fis>8 <fis cis' fis>8
	<b fis' b>4
	<b d b'>8 <bes d bes'>8
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
upper = \relative c {
	\clef treble
	\girlUpper
	\bar "||"
	\swanUpper
}

lower = \relative c {
	\clef bass
	\girlLower
	\swanLower
}


\score {
	\new PianoStaff
	<<
		\new Staff = "upper" \upper
		\new Staff = "lower" \lower
	>>
	\layout {
		\context {
			\Score
			\override SpacingSpanner.base-shortest-duration = #(ly:make-moment 1/16)
		}
	}
	\midi { }
}
