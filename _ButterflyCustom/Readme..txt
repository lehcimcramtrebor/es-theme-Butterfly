This folder allows you to customize various elements of the theme.
You must imperatively move it to the root of Batocera's "SHARE" partition or to the root of Retrobat's folder.

DON'T EDIT "wallpaper.m3u" or "video.m3u" FILES !! 

WALLPAPERS:

By default, this theme use scraped fanarts as wallpapers, but you can customise each system with your wallpapers.

Try to use wallpapers at your system resolution, if not, the theme will apply "minSize" function to enlarge image on smallest side to fit screen.

Files:

	- To use only one wallpaper put only a "wallpaper.jpg" file in folders named by theme name, examples: snes, megadrive,auto-favorites etc..

	- To use multiples wallpapers add "wallpaper-01.jpg", "wallpaper-02.jpg", "wallpaper-03.jpg" etc.. You can go up to "wallpaper-100.jpg".
	  System view will randomly display each image including "wallpaper.jpg" for 10 seconds.
	  Gamelist views will use only "wallpaper.jpg" file.
	
	- You can use "default_fanart.jpg" at root folder to use as default fanart in gamelists when no scrapes found.

	- You can use "default_wallpaper.jpg" at root folder to use as default wallpaper in system view when no fanarts found.
	
	- You can use "theme.jpg" at root folder to use only one background for all theme exept systems you have customized.

VIDEOS:

By default, this theme use scraped videos as system view presentation, but you can customise each system with yours.

Files:

	- To use only one video put only a "video.mp4" file in folders named by theme name, examples: snes, megadrive,auto-favorites etc..

	- To use multiples videos add "video-01.mp4", "video-02.mp4", "video-03.mp4" etc.. You can go up to "video-100.mp4".
	  System view will randomly play each videos including "video.mp4".

	  Be careful, if you do not customize the videos then delete the "video.m3u" file from the theme folder concerned to let theme display random videos.

SCROLL SOUNDS:

You can customize general scroll sound by using "scroll.wav" file at root of "_ButterflyCustom" folder, and you can customize
sounds of each gamelist with the same file placed in themes folders.