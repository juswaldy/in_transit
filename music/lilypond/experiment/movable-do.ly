relativeDo =
  #(define-music-function (parser location k m) ; take two real arguments: k and m.
                          (ly:pitch? ly:music?) ; k should be a pitch, m should be some music
    #{\key $k \major                            % set the key to k
      \transpose do $k { \relative $k { $m } }  % and transpose the music so that "do" is k
    #}
  )

relativeDoPitchNames = #`(
  (cf . ,(ly:make-pitch -1 0 FLAT))
  (c  . ,(ly:make-pitch -1 0 NATURAL))
  (cs . ,(ly:make-pitch -1 0 SHARP))
  (df . ,(ly:make-pitch -1 1 FLAT))
  (d  . ,(ly:make-pitch -1 1 NATURAL))
  (ds . ,(ly:make-pitch -1 1 SHARP))
  (ef . ,(ly:make-pitch -1 2 FLAT))
  (e  . ,(ly:make-pitch -1 2 NATURAL))
  (es . ,(ly:make-pitch -1 2 SHARP))
  (ff . ,(ly:make-pitch -1 3 FLAT))
  (f  . ,(ly:make-pitch -1 3 NATURAL))
  (fs . ,(ly:make-pitch -1 3 SHARP))
  (gf . ,(ly:make-pitch -1 4 FLAT))
  (g  . ,(ly:make-pitch -1 4 NATURAL))
  (gs . ,(ly:make-pitch -1 4 SHARP))
  (af . ,(ly:make-pitch -1 5 FLAT))
  (a  . ,(ly:make-pitch -1 5 NATURAL))
  (as . ,(ly:make-pitch -1 5 SHARP))
  (bf . ,(ly:make-pitch -1 6 FLAT))
  (b  . ,(ly:make-pitch -1 6 NATURAL))
  (bs . ,(ly:make-pitch -1 6 SHARP))
  (do . ,(ly:make-pitch -1 0 NATURAL))
  (di . ,(ly:make-pitch -1 0 SHARP))
  (ra . ,(ly:make-pitch -1 1 FLAT))
  (re . ,(ly:make-pitch -1 1 NATURAL))
  (ri . ,(ly:make-pitch -1 1 SHARP))
  (ma . ,(ly:make-pitch -1 2 FLAT))
  (me . ,(ly:make-pitch -1 2 FLAT))
  (mi . ,(ly:make-pitch -1 2 NATURAL))
  (fa . ,(ly:make-pitch -1 3 NATURAL))
  (fi . ,(ly:make-pitch -1 3 SHARP))
  (se . ,(ly:make-pitch -1 4 FLAT))
  (so . ,(ly:make-pitch -1 4 NATURAL))
  (si . ,(ly:make-pitch -1 4 SHARP))
  (le . ,(ly:make-pitch -1 5 FLAT))
  (lo . ,(ly:make-pitch -1 5 FLAT))
  (la . ,(ly:make-pitch -1 5 NATURAL))
  (li . ,(ly:make-pitch -1 5 SHARP))
  (ta . ,(ly:make-pitch -1 6 FLAT))
  (te . ,(ly:make-pitch -1 6 FLAT))
  (ti . ,(ly:make-pitch -1 6 NATURAL))
)
pitchnames = \relativeDoPitchNames
#(ly:parser-set-note-names parser relativeDoPitchNames)