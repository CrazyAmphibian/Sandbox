--yes this has some flaws, but it's more than good enough for what we need
function serialtable(datatable)
	local out=""
	for i,v in pairs(datatable) do
		out=out..string.format("%s\x0F%s\x0E",i,v)
	end
	return out
end

function deserialtable(datastr)
	local out={}
	for e in datastr:gmatch("[^\x0E]+") do
		s=e:find("\x0F")
		if s then
			local key=e:sub(1,s-1)
			key = tonumber(key) or key
			local value=e:sub(s+1,#e)
			value = tonumber(value) or value
			out[key]=value
		end
	end
	return out
end