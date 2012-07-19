#!/bin/bash 
source cgi-lib/main
source cgi-lib/connect
source cgi-lib/show


_header


_menu

test_dir ${_TMP} # > /dev/null 2>&1

if [ $CMD ]
then
  case "$CMD" in
    _update_esxi)
#      echo "Output of _update_esxi :<pre>"
      _update_esxi
#      echo "</pre>"
      ;;

    _show_all_vms_on_esxi)
      #echo "Output of _show_all_vms_on_esxi :<pre>"
#      echo "Output of _show_all_vms_on_esxi :"
      _show_all_vms_on_esxi
#      echo "</pre>"
      ;;

    *)
      echo "Unknown command $CMD<br>"
      ;;
  esac
fi

_footer

