\version "2.14.1"

drh = \drummode {
  \tempo 4 = 123
  cymr8 cymr cymr cymr cymr cymr cymr cymr cymr cymr cymr cymr cymr cymr cymr cymr
  cymr8 cymr cymr cymr cymr cymr cymr cymr cymr cymr cymr cymr cymr cymr cymr cymr
}
drl = \drummode {
%  bd8 bd8 sn8 bd bd4 << bd ss >>  bd8 tommh tommh bd toml toml bd tomfh16 tomfh 
%  cymc4 cyms cymr hh hhc hho hhho hhp \break
%    cb hc bd sn ss tomh tommh tomml toml tomfh tomfl s16
  bd8 bd sn bd16 sn~ sn sn bd8 sn~ sn16 sn
  bd16 bd bd8 sn8 bd16 sn~ sn sn bd8 sn sn16 sn
  bd8~ bd16 bd sn8 bd16 sn~ sn sn bd8 sn~ sn16 sn
  bd8 bd sn bd16 sn~ sn sn bd8 sn~ sn16 sn
}
snare = \drummode {
  bd8 bd sn bd16 sn~ sn sn bd8 sn~ sn16 sn
  bd16 bd bd8 sn8 bd16 sn~ sn sn bd8 sn sn16 sn
  bd8~ bd16 bd sn8 bd16 sn~ sn sn bd8 sn~ sn16 sn
  bd8 bd sn bd16 sn~ sn sn bd8 sn~ sn16 sn
}
    

\score {
  <<
    \new DrumStaff <<
      \set Staff.instrumentName = #"drums"
      \new DrumVoice { \stemUp \drh }
      \new DrumVoice { \stemDown \drl }
      \new DrumVoice { \stemDown \snare }
    >>
  >>
  \layout { }
  \midi {
  }
}
