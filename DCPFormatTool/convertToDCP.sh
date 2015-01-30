#!/bin/sh

HOME_PATH=.
export HOME_PATH

OUTPUT="${HOME_PATH}"/output
export OUTPUT

DIR_OPENCINEMATO="${HOME_PATH}/opencinematools-1.1.2/bin"
export DIR_OPENCINEMATO

DIR_ASDCP="${HOME_PATH}/asdcplib-1.6.37/src/.libs"
export DIR_ASDCP

DSS100_FIX_FOLDER="${HOME_PATH}/DSS100_FIX"
export DSS100_FIX_FOLDER

TEMP_DIR_NAME="${HOME_PATH}/temp"
export TEMP_DIR_NAME

OUTPUT_J2C_DIR_NAME="${HOME_PATH}/frames_j2c"
export OUTPUT_J2C_DIR_NAME

OUTPUT_PNG_DIR_NAME="${HOME_PATH}/frames_png"
#OUTPUT_PNG_DIR_NAME="${HOME_PATH}/additional"
export OUTPUT_PNG_DIR_NAME

OUTPUT_TIF_DIR_NAME="${HOME_PATH}/frames_tif"
export OUTPUT_TIF_DIR_NAME

OUTPUT_WAV_DIR_NAME="${HOME_PATH}/frames_wav"
export OUTPUT_WAV_DIR_NAME

OUTPUT_TGA_DIR_NAME="${HOME_PATH}/frames_tga"
export OUTPUT_TGA_DIR_NAME


FILE_MOVIE="etalon.mp4"
export FILE_MOVIE

# SET "true" FOR TO INVOKE [CLEAN FOLDER FROM OLD RESOURCES] ACTION
CLEAN_FOLDERS="true"
export CLEAN_FOLDERS

# SET "true" FOR TO INVOKE [EXTRACT IMAGE AND MEDIA] ACTION
EXTRACT_IMG_MEDIA="true"
export EXTRACT_IMG_MEDIA

# SET "true" FOR TO INVOKE [CONVERT PNG TO J2C] ACTION
CONVERT_PNGTOJ2C="true"
export CONVERT_PNGTOJ2C

# SET "true" FOR TO INVOKE [CONVERT TIF TO J2C] ACTION
CONVERT_TIFTOJ2C="false"
export CONVERT_TIFTOJ2C

# SET "true" FOR TO INVOKE [CONVERT TGA TO J2C] ACTION
CONVERT_TGATOJ2C="false"
export CONVERT_TGATOJ2C

# SET "true" FOR TO INVOKE [CREATE DCP PROJECT FOR DSS100] ACTION
CREATE_DCP_FOR_DSS100="false"
export CREATE_DCP_FOR_DSS10
# SET "true" FOR TO INVOKE [CREATE DCP PROJECT FOR DSS200] ACTION
CREATE_DCP_FOR_DSS200="true"
export CREATE_DCP_FOR_DSS200

PROJECT_NAME="PNFP"
export PROJECT_NAME

CURRENT_DATE=$(date +"%Y%m%d")

ANNOTATION=${PROJECT_NAME}_ADV_F_UK-XX_UA-XX_21_2K_ST_${CURRENT_DATE}_OV
export ANNOTATION



#-------------------------
#--CLEAN FOLDER FROM OLD RESOURCES
#------------------------
if [ "${CLEAN_FOLDERS}" = "true" ] ; then 
	rm -rf ${TEMP_DIR_NAME} ${OUTPUT_J2C_DIR_NAME} ${OUTPUT_PNG_DIR_NAME} ${OUTPUT_TGA_DIR_NAME} ${OUTPUT_WAV_DIR_NAME} ${OUTPUT}
fi

mkdir ${OUTPUT}
mkdir ${TEMP_DIR_NAME}
mkdir ${OUTPUT_J2C_DIR_NAME}
mkdir ${OUTPUT_PNG_DIR_NAME}
mkdir ${OUTPUT_WAV_DIR_NAME}
mkdir ${OUTPUT_TGA_DIR_NAME}
#-------------------------
#--EXTRACT IMAGE AND MEDIA
#------------------------

