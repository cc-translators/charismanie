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
                     --suffix-format=%03d.tex \
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
   enchap=$(sed -e 's@\\chapter\(\[.*\]\)\?{\(.*\)}$@\2@' $SPLITDIR/en/${chnum}_000.tex)
   entempchap=$(sed -n 's@\\chapter\[\(.*\)\].*}$@\1@p' $SPLITDIR/en/${chnum}_000.tex)
   frchap=$(sed -e 's@\\chapter\(\[.*\]\)\?{\(.*\)}$@\2@' $SPLITDIR/fr/${chnum}_000.tex)
   frtempchap=$(sed -n 's@\\chapter\[\(.*\)\].*}$@\1@p' $SPLITDIR/fr/${chnum}_000.tex)
   if [[ -z $entempchap ]] && [[ -z $frtempchap ]]; then
      echo "\\chapter{$enchap \\\\$frchap}" > $sfile
   else
      [[ -z $entempchap ]] && entempchap="$enchap"
      [[ -z $frtempchap ]] && frtempchap="$frchap"
      echo "\\chapter[$entempchap \\\\$frtempchap]{$enchap \\\\$frchap}" > $sfile
   fi


   echo '\normalfont' >> $sfile

   echo '\begin{Parallel}{}{}' >> $sfile
   for pfr in $SPLITDIR/fr/${chnum}_*.tex; do
        secname=$(basename $pfr .tex)
        secnum=${secname##*_}
        [[ "x$secnum" = "x000" ]] && continue
        # Ignore empty files
        grep -q '[a-z]' $pfr || continue

        pen=${pfr/fr/en}

        # Replace chapter with \Huge, section with \Large
        sed -i 's@\\section\*@\\secstyle@' $pfr

        # Remove lettrines
        sed -i 's@\\lettrine\([A-Z]\)\(ap\)\?{\(.*\)}@\1\3@' $pfr

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



