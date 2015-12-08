#!/bin/sh
#set -ex


if [ -z "$FLIF" ]; then
   FLIF=./flif
fi


runtest_1() {
	local OUTF=/tmp/FLIF_FAILURES/tmpfiles/thread1.flif
	local OUTP=/tmp/FLIF_FAILURES/tmpfiles/thread1.pam
	local encArgs=$1
	local decArgs=$2

	$FLIF $encArgs "${IN}" "${OUTF}"
	$FLIF -d $decArgs ${OUTF} ${OUTP}

	DIFF_PIXELS=`compare -metric AE ${IN} ${OUTP} null: |& grep -o '^.' | grep -P "\d"`

	if [ "$DIFF_PIXELS" -gt "0" ] ; then
		echo $DIFF_PIXELS
		#compare ${IN} ${OUTP} -compose src /tmp/diff_.png
		cp ${IN} /tmp/FLIF_FAILURES/
		echo "bad"
	fi
}

runtest_2() {
	local OUTF=/tmp/FLIF_FAILURES/tmpfiles/thread2.flif
	local OUTP=/tmp/FLIF_FAILURES/tmpfiles/thread2.pam

	local encArgs=$1
	local decArgs=$2

	$FLIF $encArgs "${IN}" "${OUTF}"
	$FLIF -d $decArgs ${OUTF} ${OUTP}

	DIFF_PIXELS=`compare -metric AE ${IN} ${OUTP} null: |& grep -o '^.' | grep -P "\d"`

	if [ "$DIFF_PIXELS" -gt "0" ] ; then
		echo $DIFF_PIXELS
		#compare ${IN} ${OUTP} -compose src /tmp/diff.png
		cp ${IN} /tmp/FLIF_FAILURES/
		echo "bad"
	fi
}




mkdir -p /tmp/FLIF_FAILURES # critical images go here
mkdir -p /tmp/FLIF_FAILURES/tmpfiles/ # tmp files for comparison

for IN in `find $@ | grep "\.png$"` ; do

	set -f
	IFS=$'\n'

	if  [ ! `file ${IN} |& grep  "PNG image"` ] ; then # there might be gifs wrongly named .png, etc...
		continue # skip
	fi
	echo $IN;

	# run -i and -n in parallel
	runtest_1 -i &
	runtest_2 -n &
	wait

done
