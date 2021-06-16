# dngmerge
dngmerge is a macOS script for combining multiple individual DNG raw images into a single multiple exposure raw still. This allows cameras that cannot do multiple exposures in-camera, such as newer Sony Alpha bodies, to create authentic multiple exposure photographs without resorting to Photoshop.

This script is mostly based on [DNG Stacker](https://github.com/antonwolf/dng_stacker) by Anton Wolf.

## Dependencies
* __Adobe DNG SDK__: Only the bundled dng_validate tool is required. Latest version is also available for download from [Adobe](https://helpx.adobe.com/photoshop/digital-negative.html).
* __[ImageMagick](https://github.com/ImageMagick/ImageMagick)__: Available from [Homebrew](https://brew.sh). 
* __[ExifTool](https://exiftool.org)__: Available from [Homebrew](https://brew.sh). Standalone binaries also available from the project homepage.
* __[Adobe Digital Negative Converter](https://helpx.adobe.com/photoshop/using/adobe-dng-converter.html)__: Only needed if your raw processor does not support DNG conversions.

## Setup and install
Download the repository and run dngmerge.command after installing all required dependencies.
All source images must be converted to DNG beforehand and placed in the same folder.

## Notes
* The output raw file is linearized but not demosaiced unless the source raw files do not need demosaicing (such as Foveon sensors).
* Since the script combines raw sensor data together, the resulting image is unaffected by any white balance or post-processing settings saved in the source images.
* The resulting file is a lossless compressed 16-bit DNG raw file.
* The script currently copies the EXIF for the first image used in the multiple exposure.
* The script can be adapted for HDR, multi-shot average noise reduction and other effects.
