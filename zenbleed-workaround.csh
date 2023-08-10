#!/bin/tcsh -f

# Quadhelion Engineering
# elias@quadhelion.engineering
# https://www.quadhelion.engineering
# https://got.quadhelion.engineering
# License: QHELP-OME-NC-ND-NAI https://www.quadhelion.engineering/QHELP-OME-NC-ND-NAI.html


# Argument clean 
# Removes all conf directives, suitable for use after a microcode update where no workaround was ever used
#
# Argument remove
# Removes the workaround including rc script and cpucontrol loading


set ZenBleeders = ( "Ryzen 3 3100" "Ryzen 3 3300X" "Ryzen 3 4100" "Ryzen 3 4300G" "Ryzen 3 4300GE" "Ryzen 4700S" "Ryzen 5 3500" "Ryzen 5 3500X" "Ryzen 5 3600" "Ryzen 5 3600X" "Ryzen 5 3600XT" "Ryzen 5 4500" "Ryzen 5 4600G" "Ryzen 5 4600GE" "Ryzen 7 3700X" "Ryzen 7 3800X" "Ryzen 7 3800XT" "Ryzen 7 4700G" "Ryzen 7 4700GE" "Ryzen 9 3900" "Ryzen 9 3900X" "Ryzen 9 3900XT" "Ryzen 9 3950X" "Ryzen 3 4300U" "Ryzen 3 5300U" "Ryzen 3 7320U" "Ryzen 5 4500U" "Ryzen 5 4600H" "Ryzen 5 4600HS" "Ryzen 5 4600U" "Ryzen 5 4680U" "Ryzen 5 5500U" "Ryzen 5 7520U" "Ryzen 7 4700U" "Ryzen 7 4800U" "Ryzen 7 4980U" "Ryzen 7 5700U" "Ryzen 9 4900H" "Ryzen 9 4800H" "Ryzen 9 4800HS" "Ryzen 9 4900HS" "Ryzen Threadripper 3960X" "Ryzen Threadripper 3970X" "Ryzen Threadripper 3990X" "Ryzen Threadripper Pro 3945WX" "Ryzen Threadripper Pro 3955WX" "Ryzen Threadripper Pro 3975WX" "Ryzen Threadripper Pro 3995WX" ) 

set microcodes = ( "00830F10" "cpu00830F10_ver0830107A_2023-05-17_D7882D6C.bin" "008A0F00" "cpu008A0F00_ver08A00008_2023-06-15_FC8F1957.bin" "00A00F10" "cpu00A00F10_ver0A001079_2023-06-09_37DED030.bin" "00A00F11" "cpu00A00F11_ver0A0011D1_2023-07-10_254BC19E.bin" "00A00F12" "cpu00A00F12_ver0A001234_2023-07-10_16B9C44F.bin" "00A10F11" "cpu00A10F11_ver0A10113E_2023-06-20_4840C55C.bin" "00A10F12" "cpu00A10F12_ver0A10123E_2023-06-20_4EE5C2BB.bin" "00AA0F01" "cpu00AA0F01_ver0AA00116_2023-06-19_BCD5C29B.bin" "00AA0F02" "cpu00AA0F02_ver0AA00212_2023-06-19_6C81D673.bin" )

set check_cpucontrol = `grep -m1 cpuctl_load /boot/loader.conf`

if ( "$1" == "" ) then
    printf "\n********************\033[38;5;75m Base Mode \033[0;0m************************\n"
    printf "\033[1mAvailable modes:\033[0m \033[38;5;208mclean\033[0;0m or \033[38;5;208mremove\033[0;0m \n"
    printf "*******************************************************\n\n"
else if ( "$1" == "clean" ) then
    printf "\n*******************\033[38;5;75m Clean Mode \033[0;0m************************\n"
    printf "*******************************************************\n\n"
    goto clean
else if ( "$1" == "remove" ) then
    printf "\n*******************\033[38;5;75m Remove Mode \033[0;0m***********************\n"
    printf "*******************************************************\n\n"
    goto remove
endif


