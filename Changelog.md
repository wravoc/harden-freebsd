## August 22, 2023
* Removed devcpu-data-amd as the re-worked port installs both AMD and Intel with command `devcpu-data`
    * https://cgit.freebsd.org/ports/commit/?id=bc7829212d153aeff69b439d08e2e3001ef88ba3

## August 20, 2023
* Printing clean-up
* Fixed error in microcode matching
* Fixed Virtual Machine vs Bare Metal c shell bug in string matching

## August 19, 2023
* Zenbleed_workdaround.csh fixes
    * at reminder fixes
    * CPU Model detection fixed
* AMD Threadripper Pros are still not being detected properly

## August 13, 2023
* Updated to give notice that no Zenbleed affected CPU was found.

## August 11, 2023
* The rc script has been updated for better performance and stability 
    * There is no positive value cases I can find for removing the chicken-bit during operation which on the contrary may produce unexpected results as with other workarounds of this type
    * Rebooting without the rc script running returns the OS to an unset chicken-bit state which obviates the need to have a `rc` chicken-bit removal function. 
        * The user chooses the workaround or not without the rc script making available CPU state changes while in operation possibly inducing kernel crashes
        * Simply using the `remove` argument and rebooting will return the AMD Zenbleed vulnerability -> MSR state to default
* Fixed Syntax errors and word clarity in the main workaround file
* Added a prompted reminder function using `at` to create a file in the home directory reminding the user to use the official patch due at that time and remove the workaround
* Changed the user text notice after a microcode update for better security and stability
    1. Rebooting once should show clean startup with new microcode but still keep the tools in case of reversion
    2. Use the `clean` function to remove the conf directives that load the still loaded promiscuous cpu tools
    3. Rebooting again to load without promiscuous cpu tools

## August 8, 2023
* `settings.ini`
    * `microcode_update_enable` set to "YES" in preparation for Zenbleed and Downfall Updates
* AMD Zenbleed mitigation script was added


## June 28, 2023
* Changed requirements to be 13.1, 13.2 as this is when most security directives were added
* Remove much conf syntax verification to work on all FreeBSD confs instead of just default installs
* Reverted 64bit ASLR protections to 32bit since these were on by default since 13.1
* `hw.mds_disable` was set at 3, AUTO
* Removed `vm.pmap.pti = "1"` since this was on by default


## June 27, 2023
* FreeBSD hardening script /usr/libexec/bsdinstall/hardening sets `security.bsd.allow_destructive_dtrace` is formatted improperly with the flag without quotes as in `/boot/defaults/loader.conf` and man. Script sets it properly.
* Test DTrace hardening: Using all 3 commands should result in `Permission denied` or `Destructive actions not allowed`:
    * `dtrace -wn 'tcp:::connect-established { @[args[3]->tcps_raddr] = count(); }'`
    * `dtrace -wqn tick-1sec'{system("date")}'`
    * `dtrace -qn tick-1sec'{system("date")}'`
* New setting `vm.pmap.pti = 0`
* Setting `kern.securelevel` to `0` has no effect as FreeBSD will increment to 1 disallowing script execution. README changed to reflect this.
* Error message conformity and clarity improvement.
* Script now exits any time it restores a file to prevent partial writes and locked files.
* Some sysctl.conf settings moved over to loader.conf section for better security


## June 23, 2023
* 64bit ASLR setting was reverted back to 32bit enable as 64bit is enabled by default.
* `kern.randompid` works better if the number is manually set over 100 and is a prime [(*)](https://reviews.freebsd.org/transactions/detail/PHID-XACT-DREV-76pds6dxlcy5er6/)