if [ "${EXTRACT_IMG_MEDIA}" = "true" ] ; then 

	echo "Extracting farmes from video..."
	ffmpeg  -i ${FILE_MOVIE} -s hd1080 -r 24 -f image2 ${OUTPUT_PNG_DIR_NAME}/%08d.png

	echo "Extracting sound from video... ${OUTPUT_WAV_DIR_NAME}/${FILE_MOVIE}"
	ffmpeg -i ${FILE_MOVIE} -vn -acodec pcm_s16le -ar 44100 -ac 2 ${OUTPUT_WAV_DIR_NAME}/${FILE_MOVIE}.wav
	sox ${OUTPUT_WAV_DIR_NAME}/${FILE_MOVIE}.wav -r 48k -b 24 ${OUTPUT_WAV_DIR_NAME}/left.wav mixer -l channels 1
	sox ${OUTPUT_WAV_DIR_NAME}/${FILE_MOVIE}.wav -r 48k -b 24 ${OUTPUT_WAV_DIR_NAME}/right.wav mixer -r channels 1

fi

#-------------------------
#--CONVERT TIF TO J2C
#------------------------

if [ "${CONVERT_TIFTOJ2C}" = "true" -a "${CONVERT_PNGTOJ2C}" = "false" -a "${CONVERT_TGATOJ2C}" = "false" ] ; then 

	echo "Converting frames into proper format (from tif to j2c) ..."

	cd ${OUTPUT_TIF_DIR_NAME}

	ls *.tif |awk 'BEGIN{FS="."} {print $1}'  | while read i
 	do
		echo "Srart processing ${i}.tif"
		#it has to be used when TIF images don't have proper size
		convert "${i}.tif"  -type TrueColor -alpha Off -background black -extent 2048x1080-64 -depth 12 -gamma 0.454545 -recolor "0.4124564 0.3575761 0.1804375 0.2126729 0.7151522 0.0721750 0.0193339 0.1191920 0.9503041" -gamma 2.6  ${TEMP_DIR_NAME}/temp.tif

		#convert $i.tif  -type TrueColor -alpha Off -depth 12 -gamma 0.454545 -recolor "0.4124564 0.3575761 0.1804375 0.2126729 0.7151522 0.0721750 0.0193339 0.1191920 0.9503041" -gamma 2.6  ${TEMP_DIR_NAME}/temp.tif

		image_to_j2k -cinema2K 24 -i  ${TEMP_DIR_NAME}/temp.tif -o ${OUTPUT_J2C_DIR_NAME}/"${i}.j2c"

		rm ${TEMP_DIR_NAME}/temp.tif

		echo "Stop processing ${i}.tif"
	done
fi

#-------------------------
#--CONVERT PNG TO J2C
#------------------------
if [ "${CONVERT_PNGTOJ2C}" = "true" -a "${CONVERT_TIFTOJ2C}" = "false" -a "${CONVERT_TGATOJ2C}" = "false" ] ; then 

	echo "Converting frames into proper format (from png to j2c) ..."

	cd ${OUTPUT_PNG_DIR_NAME}

	for i in `ls *.png |awk 'BEGIN{FS="."} {print $1}'`
	do

		echo "Srart processing ${i}.png"
		convert $i.png  -type TrueColor -alpha Off  -background black -extent 2048x1080-64 -depth 12 -gamma 0.454545 -recolor "0.4124564 0.3575761 0.1804375 0.2126729 0.7151522 0.0721750 0.0193339 0.1191920 0.9503041" -gamma 2.6  ${TEMP_DIR_NAME}/temp.tif


		image_to_j2k -cinema2K 24 -i ${TEMP_DIR_NAME}/temp.tif -o ${OUTPUT_J2C_DIR_NAME}/$i.j2c

		rm ${TEMP_DIR_NAME}/temp.tif

		echo "Stop processing ${i}.png"
	done
fi

