# UNIVERSAL SYMLINK INSTALLER

Simple script that will help you create Symlinks faster.  
It acts as both installer and uninstaller.

## Usage
1. Place the [**`usi.cmd`**](https://github.com/wvzxn/universal-symlink-installer/releases/latest/download/usi.cmd) file near the folder **`C`**, which may contain folders **`Program Files`**, **`ProgramData`**, **`Users`**, etc.
2. Open [**`usi.cmd`**](https://github.com/wvzxn/universal-symlink-installer/releases/latest/download/usi.cmd) as a text document and add [commands](https://github.com/wvzxn/universal-symlink-installer#commands) to execute.
3. Run [**`usi.cmd`**](https://github.com/wvzxn/universal-symlink-installer/releases/latest/download/usi.cmd).

To work correctly, you must recreate the system folder structure:
- :file_folder: ***root***
  - :hammer_and_wrench: ***usi.cmd***
  - :file_folder: ***C***
    - :file_folder: ***..***
    - :file_folder: ***Program Files***
      - :file_folder: ***..***
    - :file_folder: ***Users***
      - :file_folder: ***..***
      - :file_folder: ***(Name)***
        - :file_folder: ***..***

`(Name)` will be changed to [`%username%`](https://ss64.com/nt/syntax-variables.html)

:warning: Do not use these characters in the name of the root folder: `!@%^&[]'`

## Commands

Lines starting with `:::` are recognized by the script as commands to execute. <sup>*Do not confuse with comments `::`*</sup>

Correct command:

:heavy_check_mark: `::: C\..\..`

Comment, nothing will happen:

:warning: `:: C\..\..`  
:warning: `:::C\..\..`  
:warning: `:::: C\..\..`  

This may cause an error:

:x: `:C\..\..`

### Basic mode (Manual path entry)

The script recognizes the shortened [`mklink`](https://ss64.com/nt/mklink.html) command as shown below:

- `C\..\..`&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; — &nbsp;&nbsp;(default)  
- `/d C\..\..`&nbsp;&nbsp; — &nbsp;&nbsp;Directory symbolic link (from [v1.3](https://github.com/wvzxn/universal-symlink-installer/releases/tag/v1.3) can be omitted)  
- `/h C\..\..`&nbsp;&nbsp; — &nbsp;&nbsp;Hard link  
- `/j C\..\..`&nbsp;&nbsp; — &nbsp;&nbsp;Directory Junction

There is no need to put quotation marks:

:heavy_check_mark: `::: C\..\..\file`

:x: `::: "C\..\..\file"`

### Automatic mode (Regex)

The `/r` parameter activates automatic mode for the current line.

The script searches for the nearest matches in the path.  
You can also specify the symlink type for folders:

- `/d ..`&nbsp;&nbsp; — &nbsp;&nbsp;Directory symbolic link (can be omitted)
- `/j ..`&nbsp;&nbsp; — &nbsp;&nbsp;Directory Junction

#### Example

Folders that match: `TEST+FOLDER` , `TestFolder` , `test folder`:

:heavy_check_mark: `::: /r test.?folder` - symbolic link  
:heavy_check_mark: `::: /r test.?f.*?` - symbolic link  
:heavy_check_mark: `::: /r /j TEST.*?folder` - junction

:warning: `::: /r /j test.*folder` - `.*` may cause an error

:x: `::: /r testfolder` - not matches with `TEST+FOLDER` , `test folder`  
:x: `::: /r test folder` - not matches with `TestFolder`

### Other commands

You can also run standard commands like `md`, `icacls` etc. <sup>*In this case, you can use quotation marks*</sup>  
Use `!` instead of `%` to call a variable.

:heavy_check_mark: `::: md "!CommonProgramFiles!\dir !UserName!"`  
:heavy_check_mark: `::: echo Adding reg key...`  
:heavy_check_mark: `::: regedit -s "add_key.reg"`

:x: `::: for /f ..` - will cause an error

To execute the command only on uninstall add `//` parameter to the beginning of the line.

`::: // rd /s /q "!CommonProgramFiles!\dir !UserName!"`  
`::: // echo Removing reg key...`  
`::: // regedit -s "del_key.reg"`

#### .reg Smart Delete

`::: // /s del_key.reg`

This deletes empty keys after using del_key.reg

## Examples

### Example 1 (Automatic + Manual)

- :file_folder: ***Example Folder***
  - :hammer_and_wrench: ***usi.cmd***
  - :file_folder: ***C***
    - :file_folder: ***Program Files***
      - :file_folder: ***Example Company*** <sup>*</sup>
        - :file_folder: ***Example Product Folder***
        - :gear: ***Example Product File.dll***
    - :file_folder: ***Users***
      - :file_folder: ***(Name)***
        - :file_folder: ***Appdata***
          - :file_folder: ***Roaming***
            - :file_folder: ***Example Company*** <sup>*</sup>
              - :file_folder: ***Example Product Data Folder***

<sup>* — *Will be automatically created if not exist*</sup>

```
::: /r example.?product.*?
::: C\Program Files\Example Company\Example Product File.dll
```

### Example 2 (Manual)

- :file_folder: ***Example Folder***
  - :hammer_and_wrench: ***usi.cmd***
  - :old_key: ***add registry key.reg***
  - :old_key: ***del registry key.reg***
  - :file_folder: ***C***
    - :file_folder: ***Program Files***
      - :file_folder: ***Example Company*** <sup>*</sup>
        - :file_folder: ***Example Product Folder***
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

![image](https://user-images.githubusercontent.com/87862400/205160339-020a3d1f-b2f7-49da-b069-2577ac885cc3.png)
