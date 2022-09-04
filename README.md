# Text Exporter

A tool that exports words as individual images or a spritesheet, intended to be used for Rhythm Doctor custom levels as decorations.  
Made using LÖVE.

## Features
- Custom text and outline colors
- Drop shadow
- Ability to generate a spritesheet plus its JSON
- Custom font support (though rendering may be a bit wack as I've only tested with the default font)
- Custom font size (1-96)
- Word horizontal alignment
- Syllable support with `/`
- Vertical text with `\n`
- Spaces inside words with `\ ​`
  - Example: `this\nis\ vertical\ntext` will be exported as `this is vertical text`, with `this`, `is vertical` and `text` being on different lines. Nifty!

## Usage
- Compile the source or use the release executable provided.
- Click on `Open working directory` and put all the lyrics into `lyrics.txt` (or create it if it somehow wasn't created).
- Click on `Import 'lyrics.txt'` to import all the words, it should say 'Successfully loaded!'
- Click on `Start!` to start the process!
- When it's done, open the working directory and go into the folder `output`.

Additionally, there are options you can tinker around with if you press on `Options`. Experiment!

## Credits
- https://github.com/EmmanuelOga/easing/blob/master/lib/easing.lua
- https://love2d.org/wiki/HSV_color
- https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
- https://gist.github.com/jasonbradley/4357406
- https://stackoverflow.com/questions/1426954/split-string-in-lua
- https://github.com/rxi/json.lua

lmao
