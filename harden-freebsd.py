#!/usr/bin/env python

""" 
Harden FreeBSD system perms, settings.
Set and reset rc, sysctl, login, confs; set file perms, run shell commands
No arguments, only uses settings.ini file in the same directory.
Example: sendmail_enable = "NONE"
"""

__author__ = "Elias Christopher Griffin"
__url__ = "https://www.quadhelion.engineering"
__license__ = "QHELP-OME-NC-ND-NAI"
__copyright__ = "https://www.quadhelion.engineering/QHELP-OME-NC-ND-NAI.html"
__version__ = "2.0.2"
__date__ = "06/27/2023"
__email__ = "elias@quadhelion.engineering"
__status__ = "Production"



from pathlib import Path
from datetime import datetime
import os, re, subprocess, syslog, configparser, shutil, sys

_date = datetime.now()
date_time = _date.strftime("%m/%d/%Y, %H:%M")

config = configparser.ConfigParser()
config.read('settings.ini')


harden_freebsd_log = Path("/var/log/harden-freebsd.log")
rc_conf = Path("/etc/rc.conf")
sysctl_conf = Path("/etc/sysctl.conf")
loader_conf = Path("/boot/loader.conf")
login_conf = Path("/etc/login.conf")
cron_access = Path("/var/cron/allow")
at_access = Path("/var/at/at.allow")


backup_suffix = ".original"
rc_backup = rc_conf.with_name(rc_conf.name + backup_suffix)
sysctl_backup = sysctl_conf.with_name(sysctl_conf.name + backup_suffix)
loader_backup = loader_conf.with_name(loader_conf.name + backup_suffix)
login_backup = login_conf.with_name(login_conf.name + backup_suffix)



def exception_handler(func):
    def intake(*args, **kwargs):
        try:
            func(*args, **kwargs)
        except PermissionError as e:
            print(f"\n******************\033[38;5;1m Permissions \033[0;0m************************\n")
            print(f"Insufficient permissions {e}")
            print(f"*******************************************************\n")
        except OSError as e:
            print(f"\n********************\033[38;5;1m Locked \033[0;0m**************************\n")
            print(f"Perhaps file is busy, locked, process blocked, or raced:\n") 
            print(f"{e}")
            print(f"*******************************************************\n")
    return intake



# Write to either "syslog" (/var/log/messages) or "script" (/var/log/harden-freebsd.log)
@exception_handler
def writeLog(log_type, content):
    harden_freebsd_logwriter = open(harden_freebsd_log, "a")
    syslog.openlog("LOG_INFO")
    if log_type == "script":
        harden_freebsd_logwriter.writelines(content + os.linesep)
    elif log_type == "syslog":
            syslog.syslog(1, content)
    else:
        print(f"*******************************************************\n")
        print(f"\033[38;5;63m LOG: \033[0;0m {content}")
        print(f"*******************************************************\n")



# Make *.original backups of all files only once
if config['SCRIPT']['first_run'] == "True":
    try:
        harden_freebsd_log.touch()
        cron_access.touch()
        at_access.touch()
        rc_backup.write_bytes(rc_conf.read_bytes())
        sysctl_backup.write_bytes(sysctl_conf.read_bytes())
        loader_backup.write_bytes(loader_conf.read_bytes())
        login_backup.write_bytes(login_conf.read_bytes())
    except FileNotFoundError as e:
        error_path = Path(e.filename)
        print(f"\n********************\033[38;5;1m File Not Found \033[0;0m*******************")
        print(f"Filename: {error_path.parts}")
        print("*******************************************************\n")
    except PermissionError as e:
        print(f"\n******************\033[38;5;1m Permissions \033[0;0m************************\n")
        print(f"Insufficient permissions {e}")
        print(f"*******************************************************\n")
    except OSError as e:
        print(f"\n********************\033[38;5;1m Locked \033[0;0m**************************\n")
        print(f"Perhaps file is busy, locked, process blocked, or raced:\n") 
        print(f"{e}")
        print(f"*******************************************************\n")
    else:
        writeLog("syslog", "System file backups complete")
        with open('settings.ini', 'w') as configfile:
            config.set('SCRIPT', 'first_run', 'False')
            config.write(configfile)
        print(f"\n*********************\033[38;5;76m Success \033[0;0m*************************")
        print(f"\033[38;5;75mCreated: \033[0;0m")
        print(f" {cron_access.name}, {at_access.name} \n")
        print(f"\033[38;5;75mBackups Made: \033[0;0m")
        print(f" {rc_backup.name}, {sysctl_backup.name}")
        print(f" {login_backup.name}, {loader_backup.name} \n")
        print(f"*******************************************************\n")



# Read the system file content
try:
    rc_content = rc_conf.read_text(encoding="utf-8")
    sysctl_content = sysctl_conf.read_text(encoding="utf-8")
    login_content = login_conf.read_text(encoding="utf-8")
    loader_content = loader_conf.read_text(encoding="utf-8")
