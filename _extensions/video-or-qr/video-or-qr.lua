-- video-or-qr.lua
-- Renders video in HTML, QR code in PDF/EPUB

local function is_html()
  return quarto.doc.isFormat("html")
end

local function is_pdf_or_epub()
  return quarto.doc.isFormat("pdf") or quarto.doc.isFormat("epub")
end

local function to_youtube_embed(url)
  -- Convert YouTube watch URLs to embed format
  local embed_url = url
  
  -- youtube.com/watch?v=...
  local video_id = string.match(url, "[?&]v=([%w%-_]+)")
  if video_id then
    embed_url = "https://www.youtube.com/embed/" .. video_id
    return embed_url
  end
  
  -- youtu.be/...
  video_id = string.match(url, "youtu%.be/([%w%-_]+)")
  if video_id then
    embed_url = "https://www.youtube.com/embed/" .. video_id
    return embed_url
  end
  
  return url
end

local function get_qr_filename(url)
  -- Create a safe filename from URL
  local hash = 0
  for i = 1, #url do
    hash = ((hash << 5) - hash) + string.byte(url, i)
    hash = hash & 0xFFFFFFFF
  end
  return "qr-" .. string.format("%08x", hash) .. ".png"
end

return {
  ["video-or-qr"] = function(args, kwargs, meta)
    local url = args[1]
    local caption = args[2] or "Video content"
    
    if is_html() then
      -- HTML: embed video
      local embed_url = to_youtube_embed(url)
      
      return pandoc.RawBlock(
        "html",
        '<div class="video-container">' ..
        '<iframe src="' .. embed_url .. '" ' ..
        'frameborder="0" ' ..
        'allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" ' ..
        'allowfullscreen></iframe>' ..
        '<p class="video-caption">' .. caption .. '</p>' ..
        '</div>'
      )
      
    elseif is_pdf_or_epub() then
      -- PDF/EPUB: QR code with caption
      local qr_filename = get_qr_filename(url)
      local qr_path = "qr-codes/" .. qr_filename
      
      return pandoc.RawBlock(
        "tex",
        '\\begin{center}\n' ..
        '\\includegraphics[width=0.4\\textwidth]{' .. qr_path .. '}\n' ..
        '\\caption{' .. caption .. '}\n' ..
        '\\ QR code links to: ' .. url .. '\n' ..
        '\\end{center}'
      )
    end
    
    -- Fallback: return as link
    return pandoc.RawBlock(
      "markdown",
      "**Video**: [" .. caption .. "](" .. url .. ")"
    )
  end
}