printf "\n*******************************************************\n"
printf "Verifying \033[1mcpucontrol\033[0m utility in loader.conf\n"
printf "*******************************************************\n\n"



if ( $check_cpucontrol == "" ) then
    printf "*******************************************************\n"
    printf "cpucontrol must be loaded to continue. \033[38;5;75mAdd it now?\033[0;0m\n"
    printf "*******************************************************\n\n"
    printf "\033[38;5;75m[yes/no]:\033[0m  "
    set cpuctl_answer =  $<:l:l:l
    switch ($cpuctl_answer)
        case 'yes':
            echo cpuctl_load=\"YES\" >> /boot/loader.conf
            printf "*********************\033[38;5;76m Success \033[0;0m*************************\n"
            printf "cputctl_load="YES" added to /boot/loader.conf\n"
            printf "*******************************************************\n\n"
            printf "\033[38;5;9mReboot required to run script again.\033[0m \n"
            exit 1
            breaksw
        case 'y':
            printf "cpuctl_load=\"YES\"\n" >> /boot/loader.conf
            printf "*********************\033[38;5;76m Success \033[0;0m*************************\n"
            printf "cputctl_load="YES" added to /boot/loader.conf\n"
            printf "*******************************************************\n\n"
            printf "\033[38;5;9mReboot required to run script again.\033[0m \n"
            exit 1
            breaksw
        case 'n':
            printf "Exiting...\n"
            exit 1
        case 'no':
            printf "Exiting...\n"
            exit 1
    endsw
else
    printf "******************\033[38;5;76m CPUCONTROL Found \033[0m*******************\n"
    printf "*******************************************************\n\n"
endif


set amd_sysctl_check = `sysctl hw.model | awk '{ print $2 }'`
set cpu_sys = `sysctl -a | grep -m1 Origin | awk '{ print $1 }' | sed -e 's#.*=\(\)#\1#'`
set CPU_id = `sysctl -a | grep -m1 Origin | awk '{ print $2 }' | sed -e 's#.*x\(\)#\1#' | tr "[a-z]" "[A-Z]" `


printf "*******************\033[38;5;75m FreeBSD sysctl \033[0;0m********************\n"  
printf "\033[1mCPU Manufacturer\033[0m: $amd_sysctl_check\n"
printf "\033[1mCPU Authenticity\033[0m: $cpu_sys\n"
printf "\033[1mCPU ID\033[0m: $CPU_id\n"
printf "*******************************************************\n\n"


printf "\n*******************************************************\n"
printf "Verifying CPU ID\n"
printf "*******************************************************\n\n"


set GenuineIntel = '0x756e65470x6c65746e0x49656e69'
set AuthenticAMD = '0x687475410x444d41630x69746e65'
set cpu_manufacturer = `(/usr/sbin/cpucontrol -i 0x0 /dev/cpuctl0 | awk '{ print $5 $6 $7 }')`
set cpu_id = `(/usr/sbin/cpucontrol -i 0x1 /dev/cpuctl0 | awk '{ print $4 }' | sed -e 's#.*x\(\)#\1#') | tr "[a-z]" "[A-Z]" `
set amd_rome_check = `sysctl -n hw.model | grep -o "Rome"`


if ( $amd_sysctl_check == "AMD" && $amd_rome_check == "" ) then
    set amd_model = `sysctl -n hw.model | awk '{ print $2, $3, $4 }'`
else if ( $amd_sysctl_check == "AMD" && $amd_rome_check == Rome ) then
    set amd_model = `sysctl -n hw.model | awk '{ print $2 }'`
endif


if ( $cpu_manufacturer == $GenuineIntel ) then
    set amd_check = false
    printf "*********************\033[38;5;75m CPUCONTROL \033[0;0m**********************\n"  
    printf "\033[1mCPU Manufacturer\033[0m: Intel\n"
    printf "\033[1mCPU ID\033[0m: $cpu_id\n"
    printf "*******************************************************\n\n"
