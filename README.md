[![CyberArk Ready](https://img.shields.io/badge/CyberArk-ready-blue.svg)](https://www.cyberark.com)

# CyberArk Terminal Utility v1.0

CyberArk Terminal Utility (CTU) is a terminal interface that utilizes REST API to automate changes to CyberArk Enterprise Password Vault system. Built Using CyberArk PowerShell module [psPAS](https://github.com/pspete/psPAS), and [CyberArk RestAPI](https://github.com/infamousjoeg/CyberArk-RESTAPI).

<p align="center">
  <img src="https://github.com/zshehri/CTU/blob/master/Screenshots/cyberark_demo.gif">
</p>

### Latest Updates (also on this [Reddit post](https://redd.it/704q2q))

- First version released on 8/25/2017 (v1.0), with a limited functionality to manage safe permissions (see [Current Functions](https://github.com/zshehri/CTU#Current_Functions) below).
- If you want to test this version, choose number 3 (*Safe Permissions Management*) from the main menu, and choose any option from the submenu.
- The goal is to continue developing this tool by adding more functions in future releases.
- Currently I don't have access to CyberArk test server anymore, as soon as I do I will continue adding more features.

----------

## What's CyberArk PVWA ?

CyberArk Enterprise Password Vault is an enterprise solution designed to secure, audit and control access to privileged accounts in any organization, and automate the process of changing passwords of service accounts. The solution enables companies to mitigate the risk of unauthorized access to privileged accounts, and reduce the time & resources needed to maintain privileged accounts security, to better protect sensitive systems from compromise. CyberArk PVWA (Password Vault Web Access) is the web application, where users can retrieve passwords and manage safes.

More about CyberArk Enterprise Password Vault in the [official website](https://www.cyberark.com/products/privileged-account-security-solution/enterprise-password-vault/).

## CTU Features

CyberArk uses the web app as a GUI interface to manage the system, which makes it a bit difficult to perform bulk changes and automate changes to the vaulted accounts. Fortunately, CyberArk released [CyberArk REST API V9.9](http://cybr.rocks/RESTAPIv99) which allows terminal communications with the system.

CyberArk Terminal Utility (CTU) utilizes REST API to create a terminal interface that allows administrator to access CyberArk PVWA server and manage the system from a terminal interface on PowerShell. The main features are:

- Establishing a secure connection to your PVWA, and credentials will be handled as a PSCredentials Object (following the [best practice](https://social.technet.microsoft.com/wiki/contents/articles/4546.working-with-passwords-secure-strings-and-credentials-in-windows-powershell.aspx))
- Navigating through common options with a simple menu.
- Importing bulk changes from an Excel file (```import-csv``` cmdlet used for .csv, custom function created for .xls & .xlsx)
- Confirming the number of changes before executing them.
- Generating logs to the [Logs](https://github.com/zshehri/CTU/tree/master/Logs) folder of all changes made via CTU.

## Requirements

- PowerShell version 4.0 or above - (check your PS version using ```$PSVersionTable.PSVersion``` in PowerShell), install/update PowerShell using this site [Windows Management Framework](https://www.microsoft.com/en-us/download/details.aspx?id=54616)
- CyberArk version 9.7 or above - update using the official [CyberArk documentation](https://www.cyberark.com/resources) (may the force be with you!)
- Enable CyberArk PAS REST API/Web Service
- Make sure you have the appropriate permissions to the Vaults/Safes you want to change


## Getting Started:

- Download it on your computer (using the green button above) or
  clone it using the following command:
```bash
git clone https://github.com/zshehri/CTU
```

- Or update the existing folder:
```bash
git pull
```

To run `CTU.ps1`, you'd probably need to allow running scripts downloaded form the internet for this PowerShell session.

Open a new PowerShell as an admin, and paste the following command:
```powershell
powershell -ExecutionPolicy ByPass
```

and then run the script:
```PowerShell
C:\path to CTU folder\CTU.ps1
```

As soon as you're done from CTU, close the session to revert back to same ExecutionPolicy. (This workaround is the easiest, but not the best. [Here's why?](https://blog.netspi.com/15-ways-to-bypass-the-powershell-execution-policy/))


## Usage:

The menu should be clear enough for how to use the script. All inputs, outputs, and errors will handled through the terminal console.

Review the code before running it, you'll find tags that would help you customizing the tool for your needs:
- `[TEMP]`: you can hardcode your PVWA address in the tool, so you don't need to retype it every time.
- `[DEV]`: changes made but never tested, so I commented them out. If you want to contribute, here you go!
- `[DEBUG]`: of course you may have some errors along the way, search for this tag and enable the commented line to show verbose errors when needed.

## <a id="Current_Functions"></a>Current Functions:

- The initial motive of this script is to modify hundreds of user access permissions to safes, so users can be assigned one of the roles -below- describing the permissions they will get:
  1. User: Access to only use resources in the safe (vaulted passwords), list all safe users, and view audit trails.
  2. Owner: Access to manage resources in the safe, unlock accounts, and manage users access.
  3. System: All permissions are granted (meant for system accounts, such as PVWA default accounts ...)

- These roles will be imported from an excel file, following the [template](https://github.com/zshehri/CTU/blob/master/Templates/Bulk_permission_changes.csv).
- You can change these roles/permissions as you like to fit your needs (from [here](https://github.com/zshehri/CTU/blob/a4a8045b1e6d7f701072e12415dbb4568e66923b/CTU.ps1#L133))
- The script applied permission changes to over 500 users from an excel file and worked like a charm!

## Disclaimer:

**Please note: this is an unofficial project and still under development!**

*Be aware that CTU is run at your own risk and while every script has been written with the intention of minimizing the potential for unintended consequences, the author and contributors cannot be held responsible for any misuse or script problems.*

*THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.*

### Author:

Ziyad Alshehri

### Contributing:

- Review comments on this [Reddit post](https://redd.it/704q2q)
- Fork the repo
- Use the updated [psPAS](https://github.com/pspete/psPAS) (review [compatibility](https://github.com/pspete/psPAS#CyberArk_Version_Compatibility))
 - Push your changes to your fork
 - Write a [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
 - Submit a pull request
	 - Keep pull requests limited to a single issue
	 - Discussion, or necessary changes may be needed before merging the contribution.

### Credits:

-[Pete Maan](https://github.com/pspete): for [psPAS](https://github.com/pspete/psPAS) module which was extremely helpful to interface with CyberArk RestAPI using PowerShell

-[Joe Garcia](https://github.com/infamousjoeg): for the official [CyberArk RestAPI](https://git.joeco.de/CyberArk-RESTAPI) documentation, and for Password Utility Upload [PUU v2](https://git.joeco.de/PasswordUploadUtility-v2)
