#!/usr/bin/env sh


#// set variables

scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"
rofiConf="${confDir}/rofi/themeselect.rasi"
[ ! -d "${hydeThemeDir}" ] && echo "ERROR: \"${hydeThemeDir}\" does not exist" && exit 0
get_themes


#// scale for monitor x res

x_monres=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
monitor_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')
x_monres=$(( x_monres * 17 / monitor_scale ))


#// set rofi override

elem_border=$(( hypr_border * 3 ))
r_override="element{border-radius:${elem_border}px;} listview{columns:6;spacing:100px;} element{padding:0px;orientation:vertical;} element-icon{size:${x_monres}px;border-radius:0px;} element-text{padding:1em;}"


#// launch rofi menu

currentWall="$(basename "$(readlink "${hydeThemeDir}/wall.set")")"
get_hashmap "${hydeThemeDir}" "${wallAddCustomPath}"

rofiSel=$( for indx in "${!wallHash[@]}" ; do
    rfile="$(basename "${walList[indx]}")"
    echo -en "${rfile}\x00icon\x1f${thmbDir}/${wallHash[indx]}.sqre\n"
done | rofi -dmenu -theme-str "${r_override}" -config "${rofiConf}" -select "${currentWall}")


#// apply wallpaper

if [ ! -z "${rofiSel}" ] ; then
    get_hashmap "$(find "${hydeThemeDir}" "${wallAddCustomPath}" -type f -name "${rofiSel}")"
    "${scrDir}/swwwallpaper.sh" -s "${walList[0]}"
    notify-send -a "t1" -i "${thmbDir}/${wallHash[0]}.sqre" " ${rofiSel}"
fi

