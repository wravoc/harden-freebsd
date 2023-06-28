June 23, 2023
* 64bit ASLR setting was reverted back to 32bit enable as 64bit is enabled by default.
* `kern.randompid` works better if the number is manually set over 100 and is a prime [(*)](https://reviews.freebsd.org/transactions/detail/PHID-XACT-DREV-76pds6dxlcy5er6/)

June 27, 2023
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