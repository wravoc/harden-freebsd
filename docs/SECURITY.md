# Security Policy



## Report a Vulnerability

1. Open a Github Private Vulnerability Report for "Wravoc" using the "Security" Tab on the home page of the repository following [best practices](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing/best-practices-for-writing-repository-security-advisories). Click **Report a vulnerability** to open the advisory form.
2. If you believe this vulnerability is severe or wish to send files please email [elias@quadhelion.engineering](mailto:elias@quadhelion.engineering) expecting a reply within 48 hours. 



## How to report a vulnerability

Please include:

* Your Operating System details including:

  * Who was file system owner of the Software
  * What were the file system permissions on the Software
  * What networking processes had access to that file
  * What command was used to Execute the Software
  * Where the Software was located when it was Executed
  
* Your Python Environment Details including:

  * PDB output

    * `python3 -m pdb authlog-threats.py`

  * What modules were loaded at the time the Software was Executed

    * ```
      import sys
      import pprint
      
      # pretty print loaded modules
      pprint.pprint(sys.modules)
      ```

  * Version

  * Automations 

    * Including automatic Python repository, pip, or relevant software updating

  * Other Python scripts that had access to the Software

* What customizations you used in the Software

* Thorough details of vulnerability exploit

  * What process was used to prove the exploit
  * What files were touched
  * Relevant shell history during the process
  * Relevant sections of logs detailing this outcome
  * Screenshots of all the above
  * The hash and file size of the Software
  



## Confidentiality

Do not publically post information on how to utilize the vulnerability or details which others may find able to utilize the vulnerablity. 