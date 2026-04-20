-- h5p.lua
-- H5P interactive content with print fallbacks

local function is_html()
  return quarto.doc.isFormat("html")
end

local function is_pdf()
  return quarto.doc.isFormat("pdf")
end

local function is_epub()
  return quarto.doc.isFormat("epub")
end

local function split_options(options_str)
  -- Split pipe-separated options into table
  local options = {}
  for opt in string.gmatch(options_str, "([^|]+)") do
    table.insert(options, opt)
  end
  return options
end

local function escape_latex(text)
  -- Escape special LaTeX characters
  text = string.gsub(text, "\\", "\\textbackslash{}")
  text = string.gsub(text, "{", "\\{")
  text = string.gsub(text, "}", "\\}")
  text = string.gsub(text, "$", "\\$")
  text = string.gsub(text, "%", "\\%")
  text = string.gsub(text, "_", "\\_")
  text = string.gsub(text, "#", "\\#")
  text = string.gsub(text, "&", "\\&")
  text = string.gsub(text, "~", "\\textasciitilde{}")
  text = string.gsub(text, "^", "\\textasciicircum{}")
  return text
end

return {
  ["h5p"] = function(args, kwargs, meta)
    local url = kwargs["url"] or ""
    local h5p_type = kwargs["type"] or "interactive"
    local question = kwargs["question"] or "Interactive activity"
    local options_str = kwargs["options"] or ""
    local answer = kwargs["answer"] or ""
    local hint = kwargs["hint"] or ""
    
    if is_html() then
      -- HTML: embed H5P iframe
      local html = '<div class="h5p-container">'
      html = html .. '<iframe src="' .. url .. '" '
      html = html .. 'style="width: 100%; height: 400px; border: none;" '
      html = html .. 'allowfullscreen></iframe>'
      
      if hint ~= "" then
        html = html .. '<details class="h5p-hint">'
        html = html .. '<summary>Show Hint</summary>'
        html = html .. '<p>' .. hint .. '</p>'
        html = html .. '</details>'
      end
      
      html = html .. '</div>'
      
      return pandoc.RawBlock("html", html)
    
    elseif is_pdf() then
      -- PDF: styled tcolorbox with upside-down answer
      local options = split_options(options_str)
      local options_tex = ""
      
      for i, opt in ipairs(options) do
        options_tex = options_tex .. "\\item " .. escape_latex(opt)
      end
      
      local hint_tex = ""
      if hint ~= "" then
        hint_tex = "\\textbf{Hint:} " .. escape_latex(hint) .. "\\\\"
      end
      
      local latex = string.format(
        '\\begin{tcolorbox}[title={%s (%s)}, colback=yellow!10!white, coltitle=black]\\textbf{Interactive Activity: %s}\\\\[0.5em]',
        escape_latex(question), escape_latex(h5p_type), ""
      )
      
      if #options > 0 then
        latex = latex .. '\\textbf{Options:}\\begin{enumerate}' .. options_tex .. '\\end{enumerate}\\\\[0.5em]'
      end
      
      if answer ~= "" then
        -- Answer is rotated 180 degrees (upside-down)
        latex = latex .. '\\vspace{0.5em}\\textbf{Answer (upside down):}\\\\[0.5em]\n'
        latex = latex .. '\\centerline{\\rotatebox{180}{' .. escape_latex(answer) .. '}}\\\n'
      end
      
      if hint ~= "" then
        latex = latex .. '\\textit{' .. hint_tex .. '}'
      end
      
      latex = latex .. '\\end{tcolorbox}'
      
      return pandoc.RawBlock("tex", latex)
    
    elseif is_epub() then
      -- EPUB: plain text with visible answer
      local text = "**Interactive Activity**\n\n"
      text = text .. "Question: " .. question .. "\n\n"
      
      local options = split_options(options_str)
      if #options > 0 then
        text = text .. "Options:\n"
        for i, opt in ipairs(options) do
          text = text .. i .. ". " .. opt .. "\n"
        end
        text = text .. "\n"
      end
      
      if answer ~= "" then
        text = text .. "Answer: " .. answer .. "\n"
      end
      
      if hint ~= "" then
        text = text .. "\nHint: " .. hint .. "\n"
      end
      
      return pandoc.Para({pandoc.Str(text)})
    end
    
    -- Fallback
    return pandoc.Para({
      pandoc.Strong("Interactive Activity"),
      pandoc.Str(": " .. question)
    })
  end
}
