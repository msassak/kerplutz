# Kerplutz

Command-line option parsing that won't leave you feeling kerplutz.

## OMG WHY DO WE NEED ANOTHER ONE OF THESE THINGS?

Geez I love you too, sunshine. I hesitated for a long while before
committing myself to writing Kerplutz. Eventually what pushed me into
action was the observation (hopefully correct) that OptionParser is
generally a pretty slick library, even if its interface is a bit wonky.
It seemed like a shame to let it go to waste, when getting from it what
I needed requires only a small amount of code.

## Usage

Real documentation will be forthcoming, but for now see
`features/kerplutz.feature`.

## Todo

* README docs for builder and option types
* Prettify commands summary
* Read defaults from a config file
* Argument type-casts
* List arguments
* Cleanup OptionParser's puking when an option isn't recognized
* Be more shy with the parsed arguments collection via callbacks
* Multiline descriptions?

## Copyright

Copyright (c) 2011 Mike Sassak. See LICENSE for details.