except FileNotFoundError as e:
    error_path = Path(e.filename)
    writeLog("script", "Error finding file " + error_path)
    print(f"\n*******************\033[38;5;1m File Not Found \033[0;0m********************")
    print(f"Filename: {error_path.name}")
    print(f"Directories used: {error_path.parts}\n")
    print("*******************************************************\n")
except PermissionError as e:
    print(f"\n******************\033[38;5;1m Permissions \033[0;0m************************\n")
    print(f"Permission to read/append {e}")
    print(f"{os.stat(rc_conf)}{os.linesep}")
    print(f"{os.stat(sysctl_conf)}{os.linesep}")
    print(f"{os.stat(loader_conf)}{os.linesep}")
    print(f"{os.stat(cron_access)}{os.linesep}")
    print(f"{os.stat(at_access)}{os.linesep}")
    print(f"{os.stat(login_conf)}{os.linesep}")
    print(f"*******************************************************\n")
else:
    print(
    f"{os.linesep}*********************\033[38;5;75m Running \033[0;0m*************************{os.linesep}"
    f"Loaded system files for read/append\n"
    f"*******************************************************{os.linesep}"
    )
finally:
    writeLog("syslog", "Hardening in progress")
    print(f"\n********************\033[38;5;75m Info Panel \033[0;0m***********************")
    print(f"Executing {__file__}")
    print(f"Executing {date_time}")
    print(f"*******************************************************\n")
    

# Main working class dealing with rc.conf and sysctl.conf
class Conf:
    def __init__(self, file, setting, flag):
        self.file = file
        self.setting = setting
        self.flag = flag
    
    # Changes the flag from whatever it is currently to flag in settings.ini
    def setConf(self):
        try:
            with open(self.file, 'r+', encoding="us-ascii") as file_content: 
                lines = file_content.readlines()
                for i, line in enumerate(lines):
                    if line.startswith(self.setting):
                        lines[i] = self.setting + "=" + self.flag + os.linesep
                        file_content.seek(0)
                        for line in lines:
                            file_content.write(line)
                            file_content.truncate()
                writeLog("script",  self.setting + " was set to " + self.flag)
        except OSError as e:
            print(f"\n********************\033[38;5;1m Locked \033[0;0m**************************\n")
            print(f"Perhaps file is busy, locked, process blocked, or raced:\n") 
            print(f"{e}")
            print(f"*******************************************************\n")
        else:
            print(f"\033[38;5;208m {self.setting} \033[0;0m changed to\033[38;5;208m {self.flag}\033[0;0m  in\033[38;5;75m {self.file}\033[0;0m ")
    
    # Appends at the end of a file a directive that was not present previously
    def addConf(self):
        try:
            with open(self.file, 'a') as file_content: 
                file_content.write(self.setting + "=" + self.flag + os.linesep)
                writeLog("script", self.setting + "=" + self.flag + " added")
        except OSError as e:
            print(f"\n********************\033[38;5;1m Locked \033[0;0m**************************\n")
            print(f"Perhaps file is busy, locked, process blocked, or raced:\n") 
            print(f"{e}")
            print(f"*******************************************************\n")
        else:
            print(f"\033[38;5;63m {self.setting} \033[0;0m added to \033[38;5;75m{self.file}\033[0;0m ")
    
    # Checks to see if the directive is already in the conf, returns True if present.
    def checkConf(self) -> bool:
        self.found = False
        try:
            with open(self.file, 'r') as file_content:
                lines = file_content.readlines()
                for i, line in enumerate(lines):
                    if line.startswith(self.setting):
                        self.found = True
                    else:
                        pass
            return self.found
        except OSError as e:
            print(f"\n********************\033[38;5;1m Locked \033[0;0m**************************\n")
            print(f"Perhaps file is busy, locked, process blocked, or raced:\n") 
            print(f"{e}")
            print(f"*******************************************************\n") 
    
    # Checks proper flag and equality syntax in rc.conf and sysctl.conf with first-boot 13.2 directives
    # May not work with advanced flags added later
    def verifyConf(self): 
        global conf_directives
        conf_directives = []
        sysctl_conf_verify = re.compile(r'[^\"]') # No quotes
        loader_rc_conf_verify = re.compile(r'^[\"].+[$\"]') # Pair of quotes
        try:
            with open(self.file, 'r+') as file_content:
                lines = file_content.readlines()
                for i, line in enumerate(lines):
                    partitioned_line = line.partition("=")
                    if line.isspace():
                        pass
                    elif line.startswith("#"):
                        pass
                    elif partitioned_line[1] != "=":
                        print(f"\n*******************************************************")
                        print(f"Error at {lines[i]}: No equality operator. Restored original.")
                        print(f"*******************************************************\n")
                        writeLog("script", "No equality operator at line " + lines[i].rstrip() + " in " + self.file.name)
                        self.restoreConf()
                        sys.exit()
                    elif self.file == rc_conf and re.match(loader_rc_conf_verify, partitioned_line[2]) == None:
                        print(f"\n*******************************************************")
                        print(f"Error: {self.flag} not allowed in {lines[i]} in {self.file}. Restored original.")
                        print(f"*******************************************************\n")
                        writeLog("script", "Quote matching error at line " + lines[i].rstrip())
                        self.restoreConf()
                        sys.exit()
                    elif self.file == loader_conf and re.match(loader_rc_conf_verify, partitioned_line[2]) == None:
                        print(f"\n*******************************************************")
                        print(f"Error: {self.flag} not allowed in {lines[i]} in {self.file}. Restored original.")
                        print(f"*******************************************************\n")
                        writeLog("script", "Quote matching error at line " + lines[i].rstrip())
                        self.restoreConf()
                        sys.exit()
                    elif self.file == sysctl_conf and re.match(sysctl_conf_verify, partitioned_line[2]) == None:
                        print(f"\n*******************************************************")
                        print(f"Error: {self.flag} not allowed in {lines[i].rstrip()} in {self.file}. Restored original.")
                        print(f"*******************************************************\n")
                        writeLog("script", "Quote in sysctl.conf at line " + lines[i])
                        self.restoreConf()
                        sys.exit()
                    else:
                        conf_directives.append(line.rstrip())
        except OSError as e:
            print(f"\n********************\033[38;5;1m Locked \033[0;0m**************************\n")
            print(f"Perhaps file is busy, locked, process blocked, or raced:\n") 
            print(f"{e}")
            print(f"*******************************************************\n")
    
    # If syntax verification fails, restore *.originals to prevent boot failure
    # If in single user read-only mode use commands:
    # zfs set readonly=false zroot
    # zfs mount -a
    def restoreConf(self):
        try:
            if self.file == rc_conf:
                shutil.copy(rc_backup, rc_conf)
            elif self.file == sysctl_conf:
                shutil.copy(sysctl_backup, sysctl_conf)
            elif self.file == loader_conf:
                shutil.copy(loader_backup, loader_conf)
        except FileNotFoundError as e:
            error_path = Path(e.filename)
            print(f"\n*******************\033[38;5;1m File Not Found \033[0;0m********************")
            print(f"Filename: {error_path.name}")
            print(f"Directories used: {error_path.parts}\n")
            print("*******************************************************\n")
        else:
            print(f"\n*********************\033[38;5;76m Success \033[0;0m*************************")
            print(f"Files restored")
            print("*******************************************************\n")



