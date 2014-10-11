#!/bin/bash
# Change the background color of the Foundation 5 CSS files

# vim change-background.sh; ./change-background.sh custom-colorblind-1column/css/foundation.css
# vdiff custom-default-1column/css/foundation.css custom-colorblind-1column/css/foundation.css.dark
# ./change-background.sh custom-colorblind-1column/css/foundation.css; vdiff custom-default-1column/css/foundation.css custom-colorblind-1column/css/foundation.css.dark

export COLOR=black
echo Changing background color to $COLOR in $*
perl -pne 's{( background(?:-color)?: \s* ) white ( \s* ; )}{$1$ENV{COLOR}$2}xmsg' \
	$* > $*.dark

# button secondary, success, alert, also hard coded
# warning, info, disabled colors hard coded
# color white!
# color #333333
# label hard coded colors
# color #4d4d4d
# color #676767
# color #333333  span,label prefix
# border-color also hard coded
# select hard coded
# background-color #fafafa
# background-color #f3f3f3 hover
# background-color #dddddd disable
# color rgba 0 0 0 0.75
# error handling abide
# color white
# color #676767
# top bar
# color white
# color #888888 expanded
# color #333333
# background-color #555555
# background #272727
# color #777777
# breadcrumbs
# color #333333
# color #999999
# color #aaaaaa
# alert-box
# color white
# color #333333
# panel
# background #f2f2f2
# color #333333
# pricing table
# color #eeeeee
# color #f6f6f6
# color #333333
# background-color: white
# color #777777
# icon-bar
# color white
# tabs
# background-color #efefef
# color #222222
# background-color #e1e1e1
# background-color white
# pagination
# color #222222
# color #999999
# color white
# accordion
# color #222222
# code
# font - consolas -- profont!
# color #333333
# media print background color needed?
# reveal
# background-color white
# color #aaaaaa
# has-tip
# color #333333
# tap-to-close
# color #777777
# clearing-touch-label
# color #aaaaaa
# clearing-caption close
# color #cccccc
# progress
# background-color #f6f6f6
# sub-nav
# color #999999
# color #737373
# color white
# joyride-tip-guide
# background #333333
# color white
# color #777777 close-tip
# color #eeeeee close-tip hover
# joyride-expose-wrapper
# background-color white
# tab-bar
# color white
# ul.off-canvas-list
# color #999999
# rgba 255.255.255
# move-right etc
# -webkit-tap-highlight-color rgba 0,0,0
# left-submenu
# color #999999
# f-dropdown
# color #555555
# table
# color #222222
# keystroke
# background-color #ededed
# color #222222