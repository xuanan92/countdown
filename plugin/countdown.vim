" Command countdown for plugin
command! -nargs=1 Countdown           lua require('countdown').countdown(<args>)
command! -nargs=1 Countadd            lua require('countdown').countadd(<args>)
command!          Countreset          lua require('countdown').countreset()
