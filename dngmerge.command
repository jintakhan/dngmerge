#!/bin/sh

# DNG multiple exposure tool by Jintak Han
# v1.0 written June 16, 2021
# Based on dng_stacker by Anton Wolf
# Dependencies: ExifTool, ImageMagick, Adobe DNG SDK Toolkit
# Written for Mac.

# Variables
tmpdir=/tmp/dngmerge # Change to debug

echo "Welcome! This script combines multiple DNG raw files into a single exposure, giving any raw-capable camera the ability to make true multiple exposure raw files."
echo
echo "dngmerge only works with DNG files. Make sure you have converted your images to DNG, which can be done in raw processors like Camera Raw or through Adobe's free Digital Negative Converter."
echo


# Check dependency versions
cd "$(dirname "$0")"
if ! exiftool -ver >/dev/null
then
    echo 'Error! ExifTool not found.'
    echo 'Please install ExifTool. The recommended way to install ExifTool is through Homebrew using the command "brew install exiftool". You can also install ExifTool by downloading the installer at https://exiftool.org/install.html.'
    exit
elif ! magick -version >/dev/null
then
    echo 'Error! ImageMagick not found.'
    echo 'Please check if ImageMagick is installed on this computer. The recommended way to install ImageMagick is through Homebrew using the command "brew install imagemagick".'
    exit
elif [ "$(find . -name "dng_validate")" == "" ]
then
    echo 'Error! dng_validate not found.'
    echo 'Please put the bundled Adobe DNG validation tool (dng_validate) in the same directory as this script.'
    exit
fi

# Get input directory
echo "Please enter the folder that contains the source DNG images."
read inputdir
if [ "$inputdir" == "" ]
then
    echo "An invalid directory has been entered."
    echo "Exiting..."
    exit
else
    if [ "$(find $inputdir -maxdepth 1 \( -name "*.dng" -o -name "*.DNG" \))" == "" ]
    then
        echo "No DNG images were found in the folder specified."
        echo "Exiting..."
        exit
    else
        shopt -s nocaseglob
        dngfiles=($inputdir/*.dng)
    fi
fi

# Get output directory
echo "Please enter the folder in which you want the merged file to be saved. (Leave blank to save in the input directory)"
read outputdir
if [ "$outputdir" = "" ]
then
    outputdir=$inputdir
fi

# Use dng_validate to extract linearized raw data to individual TIFF files
# Change the -2 flag to -1 for pure raw data, but this might give unexpected results
mkdir $tmpdir
a=0
for i in "${dngfiles[@]}"
do
    if ! ./dng_validate -2 $tmpdir/$a $i
    then
        echo "The script encountered a fatal error during validation!"
        rm -r $tmpdir
        exit
    fi
    a=$((++a))
done

# Add TIFF files together
convert $tmpdir/* -evaluate-sequence add $tmpdir/temp.tif
mv $tmpdir/temp.tif $tmpdir/temp.dng

# Copy EXIF data from topmost DNG file to the merged file
if ! exiftool -n \
-IFD0:SubfileType#=0 \
-overwrite_original -TagsFromFile ${dngfiles[0]} \
"-all:all>all:all" \
-DNGVersion \
-DNGBackwardVersion \
-ColorMatrix1 \
-ColorMatrix2 \
'-IFD0:BlackLevelRepeatDim<SubIFD:BlackLevelRepeatDim' \
'-IFD0:PhotometricInterpretation<SubIFD:PhotometricInterpretation' \
'-IFD0:CalibrationIlluminant1<SubIFD:CalibrationIlluminant1' \
'-IFD0:CalibrationIlluminant2<SubIFD:CalibrationIlluminant2' \
-SamplesPerPixel \
'-IFD0:CFARepeatPatternDim<SubIFD:CFARepeatPatternDim' \
'-IFD0:CFAPattern2<SubIFD:CFAPattern2' \
-AsShotNeutral \
'-IFD0:ActiveArea<SubIFD:ActiveArea' \
'-IFD0:DefaultScale<SubIFD:DefaultScale' \
'-IFD0:DefaultCropOrigin<SubIFD:DefaultCropOrigin' \
'-IFD0:DefaultCropSize<SubIFD:DefaultCropSize' \
'-IFD0:OpcodeList1<SubIFD:OpcodeList1' \
'-IFD0:OpcodeList2<SubIFD:OpcodeList2' \
'-IFD0:OpcodeList3<SubIFD:OpcodeList3' \
$tmpdir/temp.dng
then
    echo "An error occurred while copying EXIF data!"
else
# Repackage and compress DNG file
    if ./dng_validate -dng $outputdir/merged.dng $tmpdir/temp.dng
    then
        echo "Finished! The images have been merged into a single file at" $outputdir/merged.dng"."
    else
        echo "The images failed to merge!"
    fi
fi

# Clean up
echo "Cleaning up..."
rm -r /tmp/dngmerge
echo "Done."
exit
