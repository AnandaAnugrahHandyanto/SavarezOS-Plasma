var wallpaper = "/usr/share/savarez/savarez-wallpaper.png";

var desktops = desktopsForActivity(currentActivity());
var d = desktops[0];

d.wallpaperPlugin = "org.kde.image";
d.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
d.writeConfig("Image", "file://" + wallpaper);
