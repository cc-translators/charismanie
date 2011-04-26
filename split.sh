#!/bin/bash


CHAPDIR="chapters"
SPLITDIR="splits"

# Split all files
for l in fr en; do
   mkdir -p $SPLITDIR/$l
   for c in $CHAPDIR/$l/*.tex; do
      f=$(basename $c)
      num=${f%%_*}
      csplit --quiet --prefix $SPLITDIR/$l/${num}_\
                     --suffix-format=%02d.tex \
                     --elide-empty-files \
             $c /^$/+1 {*}
   done
done


# Generate document
for c in $CHAPDIR/fr/*.tex; do
   f=$(basename $c)
   chnum=${f%%_*}
   sfile="$SPLITDIR/${chnum}.tex"

   # Make chapter title
   #echo "\input{$SPLITDIR/en/${chnum}_00}" > $sfile
   #sed -i 's@\\chapter@\\chapstyle\\chapheadstyle@' $SPLITDIR/fr/${chnum}_00.tex
   #echo "\input{$SPLITDIR/fr/${chnum}_00}" >> $sfile
   enchap=$(sed -e 's@\\chapter{\(.*\)}@\1@' $SPLITDIR/en/${chnum}_00.tex)
   frchap=$(sed -e 's@\\chapter{\(.*\)}@\1@' $SPLITDIR/fr/${chnum}_00.tex)
   echo "\\chapter{$enchap\\\\$frchap}" > $sfile


   echo '\normalfont' >> $sfile

   echo '\begin{Parallel}{2in}{2in}' >> $sfile
   for pfr in $SPLITDIR/fr/${chnum}_*.tex; do
        secname=$(basename $pfr .tex)
        secnum=${secname##*_}
        [[ "x$secnum" = "x00" ]] && continue

        pen=${pfr/fr/en}

        # Replace chapter with \Huge, section with \Large
        sed -i 's@\\section\*@\\secstyle@' $pfr

        # Remove lettrines
        sed -i 's@\\chlettrine{\(.*\)}{\(.*\)}@\1\2@' $pfr

        if [ ! -f "$pen" ]; then
           echo "E: Missing file $pen"
           exit 1
        fi

        echo '\ParallelPar' >> $sfile
        echo "\ParallelLText{\selectlanguage{english}\input{$pen}}" >> $sfile
        echo "\ParallelRText{\selectlanguage{french}\input{$pfr}}" >> $sfile
   done
   echo '\end{Parallel}' >> $sfile
done



