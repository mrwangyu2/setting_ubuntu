local status, actions = pcall(require, "telescope.actions")
if (not status) then
  return
end

require("telescope").setup {
  defaults = {
    mappings = {
      n = {
        ["q"] = actions.close,
        ["l"] = actions.file_edit
      }
    },
    file_ignore_patterns = {"tags", "build"}
  }
}