#-------------------------
#--CONVERT TGA TO J2C
#------------------------
if [ "${CONVERT_PNGTOJ2C}" = "false" -a "${CONVERT_TIFTOJ2C}" = "false" -a "${CONVERT_TGATOJ2C}" = "true" ] ; then 

	echo "Converting frames into proper format (from tga to j2c) ..."

	cd ${OUTPUT_TGA_DIR_NAME}
	
	ls *.tga |awk 'BEGIN{FS="."} {print $1}'  | while read i
 	do
 
 		echo "Srart processing ${i}"
  		convert "${i}.tga"  -type TrueColor -alpha Off  -background black -extent 2048x1080-64 -depth 12 -gamma 0.454545 -recolor "0.4124564 0.3575761 0.1804375 0.2126729 0.7151522 0.0721750 0.0193339 0.1191920 0.9503041" -gamma 2.6  ${TEMP_DIR_NAME}/temp.tif	
		image_to_j2k -cinema2K 24 -i ${TEMP_DIR_NAME}/temp.tif -o ${OUTPUT_J2C_DIR_NAME}/"${i}.j2c"

  		rm ${TEMP_DIR_NAME}/temp.tif

		echo "Stop processing ${i}.tag"	
	done
fi


#---------------------------------
#--CREATE DCP PROJECT FOR DSS100
#---------------------------------
#if [ "${CREATE_DCP_FOR_DSS100}" = "true" -a "${CREATE_DCP_FOR_DSS200}" = "false" ] ; then 
if [ "${CREATE_DCP_FOR_DSS100}" = "true" ] ; then 
	
	echo "Creating DCP project resources for DSS 100 ..."
	
	cd ${HOME_PATH}

	LD_LIBRARY_PATH=${DIR_ASDCP}
	export LD_LIBRARY_PATH

	echo "Command A (create a video MXF file from the folder of J2K files):"
	${DIR_ASDCP}/asdcp-test -v -c ${PROJECT_NAME}.video.mxf ${OUTPUT_J2C_DIR_NAME}

	#Command B (create an audio MXF file from the six wavs):
	echo "Command B (create an audio MXF file from the six wavs):"
	${DIR_ASDCP}/asdcp-test -v -c ${PROJECT_NAME}.audio.mxf ${OUTPUT_WAV_DIR_NAME}/left.wav ${OUTPUT_WAV_DIR_NAME}/right.wav  

	#Command C (create an XML composition playlist):
	echo "Command C (create an XML composition playlist):"
	${DIR_OPENCINEMATO}/mkcpl --kind advertisement --title  ${ANNOTATION} --annotation  ${ANNOTATION} --norating ${PROJECT_NAME}.video.mxf ${PROJECT_NAME}.audio.mxf | sed -f ${DSS100_FIX_FOLDER}/cpl.sed > ${PROJECT_NAME}.cpl.xml

	#Command D (create an XML packing list):
	echo "Command D (create an XML packing list):"
	${DIR_OPENCINEMATO}/mkpkl --issuer stepico --annotation ${ANNOTATION} ${PROJECT_NAME}.video.mxf ${PROJECT_NAME}.audio.mxf ${PROJECT_NAME}.cpl.xml | sed -f ${DSS100_FIX_FOLDER}/pkl.sed > ${PROJECT_NAME}.pkl.xml

	#Command E (create the ASSETMAP and VOLINDEX XML files):
	echo "Command E (create the ASSETMAP and VOLINDEX XML files):"
	${DIR_OPENCINEMATO}/mkmap --issuer stepico ${PROJECT_NAME}.video.mxf ${PROJECT_NAME}.audio.mxf ${PROJECT_NAME}.cpl.xml ${PROJECT_NAME}.pkl.xml

	cat VOLINDEX.xml | sed -f  ${DSS100_FIX_FOLDER}/volindex.sed > VOLINDEX.tmp
	cat ASSETMAP.xml | sed -f ${DSS100_FIX_FOLDER}/assetmap.sed | sed -f ${DSS100_FIX_FOLDER}/assetmap2.sed > ASSETMAP.tmp
	mv VOLINDEX.tmp VOLINDEX.xml
	mv ASSETMAP.tmp ASSETMAP.xml
	
	echo "Creating package for DSS100"
	zip_file_name=${PROJECT_NAME}_${CURRENT_DATE}_DSS100.zip
	zip -m  ${zip_file_name} ASSETMAP.xml VOLINDEX.xml ${PROJECT_NAME}.video.mxf ${PROJECT_NAME}.audio.mxf ${PROJECT_NAME}.cpl.xml ${PROJECT_NAME}.pkl.xml

