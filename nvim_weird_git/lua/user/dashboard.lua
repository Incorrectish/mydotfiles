require('dashboard').setup {
    theme = 'doom',
    config = {
        header = {
            "",
            "",
            " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
            " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
            " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
            " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
            " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
            " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
            "",
            " [ TIP: To exit Neovim, just power off your computer. ] ",
            "",
        }, --your header
        center = {
            {
                icon = "  ",
                desc = "Restore Last Session                         ",
                shortcut = "SPC q l",
                action =[[<cmd>lua require("persistence").load({ last = true })<cr>]],
            },
            {
                icon = "  ",
                desc = "Find recent files                       ",
                action = "Telescope oldfiles",
                shortcut = "SPC f r",
            },
            {
                icon = "  ",
                desc = "Find files                              ",
                action = "Telescope find_files find_command=rg,--hidden,--files",
                shortcut = "SPC f f",
            },
            {
                icon = "  ",
                desc = "File browser                            ",
                action = "Telescope file_browser",
                shortcut = "SPC f b",
            },
            {
                icon = "  ",
                desc = "Find word                               ",
                action = "Telescope live_grep",
                shortcut = "SPC f g",
            },
            {
                icon = "  ", desc = "Load new theme                          ",
                action = "Telescope colorscheme",
                shortcut = "SPC s c",
            },
        },
        footer = { "", "Time to suffer -- Ishan" }  --your footer
    }
}
