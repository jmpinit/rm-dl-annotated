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

## Dependencies:

All these things need to be on your path, and you need to have given `rmapi` access to your ReMarkable Cloud account:

* python
* ImageMagick (`convert`)
* [rmapi](https://github.com/juruen/rmapi)
* [rM2svg](https://github.com/reHackable/maxio/blob/master/tools/rM2svg)
* [svgexport](https://github.com/shakiba/svgexport)
* pdfinfo
* pdfunite
* pdftk

If any of your PDFs have been cropped on your ReMarkable then you will also need:

* opencv-python
* numpy
* pdftoppm

