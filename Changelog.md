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
