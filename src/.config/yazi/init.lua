-- git status in file list
require("git"):setup { order = 1500 }

-- starship prompt in header
require("starship"):setup()

-- full border with rounded corners
require("full-border"):setup { type = ui.Border.ROUNDED }
