# android-prepare-maven-release
Script for getting an android maven lib ready to be uploaded to Maven Central.

The script expects that `publishToMavenLocal` has already run.
It signs the files and produces all the files needed, before zipping them together for easy upload.

You need to have setup your machine to have all the required tools and config to perform this via command line, otherwise it will not work.

## Disclaimer

This project is open source and open to anyone to use as they see fit.
But I am building this with myself as the main target audience.
So I will not be making this script generic or configurable beyond my needs.
If you need it to work differently, feel free to fork and make your changes as you need.