else if ( $cpu_manufacturer == $AuthenticAMD ) then   
    set amd_check = true
    printf "*********************\033[38;5;75m CPUCONTROL \033[0;0m**********************\n"  
    printf "\033[1mCPU Manufacturer\033[0m: AMD\n"
    printf "\033[1mCPU ID\033[0m: $cpu_id\n"
    printf "\033[1mModel\033[0m: $amd_model\n"
    printf "*******************************************************\n\n"
else    
    printf "Could not identify CPU\n"
    printf "Exiting...\n\n"
    exit 1
endif


set vm_check = `sysctl -a | grep kern.vm_guest | awk '{ print $2 }'`

if ( $amd_sysctl_check == "AMD" &&  $amd_check == true ) then
	printf "********************\033[38;5;76m AMD CPU Found \033[0;0m********************\n"
    printf "*******************************************************\n\n"
else
    printf "******************\033[38;5;9m AMD CPU Not Found \033[0;0m******************\n"
    printf "Exiting...\n"
    printf "*******************************************************\n\n"
    exit 1
endif


printf "**********\033[38;5;75m Searching Matching CPU Updates \033[0;0m*************\n"  
printf "*******************************************************\n\n"

set count = 1
foreach micro_id ( $microcodes )
@ count = "$count" + 1
    if ( $cpu_id == $micro_id ) then
        set microcode_update = $microcodes[$count]
        printf "**************\033[38;5;75m Found Matching CPU Update \033[0;0m**************\n"  
        printf "\033[1m$microcodes[$count]\033[0m\n"
        printf "*******************************************************\n\n"
    endif
end

set count = 1
foreach model ( $ZenBleeders )
@ count = "$count" + 1
    if ( $amd_model == $model ) then
        set zenbleeding = true
    else
        set zenbleeding = false
    endif
end


if ( $amd_sysctl_check == "AMD" && $amd_model == "EPYC-Rome" ) then
    printf "****************\033[38;5;76m CPU Update Available \033[0;0m*****************\n"
    printf "Would you like to apply the AMD CPU microcode update?\n"
    printf "*******************************************************\n\n"
    printf "\033[38;5;75m[yes/no]:\033[0m \n"
    set microcode_answer =  $<:l:l:l

    switch ($microcode_answer)
        case 'yes':
            echo cpu_microcode_load=\"YES\" >> /boot/loader.conf
            printf cpu_microcode_name=\"/boot/firmware/$microcode_update\" >> /boot/loader.conf
            echo microcode_update_enable=\"YES\" >> /etc/rc.conf
            printf "*********************\033[38;5;76m Success \033[0;0m*************************\n"
            printf "cpu_microcode_load="YES" added to /boot/loader.conf\n"
            printf "cpu_microcode_name"" added to /boot/loader.conf\n"
            printf "microcode_update_enable="YES" added to /etc/rc.conf\n\n"
            printf "\033[1mInstalling Update Utilities:\033[0m\n"
            printf "pkg install devcpu-data-amd\n"
            printf "pkg install devcpu-data\n"
            printf "*******************************************************\n\n"
            pkg install devcpu-data-amd devcpu-data
            wget https://github.com/platomav/CPUMicrocodes/blob/master/AMD/$microcode_update
            cp $microcode_update /boot/firmware
            service microcode_update start
            printf "*********************\033[38;5;76m Success \033[0;0m*************************\n"
            printf "\033[1mSecurity Notice:\033[0m\n"
            printf "After update you should remove update utilities\n"
            printf "Please reboot and run sudo zenbleed_workaround.csh clean\n"
            printf "*******************************************************\n\n"
            exit 1
            breaksw
        case 'y':
            echo cpu_microcode_load=\"YES\" >> /boot/loader.conf
            printf cpu_microcode_name=\"/boot/firmware/$microcode_update\" >> /boot/loader.conf
            echo microcode_update_enable=\"YES\" >> /etc/rc.conf
            printf "*********************\033[38;5;76m Success \033[0;0m*************************\n"
            printf "cpu_microcode_load="YES" added to /boot/loader.conf\n"
            printf "cpu_microcode_name"" added to /boot/loader.conf\n"
            printf "microcode_update_enable="YES" added to /etc/rc.conf\n\n"
            printf "\033[1mInstalling Update Utilities:\033[0m\n"
            printf "pkg install devcpu-data-amd\n"
            printf "pkg install devcpu-data\n"
            printf "*******************************************************\n\n"
            pkg install devcpu-data-amd devcpu-data
            wget https://github.com/platomav/CPUMicrocodes/blob/master/AMD/$microcode_update
            cp $microcode_update /boot/firmware
            service microcode_update start
            printf "*********************\033[38;5;76m Success \033[0;0m*************************\n"
            printf "\033[1mSecurity Notice:\033[0m\n"
            printf "After update you should remove update utilities\n"
            printf "Please reboot and run sudo zenbleed_workaround.csh clean\n"
            printf "*******************************************************\n\n"
            exit 1
            breaksw
        case 'n':
            printf "Exiting...\n"
            exit 1
        case 'no':
            printf "Exiting...\n"
            exit 1
    endsw
