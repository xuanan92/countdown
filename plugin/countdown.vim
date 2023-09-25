" Command countdown for plugin
command! -nargs=1 Countdown           lua require('countdown').countdown(<args>)
command!          Countreset          lua require('countdown').countreset()
command! -nargs=1 Countadd           lua require('countdown').countadd(<args>)
