var wallpaper = "/usr/share/savarez/savarez-wallpaper.png";

var plasma = desktopsForActivity(currentActivity());
var d = plasma[0];

d.wallpaperPlugin = "org.kde.image";
d.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
d.writeConfig("Image", "file://" + wallpaper);
