# UNIVERSAL SYMLINK INSTALLER

##### *version: 1.4f*

Simple script that will help you speed up the Symlink creation process on Windows OS.  
It acts as both an installer and a uninstaller.

## Usage
1. Place the [**`usi.cmd`**](https://github.com/wvzxn/universal-symlink-installer/releases/latest/download/usi.cmd) file near the folder **`C`**, which may contain folders **`Program Files`**, **`ProgramData`**, **`Users`**, etc.
2. Open [**`usi.cmd`**](https://github.com/wvzxn/universal-symlink-installer/releases/latest/download/usi.cmd) as a text document and add [commands](https://github.com/wvzxn/universal-symlink-installer#commands) to execute.
3. Run [**`usi.cmd`**](https://github.com/wvzxn/universal-symlink-installer/releases/latest/download/usi.cmd).

To work correctly, you must recreate the system folder structure:
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

Lines starting with `:::` are recognized by the script as commands to execute. <sup>*Do not confuse with comments `::`*</sup>

:heavy_check_mark: `:: C\..\..` - a comment, nothing will happen  
:heavy_check_mark: `::: C\..\..` - the correct command  
:x: `:::: C\..\..` , `::::: C\..\..` - may cause an error

___

The script recognizes the shortened [`mklink`](https://ss64.com/nt/mklink.html) command as shown below:

- `C\..\..`&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; — &nbsp;&nbsp;(default)  
- `/d C\..\..`&nbsp;&nbsp; — &nbsp;&nbsp;Directory symbolic link (from [v1.3](https://github.com/wvzxn/universal-symlink-installer/releases/tag/v1.3) not necessary)  
- `/h C\..\..`&nbsp;&nbsp; — &nbsp;&nbsp;Hard link  
- `/j C\..\..`&nbsp;&nbsp; — &nbsp;&nbsp;Directory Junction

There is no need to put quotation marks

:heavy_check_mark: `::: C\..\..\file`  
:x: `::: "C\..\..\file"`

___

You can also run standard commands like `md`, `icacls` etc. <sup>*In this case, you can use quotation marks*</sup>

:heavy_check_mark: `::: md "%CommonProgramFiles%\dir %UserName%"`  
:heavy_check_mark: `::: attrib +h "C\..\..\file"`  
:heavy_check_mark: `::: echo Adding reg key...`  
:heavy_check_mark: `::: regedit -s add_key.reg`

To execute the command only on uninstall add `//` parameter to the beginning of the line.

:heavy_check_mark: `::: // rd /s /q "%CommonProgramFiles%\dir %UserName%"`  
:heavy_check_mark: `::: // attrib -h "C\..\..\file"`  
:heavy_check_mark: `::: // echo Removing reg key...`  
:heavy_check_mark: `::: // regedit -s del_key.reg`

## Example
- :file_folder: ***Example Folder***
  - :hammer_and_wrench: ***usi.cmd***
  - :old_key: ***add registry key.reg***
  - :old_key: ***del registry key.reg***
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
::: C\Program Files\Example Company\Example Product Folder
::: C\Users\(Name)\Appdata\Roaming\Example Company\Example Product Data Folder
::: regedit -s "add registry key.reg"
::: // regedit -s "del registry key.reg"
```
![image](https://user-images.githubusercontent.com/87862400/196798049-839c3736-d44b-44b6-b2a6-88a2aa4b78a9.png)
