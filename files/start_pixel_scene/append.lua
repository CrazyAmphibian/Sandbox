local text,file
file=ModTextFileGetContent("mods/sandbox_mode/files/start_pixel_scene/scene_loader.xml")
	
	
text= ModTextFileGetContent( "data/biome/_pixel_scenes.xml" )

if text then
	text = string.gsub( text, '</mBufferedPixelScenes>', file.."\n</mBufferedPixelScenes>" )
	ModTextFileSetContent( "data/biome/_pixel_scenes.xml", text )
else
error("TEXT LOADING FAILED IN data/biome/_pixel_scenes.xml")
end

text= ModTextFileGetContent( "data/biome/_pixel_scenes_newgame_plus.xml" )
if text then
	text = string.gsub( text, '</mBufferedPixelScenes>', file.."\n</mBufferedPixelScenes>" )
	ModTextFileSetContent( "data/biome/_pixel_scenes_newgame_plus.xml", text )
else
error("TEXT LOADING FAILED IN data/biome/_pixel_scenes_newgame_plus.xml")
end

