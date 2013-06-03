#!/bin/bash 
source cgi-lib/main
source cgi-lib/connect
source cgi-lib/show


_header


_menu

test_dir ${_TMP} &> /dev/null 

if [ $CMD ]
then
  case "$CMD" in
    _update_esxi)
      _update_esxi
      ;;

    _show_all_vms_on_esxi)
      _show_all_vms_on_esxi
      ;;

    *)
      echo "Unknown command $CMD<br>"
      ;;
  esac
fi

_footer