else if ( $amd_sysctl_check == "AMD" && $zenbleeding )
    printf "Executing workaround\n"
    echo zenbleed_enable=\"YES\" >> /etc/rc.conf
    cp zenbleed-rc.sh /usr/local/etc/rc.d/
    chmod 755 /usr/local/etc/rc.d
    service zenbleed-rc.sh enable
    service zenbleed-rc.sh start
        if ( -e /usr/local/etc/rc.d/zenbleed_workaround)
            printf "*********************\033[38;5;76m Success \033[0;0m*************************\n"
            printf "Workaround Active \033[1mUpon Reboot\033[0m"
            printf "*******************************************************\n\n"
        endif
else if !( $vm_check == "" && $amd_model == "Rome") then
    printf "\n**********************\033[38;5;75m VM Found \033[0;0m***********************\n" 
    printf "\033[1mVirtual Machine\033[0m: $vm_check\n"
    printf "VM Hypervisors will not allow the ZenBleed workaround\n"
    printf "*******************************************************\n\n"
    printf "Exiting...\n\n"
    exit 1
endif


clean:
    printf "****************\033[38;5;76m Cleaning System Files \033[0;0m****************\n"
    printf "*******************************************************\n\n"
    sed -i .zen_backup '/^cpu_microcode_load/d' /boot/loader.conf
    sed -i .zen_backup '/^cpu_microcode_name/d' /boot/loader.conf
    set cpu_microcode_isloaded = cpu_microcode_load=\"YES\"
    set cpu_microcode_found = `grep -m1 cpu_microcode_load /etc/rc.conf`
        if !( $cpu_microcode_isloaded == $cpu_microcode_found) then
            printf "*********************\033[38;5;76m Success \033[0;0m*************************\n"
            printf "Conf directives removed\n"
            printf "*******************************************************\n\n"
        else
            printf "**********************\033[38;5;9m Error \033[0;0m**************************\n"
            printf "Unable to remove conf directives. Manually remove.\n"
            printf "*******************************************************\n\n"
        endif
    exit 1


remove:
    printf "*****************\033[38;5;76m Removing Workaround \033[0;0m*****************\n"
    printf "*******************************************************\n\n"
    service zenbleed-rc.sh onestop
    service zenbleed-rc.sh onedisable
    sed -i .zen_backup '/^cpuctl_load/d' /boot/loader.conf
    sed -i .zen_backup '/^zenbleed_workaround_enable/d' /etc/rc.conf
    rm /usr/local/etc/rc.d/zenbleed-rc.sh
    set cpuctl_isloaded = cpuctl_load=\"YES\"
        if ( $check_cpucontrol == "") then
            printf "*********************\033[38;5;76m Success \033[0;0m*************************\n"
            printf "Workaround removed and cpucontrol loading disabled\n"
            printf "*******************************************************\n\n"
        else
            printf "**********************\033[38;5;9m Error \033[0;0m**************************\n"
            printf "Unable to remove workaround. Manually remove.\n"
            printf "*******************************************************\n\n"
        endif
    exit 1

