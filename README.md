# UNIVERSAL SYMLINK INSTALLER
Simple script that will help you speed up the Symlink creation process on Windows OS.

It acts as both an installer and a uninstaller.
## Usage
1. Place the **`usi.cmd`** file near the folder **`C`**, which may contain folders **`Program Files`**, **`ProgramData`**, **`Users`**, etc.
2. Open **`usi.cmd`** as a text document and add commands to execute.
3. Run **`usi.cmd`**

To work correctly, you must recreate the system folder structure.
- :file_folder: ***..***
  - :hammer_and_wrench: ***usi.cmd***
  - :file_folder: ***C***
    - :file_folder: ***..***
    - :file_folder: ***Program Files***
      - :file_folder: ***..***
    - :file_folder: ***Users***
      - :file_folder: ***..***
      - :file_folder: ***(Name)***
        - :file_folder: ***..***

*`(Name)` will be changed to [`%username%`](https://ss64.com/nt/syntax-variables.html)*
## Commands
Lines starting with `:::` are recognized by the script as commands to execute <sup>*Do not confuse with comments `::`*</sup>

The script recognizes the shortened [`mklink`](https://ss64.com/nt/mklink.html) command as shown below
```
C\..\..       ||    (default)
/d C\..\..    ||    Directory symbolic link (default is file)
/h C\..\..    ||    Hard link
/j C\..\..    ||    Directory Junction
```
There is also no need to put quotation marks

:heavy_check_mark: `C\..\..\file`

:x: `"C\..\..\file"`
___
You can also run standard commands like `md ..`.
But line that starts with `/` and `C\` can cause an error.
## Example
- :file_folder: ***Example Folder***
  - :hammer_and_wrench: ***usi.cmd***
  - :old_key: ***registry_key.reg***
  - :file_folder: ***C***
    - :file_folder: ***Program Files***
      - :file_folder: ***Example Company*** <sup>*</sup>
        - :file_folder: ***Example Product***
        - :gear: ***Example Product File.dll***
    - :file_folder: ***Users***
      - :file_folder: ***(Name)***
        - :file_folder: ***Appdata***
          - :file_folder: ***Roaming***
            - :file_folder: ***Example Company*** <sup>*</sup>
              - :file_folder: ***Example Product Data Folder***

<sup>* — *Will be automatically created if not exist*</sup>

```
:: Some info :)
::: C\Program Files\Example Company\Example Product File.dll
::: /d C\Program Files\Example Company\Example Product
::: /d C\Users\(Name)\Appdata\Roaming\Example Company\Example Product Data Folder
::: regedit -s registry_key.reg
```
