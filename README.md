# Harden FreeBSD 

![](images/harden-freebsd-logo.jpg)

FreeBSD officially defaults to [Permanently Insecure Mode](https://man.freebsd.org/cgi/man.cgi?query=security&sektion=7&manpath=freebsd-release#SECURING_THE_KERNEL_CORE,_RAW_DEVICES,_AND_FILE_SYSTEMS). This script will duplicate all the hardening settings run by `/usr/libexec/bsdinstall/hardening` and much more. Any directive can be set and re-set with a customizable `settings.ini` for administering, tuning, and easier jail management. All existing entries in all confs will remain untouched unless they are modified in the settings file.

This script is also targeted to new users of FreeBSD so that they may leverage years of security contributions by the entire BSD community across all spectra, implemented on their system in seconds.

Each of the security settings was researched, assessed, and chosen as a set of mitigations for maximizing threat reduction while minimizing restriction of system capability and availability.


---

## Main Features

* Makes backups of `rc.conf`, `sysctl.conf`, `login.conf`, and `loader.conf` on first run
* Disables Sendmail completely, recommend `pkg install opensmtpd`
* Sets passwords to blowfish encryption
* Sets passwords to expire at 120 days
* Removes `other` write permissions from key system files and folders
* Allows only root for `cron` and `at`
* Primitive flag verification catches simple errors
* Modularizable within other tools
* Automate any shell command
* System Logging to `/var/log/messages` and Script Logging to `/var/log/harden-freebsd.log`
* Pretty prints color output of script execution to console while running

---


### Includes
* Desktop Wallpapers as a special gift to users of the Software
* Directory (Hier)archy Visual Map, PDF, in /docs
* robots.txt to deny AI use of your intellectual property, with inline `nginx.conf` format and commented section for use as a plain txt file
* Robust firewall settings for pf

---

### New Features in 3.1
* A package audit is automatically run identifying vulnerabilities in installed packages and saves to file `pkg-audit-report`
* Security Tiering has been introduced with additional settings files minimal and server
* A script argument can be given naming the settings ini file you wish to use, mainly to toggle between secure and minimal, otherwise settings.ini is used
    * A minimum security and high performance server tier ini files are now included
    * Adjust as neccessary or make your own set
* A script argument of "restore" is now available, overwriting the changed files with the original files saved during first run
    * rc.conf, sysctl.conf, and loader.conf are restored. `login.conf` and the password changes are not reversed, neither are file permissions or at, cron adjustments
    * `minimum.ini` does not have `first_run = True` set as it is expected to usually run secure. Therefore if using this ini file first, **backups will not be made**.
* New wallpapers have been added with the assistance of [LimeWire BlueWillow v4](https://limewire.com/features/bluewillow-ai) Artificial Intelligence image generator.

---


## Known Incompatibilities (Insecure) 09/7/2023
* **VM**: 
    * VirtualBox Shared Folders
* **Workstation**: 
    * **Firefox, Chromium** explicitly use [shared memory](https://www.usna.edu/Users/cs/crabbe/SI411/current/security/memory.html) allowing data access between private and non-private windows, tabs as well as other currently running apps.
        * Conflicts with `kern.elf64.allow_wx` 
    * Linux Binary Compatibility
* **Server**: Nginx


### Verified Compatible
* **Workstation**: 
    * Librewolf, Qutebrowser, Transmission, Evolution, RhythmBox, VLC, Abiword, Gimp, Inkscape, Spacemacs, Git
* **Server**: 
    * Apache (w/o memcache), OpenSMTPD, MariaDB `have_dynamic_loading=YES` (with plugins)


---


## FreeBSD Security Advisories
https://www.freebsd.org/security/advisories/

**FreeBSD Update Procedure**

    ```
    root@freebsd:~# freebsd-update fetch
    root@freebsd:~# freebsd-update install
    root@freebsd:~# shutdown -r +10min "Rebooting for a security update"
    ```

### Downfall Intel CPU Vulnerability
* https://downfall.page/
    * Skylake and Kaby Lakes are also now tested as vulnerable
    * Computing devices based on Intel Core processors from the 6th Skylake to (including) the 11th Tiger Lake generation are affected.
    * [Vulnerability Checker](https://github.com/flowyroll/downfall/tree/main/POC/gds_spy)
    * **Mitigation**: Intel Microcode Update Expected 


### FreeBSD 14.0 Security Changes
* New [Mitigations Manual](https://man.freebsd.org/cgi/man.cgi?query=mitigations&sektion=7&format=html)
* New Kernel Address Sanitizer
    * [KASAN](https://man.freebsd.org/cgi/man.cgi?query=kasan&sektion=9&format=html) is	a subsystem which leverages compiler instrumentation to	detect invalid memory accesses in the kernel.
* The **Zenbleed bug affecting AMD Zen2 processors is now automatically mitigated** (via chicken bit), preventing misbehavior and data leaks on affected machines. If needed, applying the mitigation can be manually controlled via the machdep.mitigations.zenbleed.enable sysctl(8) knob. Please consult the new [mitigations(7)](https://man.freebsd.org/cgi/man.cgi?query=mitigations&sektion=7&format=html) manual page for more information.
* Position Independent Executable (PIE) support enabled by default on x64
* Address Space Layout Randomization (ASLR) is enabled by default on x64
    * To disable for a single invocation, use the [proccontrol(1)](https://man.freebsd.org/cgi/man.cgi?query=proccontrol&sektion=1&format=html) command: `proccontrol -m aslr -s disable command.`
    * To disable ASLR for all invocations of a binary, use the [elfctl(1)](https://man.freebsd.org/cgi/man.cgi?query=elfctl&sektion=1&format=html) command: `elfctl -e +noaslr file`
* A workaround has been implemented for a hardware page invalidation problem on Intel Alder Lake (twelfth generation) and Raptor Lake (thirteenth generation) hybrid CPUs.
* The default mail transport agent (MTA) is now the Dragonfly Mail Agent.
* Support has been added to the kernel crypto for the XChaCha20-Poly1035 AEAD cipher.
* The process visibility policy controlled by the `security.bsd.see_jail_proc` sysctl(8) knob was hardened.
* The process visibility policy controlled by the `security.bsd.see_other_gids` sysctl(8) knob was fixed to consider the real group of a process instead of its effective group when determining whether the user trying to access the process is a member of one of the process' groups.

---

## Additional Software

* Scripts included to verify the implementation. Run before and after the hardening.
    * Kernel vulnerability diagnosis provided by [Stéphane Lesimple's](https://github.com/speed47) spectre-meltdown-checker
        * `cd vendor`
        * `chmod 750 spectre-meltdown-checker.sh`
        * `sudo ./spectre-meltdown-checker.sh`
        * You should only be left with the MCEPSC, Machine Check Exception on Page Size Change Vulnerability, [CVE-2018-12207](https://www.freebsd.org/security/advisories/FreeBSD-SA-19:25.mcepsc.asc)
    * MMAP, MProtect vulnerability diagnosis provided by [u/zabolekar](https://www.reddit.com/r/BSD/comments/10isrl3/notes_about_mmap_mprotect_and_wx_on_different_bsd/)
        * `cd util`
        * `cc mmap_protect.c` 
        * `./a.out`
        * You should have two successes

---


---
# Main Details

## Requirements
* FreeBSD 14.0
* Python 3.9.16


## Installation

**WARNING: Once kernel level 1 is set by this script, you will not be able to modify these confs again with this script until it is set to -1 and rebooted!**

* Set `kernlevel = -1` if you want to test various setting groups with your applications and network
* Customize `settings.ini`  to whatever is needed, the script will change the directive to your flag
* Set permissions `chmod 750 harden-freebsd.py` to prevent shell injection from another account or process
* Set permissions `chmod 640 settings.ini` to prevent shell injection from another account or process
* No `settings.ini` section can be entirely commented out nor be completely empty
* `sudo ./harden-freebsd.py`


## Conf File Verification

`kern.vty = "vt"`

This script does primitive verification of the confs flags in strict accordance with system man. Many online tutorials even on the FreeBSD family of websites do not use the proper syntax. Check the log for any validation failures. Use proper syntax, remove the syntax checking lines 241-261, or rewrite the regular expression to make a new check suitable for you.

* For `/etc/sysctl.conf` the script checks for no quotes
* For `/boot/loader.conf` the script strictly verifies syntax from man and `/boot/defaults/loader.conf` syntax
    * All directives in these sister confs must be in quotes

If you do get stuck in read-only single-user mode and need to correct a configuration file then use:

```sh
zfs set readonly=false zroot
zfs mount -a
```

## Customization

#### pf.conf
pf is now enabled in `settings.ini` by default but not in `minimal.ini` or `server.ini`. You will need to edit the macros with your interface, SSH port, and IP addresses before use. `admin_ips` is used by default and will take only one IP address instead of a list, but `admin_ip_range` is included for convenience. If you will be using the range macro instead of the default make sure to edit line 108 changing `admin_ips` to `admin_ip_range`. Redis is configured to be localhost only.


#### Backups

The very first time the script is run it will make copies of `rc.conf`, `sysctl.conf`, `login.conf`, and `loader.conf` named `rc.conf.original` etc. If you've already done this yourself you may want to rename or move those files. After the script is once run, it sets that field to false and no longer makes backups. If you would like you can set `settings.ini` section `[SCRIPT]`option `first_run` to `True` with capital `T` to make new backups at any time after you've renamed the original backups or the script will overwrite them.


#### Chmod-ability

The set of files needed to be secure changed and changed throughout testing and so it ended up as a shell command but an error checked function was provided for the administrator programmer to use instead of appending to the long list in `settings.ini` section `[FILESEC]` if you wish or to work with other software.

Those files are:

`etc/ftpusers /etc/group /etc/hosts /etc/hosts.allow /etc/hosts.equiv /etc/hosts.lpd /etc/inetd.conf /etc/login.access /etc/login.conf /etc/newsyslog.conf /etc/rc.conf /etc/ssh/sshd_config /etc/sysctl.conf etc/syslog.conf /etc/ttys /etc/crontab /usr/bin/crontab /usr/bin/at /usr/bin/atq /usr/bin/atrm /usr/bin/batch /var/log`

#### Secure Password Settings

The newly applied settings will not take effect until you reset your password.

---

#### Automatic Jail Lockdown/Management Strategies

1. Set the correct paths to jailed confs in `harden-freebsd.py` lines 32-38 and run for each jail.
2. Copy software to `/root` and have jail start this script at reboot and all settings will be updated upon next reboot. To update all jails simply copy `settings.ini` with your own copy script to all appropriate locations for uptake. 

`crontab -e`

`@reboot /path/to/harden-freebsd.py`

3. Have all jails pointing to the same rc script via `exec.start` and set paths in the script pointing to the same location modified by the script paths. 
4. Add new jail specific entires to `settings.ini [SYSTEM]` section for sysctl.conf update
   - `security.jail.* = 0`
5. Use multiple copies of the script and settings.ini for each jail
6. Put it in your template


---


# Setting Descriptors
**Startup**

* `kern_securelevel_enable = "YES"`
    * Enable access to other than permanently insecure modes
* `microcode_update_enable = "YES"`
    * Allow CPU microcode/firmware updates
* Disable Mail Transport Agent
* `syslogd_flags="-ss"`
    * Disallow syslogd to bind to a network socket
* `clear_tmp_enable = "YES"`
    * Clear the /tmp directory on reboot
* `icmp_drop_redirect="YES"`
    * Disallow redirection of ICMP (ping, echo)
* `inetd_enable = "NO"`
    * Disallow Network File System to share directories over the network
* `portmap_enable = "NO"`
    * Disallow portmapping since Network File Systems is disallowed
* `update_motd = "NO"`
    * Disallow computer system details from being added to /etc/motd on system reboot

**System**

* `kern.securelevel = 1` [(*)](https://man.freebsd.org/cgi/man.cgi?securelevel)
    * The system immutable and system append-only flags may
	   not be turned off; disks for	mounted	file systems, /dev/mem and
	   /dev/kmem may not be	opened for writing; /dev/io (if	your platform
	   has it) may not be opened at	all; kernel modules (see kld(4)) may
	   not be loaded or unloaded.  The kernel debugger may not be entered
	   using the debug.kdb.enter sysctl.  A	panic or trap cannot be	forced
	   using the debug.kdb.panic, debug.kdb.panic_str and other sysctl's.
* `security.bsd.see_other_uids = 0`
    * Disallow users from seeing information about processes that are being run by another user (UID)
* `security.bsd.see_other_gids = 0` [(*)](https://docs.freebsd.org/en/books/handbook/mac/#mac-policies)
    * Disallow users from seeing information about processes that are being run by another group (GID)
* `security.bsd.see_jail_proc = 0` (Sysctl MIB Entry `sysctl -a | grep security.bsd`)
    * Disallow non-root users from seeing processes in jail
* `security.bsd.unprivileged_read_msgbuf = 0` (Sysctl MIB Entry `sysctl -a | grep security.bsd`)
    * Disallow non-root users from reading system message buffer
* `kern.randompid = 107` [(*)](https://wiki.freebsd.org/DevSummit/201308/Security)
    * Force kernel to randomize process ID's using above salt value instead of sequential
* `net.inet.ip.random_id = 1`
    * Randomize IP packet ID
* `net.inet.ip.redirect = 0` 
    * Disallow ICMP host redirects
* `net.inet.tcp.always_keepalive = 0`
    * Disallow keeping open idle TCP connections. This may need to be changed if you are serving
* `net.inet.tcp.blackhole = 2` +(UDP)[(*)](https://man.freebsd.org/cgi/man.cgi?query=blackhole)
    * Packets that are received on a closed port will not initiate a reply
* `net.inet.tcp.path_mtu_discovery = 0` [(*)](https://man.freebsd.org/cgi/man.cgi?query=tcp&sektion=4)
    * Disallows TCP to determine the minimum MTU size on any network that is currently in the path between two hosts
* `net.inet.icmp.drop_redirect = 1`
    * Pairs with rc.conf startup, as once enabled, it is then set
* `net.inet6.icmp6.rediraccept = 0`
    * Disable ping IPv6 redirection mitigating ICMP attacks 
    * Set to 1 if using FreeBSD as network appliance
* `net.inet.tcp.drop_synfin` [(*)](https://www.juniper.net/documentation/us/en/software/ccfips22.2/cc-security_srx5000/cc-security/topics/task/configuring-tcp-syn-fin-attack.html)
    * Mitigates probe scans and has positive impact against DoS/DDoS attacks
    * Quadhelion Engineering [Research](https://www.quadhelion.engineering/articles/freebsd-synfin.html) on this setting
* `hw.mds_disable = 3` [(*)](https://www.kernel.org/doc./html/latest/arch/x86/mds.html)
    * Enable Microarchitectural Data Sampling Mitigation version `VERW`
    * Change value to `3` (AUTO) if using a Hypervisor without MDS Patch
* `hw.spec_store_bypass_disable = 1` [(*)](https://handwiki.org/wiki/Speculative_Store_Bypass)
    * Disallow Speculative Bypass used by Spectre and Meltdown
* `kern.elf64.allow_wx = 0` [(*)](https://www.ibm.com/docs/en/aix/7.2?topic=memory-understanding-mapping)
    * Disallow write and execute for shared memory
**SERVER.INI only**
Common network tuning values to increase performance and alleviate congestion, useful against DoS/DDoS attacks on high bandwidth application servers
* `kern.ipc.maxsockbuf=67108864`
* `net.inet.tcp.sendbuf_max=67108864`
* `net.inet.tcp.recvbuf_max=67108864`
* `net.inet.tcp.sendbuf_auto=1`
* `net.inet.tcp.recvbuf_auto=1`
* `net.inet.tcp.sendbuf_inc=16384`


**Kernel**
* `security.bsd.allow_destructive_dtrace = "0"`
    * Disallow DTrace to terminate processes
    * Test DTrace hardening: Using all 3 commands should result in `Permission denied` or `Destructive actions not allowed`:
    * `dtrace -wn 'tcp:::connect-established { @[args[3]->tcps_raddr] = count(); }'`
    * `dtrace -wqn tick-1sec'{system("date")}'`
    * `dtrace -qn tick-1sec'{system("date")}'`
* `hw.ibrs_disable = "3"` [(*)](https://wiki.freebsd.org/SpeculativeExecutionVulnerabilities)
    * Prevent Spectre and Meltdown CPU Vulnerabilities, 3 for AUTO


---

### January 17, 2024 Changelog
*If you are on FreeBSD 13.2 download the 3.0.1 release tag*

* pf enabled by default
* ZenBleed workaround removed
* 32bit protections removed


---


*Full [Changelog](Changelog.md)*

---

## FreeBSD Laptop Picks
https://wiki.freebsd.org/Laptops/

* Have every check box or insignificant issues*
* Bigger than 13" Screen
* Made within last 8 years

&#127775; [Gigabyte Aero 15X](https://wiki.freebsd.org/Laptops/Gigabyte_Aero_15X)

&#9734; [HP EliteBook 1040 G3](https://wiki.freebsd.org/Laptops/HP_EliteBook_1040_G3)*

[Thinkpad T550](https://wiki.freebsd.org/Laptops/Thinkpad_T550) and W550s

&#11088; [Thinkpad T495](https://wiki.freebsd.org/Laptops/Thinkpad_T495)

* T495*s* (lesser model, Vega 8 Graphics instead of 10)

[Thinkpad T490](https://wiki.freebsd.org/Laptops/Thinkpad_T490s)

* T490*s* (lesser model)


#### Special Mentions
&#127776; "Think Penguin" **Penguin T4** can be requested to have FreeBSD Pre-Installed
* 10-Core Intel i5-1335U processor (up to 4.6GHz)
* 15.6" Screen
* User replaceable battery
* Intel® Iris® Xe Graphics
* 64GB RAM available
* 4TB NVME SDD HDD available

Lenovo Legion 5 15ACH6H 
* WiFi driver supported in Linux 6.5, expected compatibility in FreeBSD 14.0 release

---


## License Summary

### Software
Non-Commercial usage, Human Intelligence only, retain and forward author and license data. Modify existing code as needed up to 25% while allowing unlimited new additions. The Software may use or be used by other software.


### Digital Art
All Digital Artists and Original Digital Art automatically receives robust International Copyright protections. 
* Supplemental License [here](digital%20art/Quadhelion%20Engineering%20Universal%20Digital%20Art%20License.md)
* QHE Wallpapers meet the [FreeBSD Foundation Trademark Usage Terms and Conditions](https://freebsdfoundation.org/legal/trademark-usage-terms-and-conditions/) where most FreeBSD digital art does not.
* An original digital art creation containing the FreeBSD Logo under T&C, the larger work is thus automatically copyrighted worldwide and may not be distributed, shared, or altered. 
* FreeBSD Foundation Members, Employees, and Associates are exempt from Digital Art restrictions.



## Security Guidelines

Since this Software uses shell commands it is required to place it in a secure directory with permissions on the **parent** directory to have no permissions for `other` /all/world group to write or *execute* and **no network access**. 

Please follow [these guidelines](/docs/SECURITY.md) should you find a vulnerability not addressed in the audit.


## Statement of Security: 

* **Risk** - Low
* **Impact** - Medium

This script has no networking, accesses no sockets, and uses only standard libraries.

Although this script is using `subprocess.run(shell=True)` the only possibility of shell injection is from the paths customized by the Licensee or unauthorized access to the filesystem the script resides on in order to perform unauthorized modifications to `settings.ini`or the Software which is not a vulnerability of the Software. 

### Latest Development Version

[Quadhelion Engineering Code Repository](https://quadhelion.dev)



![quadhelion engineering logo](images/quadhelionEngineeringIcon.jpg)