fi

#---------------------------------
#--CREATE DCP PROJECT FOR DSS200
#---------------------------------

#if [ "${CREATE_DCP_FOR_DSS200}" = "true" -a "${CREATE_DCP_FOR_DSS100}" = "false" ] ; then
if [ "${CREATE_DCP_FOR_DSS200}" = "true" ] ; then  
	
	echo "Creating DCP project resources for DSS 200 ..."
	
	cd ${HOME_PATH}

	LD_LIBRARY_PATH=${DIR_ASDCP}
	export LD_LIBRARY_PATH

	#Command A (create a video MXF file from the folder of J2K files):
	echo "Command A (create a video MXF file from the folder of J2K files):"
	${DIR_ASDCP}/asdcp-test -v -L -c ${PROJECT_NAME}.video.mxf ${OUTPUT_J2C_DIR_NAME}
	
	#Command B (create an audio MXF file from the six wavs):
	echo "Command B (create an audio MXF file from the six wavs):"
	${DIR_ASDCP}/asdcp-test -v -L -c ${PROJECT_NAME}.audio.mxf ${OUTPUT_WAV_DIR_NAME}/left.wav ${OUTPUT_WAV_DIR_NAME}/right.wav
	#${DIR_ASDCP}/asdcp-test -v -L -c ${PROJECT_NAME}.audio.mxf ${OUTPUT_WAV_DIR_NAME}/left.wav ${OUTPUT_WAV_DIR_NAME}/right.wav ${OUTPUT_WAV_DIR_NAME}/center.wav ${OUTPUT_WAV_DIR_NAME}/sub.wav ${OUTPUT_WAV_DIR_NAME}/surrLeft.wav ${OUTPUT_WAV_DIR_NAME}/surrRight.wav
	
	#Command C (create an XML composition playlist):
	#Content kind. Could be one of the following: feature, trailer, test, teaser, rating, advertisement, short, transitional, psa, policy
	echo "Command C (create an XML composition playlist):"
	${DIR_OPENCINEMATO}/mkcpl --kind advertisement --title  ${ANNOTATION} --annotation  ${ANNOTATION} --norating ${PROJECT_NAME}.video.mxf ${PROJECT_NAME}.audio.mxf > ${PROJECT_NAME}.cpl.xml

	#Command D (create an XML packing list):
	echo "Command D (create an XML packing list):"
	${DIR_OPENCINEMATO}/mkpkl --issuer stepico --annotation ${ANNOTATION} ${PROJECT_NAME}.video.mxf ${PROJECT_NAME}.audio.mxf ${PROJECT_NAME}.cpl.xml > ${PROJECT_NAME}.pkl.xml

	#Command E (create the ASSETMAP and VOLINDEX XML files):
	echo "Command E (create the ASSETMAP and VOLINDEX XML files):"
	${DIR_OPENCINEMATO}/mkmap --issuer stepico ${PROJECT_NAME}.video.mxf ${PROJECT_NAME}.audio.mxf ${PROJECT_NAME}.cpl.xml ${PROJECT_NAME}.pkl.xml

	echo "Creating package for DSS200"
	zip_file_name=${PROJECT_NAME}_${CURRENT_DATE}_DSS200.zip	
	zip -m ${zip_file_name} ASSETMAP.xml VOLINDEX.xml ${PROJECT_NAME}.video.mxf ${PROJECT_NAME}.audio.mxf ${PROJECT_NAME}.cpl.xml ${PROJECT_NAME}.pkl.xml
fi




