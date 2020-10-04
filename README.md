# rm-dl-annotated

Export annotated PDFs from [ReMarkable tablets](https://remarkable.com/).

I read lots of papers on my RM tablet. It's super cool to be able to scribble
notes and highlight them, but later I want to go back and review the notes and
unfortunately the interface on the actual RM sucks for that. I made this simple
utility so I could scroll through the PDFs on my laptop and see my highlights
and notes at a glance during review.

It also works for notebooks.

Tested with reMarkable tablet software version 2.0.2.0.

## Example

```
rm-dl-annotated.sh "/Super Cool Research Paper I Scribbled All Over"
```

Generates `./"Super Cool Research Paper (exported).pdf"` with the scribbles on top of the original PDF.

## Dependencies

All these things need to be on your path, and you need to have given `rmapi` access to your ReMarkable Cloud account:

* python
* ImageMagick (`convert`)
* pdfinfo (from poppler-utils)
* pdfunite (from poppler-utils)
* qpdf
* [rmapi](https://github.com/juruen/rmapi)
* [svgexport](https://github.com/shakiba/svgexport)
* [rM2svg](https://github.com/delaere/maxio/blob/master/tools/rM2svg)

If any of your PDFs have been cropped on your ReMarkable then you will also need:

* pdftoppm (from poppler-utils)

And the following Python libraries:

* [opencv-python](https://pypi.org/project/opencv-python/)
* [numpy](https://numpy.org/)

As of this writing [the reHackable rM2svg](https://github.com/reHackable/maxio/blob/a0a9d8291bd034a0114919bbf334973bbdd6a218/tools/rM2svg)
hasn't been updated to support new versions of the .lines file format for new
version of the ReMarkable tablet OS, so I suggest using [the fork by delaere](https://github.com/delaere/maxio/blob/master/tools/rM2svg).

## Installation

On Ubuntu:

```
sudo apt install imagemagick poppler-utils qpdf
pip install opencv-python numpy
```

Follow the installation instructions on the project pages for
[rmapi](https://github.com/juruen/rmapi),
[rM2svg](https://github.com/delaere/maxio/blob/master/tools/rM2svg)
(download the script and put it in a directory on your PATH like /usr/bin), and
[svgexport](https://github.com/shakiba/svgexport). 

