-- Remove figures and images for a text-only PDF variant.
function Figure(_)
  return {}
end

function Image(_)
  return {}
end

function Table(_)
  return {}
end
