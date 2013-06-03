#!/bin/bash

# DIRS
BASE_dir=$(dirname ${0})
ROOT_dir="${BASE_dir}/.."
CFG_dir="${ROOT_dir}/configs"
TMP_dir="${ROOT_dir}/tmp"


for f in $(ls ${CFG_dir}/*.conf); do
    source ${f}

# MAIN varibles
############################################################################

# SETTINGS
_ESXI=$(basename ${f}|grep -P -o "[^/]*(?=\.[^\.]*$)")
#_EMAIL=achekunov@thumbtack.net
_EMAIL=sysadmins@thumbtack.net

# FILES
LST="${TMP_dir}/${_ESXI}_backup.lst"
LST_all="${TMP_dir}/${_ESXI}_backup.lst_all"
LST_excl="${CFG_dir}/${_ESXI}_backup.lst_excl"
#
SCRIPT="${BASE_dir}/ghettoVCB.sh"
SCRIPT_cfg_main="${CFG_dir}/ghettoVCB.cfg"
SCRIPT_cfg="${TMP_dir}/${_ESXI}_ghettoVCB.conf"

# COMMANDS
_LOGIN="${_ESXI_USER}@${_ESXI_HOST}"
_SSH="ssh -o BatchMode=yes -i ${_ESXI_KEY} $_LOGIN"
_SCP="scp -i ${_ESXI_KEY}"

#### PREPARE config for ghettoVCB
cat ${SCRIPT_cfg_main}                              > ${SCRIPT_cfg}
    echo "NFS_VM_BACKUP_DIR=${_ESXI}"               >> ${SCRIPT_cfg}
    echo "EMAIL_FROM=${_ESXI_USER}@${_ESXI}"        >> ${SCRIPT_cfg}

touch ${LST} ${LST_all} ${LST_excl}

#$_SSH vim-cmd vmsvc/getallvms | grep 'vmx-' | awk '{print $2 }' 
#echo "
#cat ${SCRIPT_cfg}
#_ESXI = ${_ESXI}
#_ESXI_USER = ${_ESXI_USER}
#_ESXI_HOST = ${_ESXI_HOST}
#_ESXI_KEY  = ${_ESXI_KEY}
#LST = ${LST}
#LST_all = ${LST_all}
#LST_excl = ${LST_excl}
#
#
#    "





# END MAIN varibles
############################################################################
# BEDIN

# Chck connection to ESXi
#ssh -o BatchMode=yes $_LOGIN id &> ${TMP_dir}/ssh_chk_${_ESXI_HOST}.log
${_SSH} id &> ${TMP_dir}/ssh_chk_${_ESXI_HOST}.log
    if [ $? -ne 0 ]
    then
        echo "Problem with connect to ${_ESXI_HOST}"
        cat ${TMP_dir}/ssh_chk_${_ESXI_HOST}.log | mail -s "Problem with connect to ${_ESXI_HOST}" "${_EMAIL}"
        continue
    fi



# Getting list all VM's
$_SSH vim-cmd vmsvc/getallvms | grep 'vmx-' | awk '{print $2 }' > $LST_all

# Creating baclup list for VMs

RESULT=$(wc -l $LST_excl | awk '{print $1}')
    if [ $RESULT -eq 0 ]
        then
            echo "$LST_excl is empty."
#            cat $LST_all  > $LST
            cat $LST_all  > $LST
        else
            echo "Exclude $LST_excl from $LST"
#            cat $LST_all | egrep -v "($(cat $LST_excl | awk '{printf $1"|"}' |sed -e 's/|$//g' ))" > $LST
            cat $LST_all | egrep -v "($(cat $LST_excl | awk '{printf $1"|"}' |sed -e 's/|$//g' ))" > $LST
    fi
set -x
# Copy prepared files to ESXi
$_SCP  $LST           $_LOGIN:/etc/backup.lst
$_SCP  $SCRIPT_cfg    $_LOGIN:/etc/backup.cfg
$_SCP  $SCRIPT        $_LOGIN:/bin/backup.sh

# Run backup's
$_SSH /bin/backup.sh -f /etc/backup.lst -g /etc/backup.cfg -l /tmp/ghettoVCB.log  &> /dev/null
#exit

# Download log
cat /dev/null > ${TMP_dir}/${_ESXI}-ghettoVCB.log
$_SCP   $_LOGIN:/tmp/ghettoVCB.log  ${TMP_dir}/${_ESXI}-ghettoVCB.log 



# Prepare email's
_FINAL_STATUS=$(grep -P -o '###### Final status:.*######' ${TMP_dir}/${_ESXI}-ghettoVCB.log | uniq)
_MAIL_SUBJ="Host: ${_ESXI} $(date +"%F %R") BackUP: ${_FINAL_STATUS}"

# Sending email's
grep -P -v 'Clone.*done' ${TMP_dir}/${_ESXI}-ghettoVCB.log | mail -s "${_MAIL_SUBJ}" "${_EMAIL}"

# RM files from ESXi
$_SSH rm /etc/backup.lst
$_SSH rm /etc/backup.cfg
$_SSH rm /bin/backup.sh
$_SSH rm /tmp/ghettoVCB.log

    ####
#exit
done
    ####