# Hardcoded sections as only t e contain flags we can dynamically set and re-set.
# Loops through all directives and sets each
class SetOpts:
    def __init__(self, section):
        self.section = section
        if self.section == "STARTUP":
            file = rc_conf
        elif self.section == "SYSTEM":
            file = sysctl_conf
        elif self.section == "KERNEL":
            file = loader_conf
        else:
            pass

        for opt in config[self.section]:
            value = config[self.section][opt]
            conf_runner = Conf(file, opt, value)
            setting_present = conf_runner.checkConf()
            if setting_present:
                conf_runner.setConf()
                conf_runner.verifyConf()
            else:
                conf_runner.addConf()
                conf_runner.verifyConf()
        


# Run shell commands for named section. Will error if sent setting.ini sections that have no shell commands.
def shellCommand(section):
    try:
        for opt in config[section]:
            value = config[section][opt]
            command_result = subprocess.run([value], shell=True, timeout=0.7)
    except subprocess.CalledProcessError as e:
        syslog.syslog(syslog.LOG_ERR, "Failure: Shell Command")
        print(f"\n*********************\033[38;5;1m Shell Error \033[0;0m*********************")
        print(f"Command {e.args[1]} failed")
        print(f"Terminated by {command_result.returncode}")
        print(f"{command_result.stderr}")
        print("*******************************************************\n")
    except OSError as e:
        print(f"\n********************\033[38;5;1m Locked \033[0;0m**************************\n")
        print(f"Perhaps file is busy, locked, process blocked, or raced:\n") 
        print(f"{e}")
        print(f"*******************************************************\n")
    else:
        print(f"\n*********************\033[38;5;76m Success \033[0;0m*************************")
        print(f"\033[38;5;208mShell Errors: \033[0;0m {command_result.stdout}")
        print(f"*******************************************************\n")



# Set chmod for added convienence of the adminstrator with error handling and logging
@exception_handler
def setChmod(file, setting):
        os.fchmod(file, setting)
        writeLog("script", file + "was set to " + setting )




# Main
writeLog("script", date_time)
SetOpts("STARTUP")
SetOpts("SYSTEM")
SetOpts("KERNEL")
shellCommand("FILESEC")
shellCommand("USERSEC")


# Write succesfull completion to console and syslog
writeLog("script", "************ SUCCESS ************")
writeLog("script", "All files and directives validate")
writeLog("script", "*********************************")
writeLog("syslog", "SUCCESS: Hardening completed")

