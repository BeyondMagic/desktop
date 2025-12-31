-- Tabs of buffers.

return {
  'noib3/nvim-cokeline',
  config = {
    -- Only show the bufferline when there are at least this many visible buffers.
    -- default: `1`.
    show_if_buffers_are_at_least = 1,

    buffers = {
      -- A function to filter out unwanted buffers. Takes a buffer table as a
      -- parameter (see the following section for more infos) and has to return
      -- either `true` or `false`.
      -- default: `false`.
      filter_valid = false,

      -- A looser version of `filter_valid`, use this function if you still
      -- want the `cokeline-{switch,focus}-{prev,next}` mappings to work for
      -- these buffers without displaying them in your bufferline.
      -- default: `false`.
      filter_visible = false,

      -- Which buffer to focus when a buffer is deleted, `prev` focuses the
      -- buffer to the left of the deleted one while `next` focuses the one the
      -- right. Turned off by default.
      -- default: `false`
      focus_on_delete = false,

      -- If set to `last` new buffers are added to the end of the bufferline,
      -- if `next` they are added next to the current buffer.
      -- default: 'last',
      new_buffers_position = 'next',
    },

    mappings = {
      -- Controls what happens when the first (last) buffer is focused and you
      -- try to focus/switch the previous (next) buffer. If `true` the last
      -- (first) buffers gets focused/switched, if `false` nothing happens.
      -- default: `true`.
      cycle_prev_next = true,
    },

    rendering = {
      -- The maximum number of characters a rendered buffer is allowed to take
      -- up. The buffer will be truncated if its width is bigger than this
      -- value.
      -- default: `999`.
      max_buffer_width = 40,
    },

    -- The default highlight group values.
    -- The `fg` and `bg` keys are either colors in hexadecimal format or
    -- functions taking a `buffer` parameter and returning a color in
    -- hexadecimal format. Similarly, the `style` key is either a string
    -- containing a comma separated list of items in `:h attr-list` or a
    -- function returning one.
    -- '#rrggbb' | function(buffer) -> '#rrggbb'
    default_hl = {
      -- default: `ColorColumn`'s background color for focused buffers,
      -- `Normal`'s foreground color for unfocused ones.
      fg = function(buffer)
        return buffer.is_focused and COLOUR.fg_1 or COLOUR.fg_2
      end,

      -- default: `Normal`'s foreground color for focused buffers,
      -- `ColorColumn`'s background color for unfocused ones.
      -- default: `Normal`'s foreground color.
      bg = function(buffer)
        return buffer.is_focused and COLOUR.bg_3 or COLOUR.bg_0
      end,
      -- default: `'NONE'`.
      -- 'attr1,attr2,...' | function(buffer) -> 'attr1,attr2,...'
      style = function(buffer)
        return buffer.is_focused and 'bold' or nil
      end,

    },

    -- A list of components to be rendered for each buffer. Check out the section
    -- below explaining what this value can be set to.
    -- default: see `/lua/cokeline/defaults.lua`
    components = {

      {
        text = '  '
      },

      -- The index of the tab!
      {
        text = function(buffer)
          return buffer.index .. ". "
        end,

        -- Whetever the are mistakes in this.
        fg = function(buffer)
          return
              (buffer.diagnostics.errors ~= 0 and COLOUR.red_1)
              or (buffer.diagnostics.warnings ~= 0 and COLOUR.fg_3)
              or nil
        end,

        style = function(buffer)
          return buffer.is_focused and "bold" or nil
        end,
      },

      -- The devicon of the file
      {
        text = function(buffer)
          return buffer.devicon.icon
        end,
        fg = function(buffer)
          return buffer.devicon.color
        end,

        style = 'NONE',
      },

      -- The prefix (path, folder) of the file.
      -- It will show up when necessary.
      {
        text = function(buffer)
          return buffer.unique_prefix
        end,
        fg = function(buffer)
          return buffer.is_focused and COLOUR.fg_3 or COLOUR.fg_5
        end,
        style = function(buffer)
          return buffer.is_focused and "bold" or nil
        end,
        truncation = {
          -- default: index of the component in the `components` table (1 for the
          -- first component, 2 for the second, etc.).
          priority = 1,

          -- default: `right`.
          direction = 'left',
        },
      },

      -- The file name itself.
      {
        text = function(buffer)
          return buffer.filename .. " "
        end,
        fg = function(buffer)
          return (buffer.diagnostics.errors ~= 0 and COLOUR.red_1)
              or (buffer.diagnostics.warnings ~= 0 and COLOUR.warning)
              or (buffer.is_focused and COLOUR.violet_1)
              or nil
        end,
        style = function(buffer)
          return buffer.is_focused and "bold" or nil
        end,
        truncation = {
          -- default: index of the component in the `components` table (1 for the
          -- first component, 2 for the second, etc.).
          priority = 2,

          -- default: `right`.
          direction = 'left',
        },
      },

      -- A sign to display whetever is modified or not.
      {
        text = ' ',
        delete_buffer_on_left_click = true,
        fg = function(buffer)
          return buffer.is_modified and COLOUR.green_0
        end,
      },

      {
        text = "  ",
      },

    },

    -- Left sidebar to integrate nicely with file explorer plugins.
    -- This is a table containing a `filetype` key and a list of `components` to
    -- be rendered in the sidebar.
    -- The last component will be automatically space padded if necessary
    -- to ensure the sidebar and the window below it have the same width.
    sidebar = {
      filetype = 'neo-tree',
      components = {
        {
          text = '',
        },
      },
    },
  },
}
