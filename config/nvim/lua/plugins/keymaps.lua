return {
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<A-Right>"] = { "<cmd>bnext<CR>", desc = "Next Buffer" },
          ["<A-Left>"] = { "<cmd>bprevious<CR>", desc = "Previous Buffer" },
        },
      },
    },
  },
}
