# MWMinPhotoBrowser
A minimal iOS photo browser with captions optimized and tested on iOS 7. (based on https://github.com/mwaterfall/MWPhotoBrowser without the grid feature)
Please note, that external libraries are not included in this version, to avoid redundancy and conflicting with different versions.

## Adding to your project

Simply add the source files to your project in XCode. If build fails because of different external library versions, you should modify the source code on your own to fit to that version. (I know it's not out of the box solution, but having e.g. 2 different versions of SDWebImage in a single app is also not too smart...)

## Requied external libraries

MWPhotoBrowser very gratefully makes use of these other fantastic open source projects:

- [SDWebImage](https://github.com/rs/SDWebImage) by Olivier Poitrey — Used to handle downloading and decompressing of photos from the web.
- [MBProgressHUD](https://github.com/jdg/MBProgressHUD) by Jonathan George — Used to display activity notifications.
- [DACircularProgress](https://github.com/danielamitay/DACircularProgress) by Daniel Amitay — Used to display image download progress.

## Licence

Copyright (c) 2010 Michael Waterfall <michaelwaterfall@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
