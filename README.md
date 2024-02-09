 # UPX-Fix Project Readme
This project aims to create a tool that can fix the smashed UPX headers of malicious ELF binaries, particularly focusing on fixing the zeroed l_info & p_info headers.

## Table of Contents
1. [Introduction](#introduction)
2. [Requirements](#requirements)
3. [How to Use UPX-Fix](#how-to-use-upx-fix)
    - 3.1 [Command Line Interface (CLI)](#command-line-interface-cli)
4. [Project Structure and Code Explanation](#project-structure-and-code-explanation)
5. [References](#credits-and-references)

## Introduction
The UPX-Fix project provides a tool that can repair the headers of ELF binaries with zeroed UPX headers. This can be particularly useful when analyzing malware samples, as many malicious samples (for example **Mozi** malware) are intentionally damaged to hinder unpacking.

## Requirements
To use this project, you will need to have Nim lang installed on your system or download precompiled executables. This can be done by following the instructions on the [Nim website](https://nim-lang.org/install.html).

## How to Use UPX-Fix

UPX-Fix can be run from the command line interface using its built-in script or by manually executing the compiled binary.

To build and execute the CLI version of UPX-Fix, follow these steps:
1. Open your terminal or command prompt.
2. Navigate to the directory containing the source code file `upx_fix.nim`.
3. Run the following command to compile the script into an executable binary:
    ```
    nimble build
    ```
4. Once compiled, you can use the following command to execute UPX-Fix with the `-h` flag to display the help menu:
    ```
    ./upx_fix -h
    ```
5. To fix a file, simply provide its path as an argument to the `-f` or `--file` flag followed by any additional optional arguments, such as the `-f` or `--force` flag to force overwriting of existing files without confirmation. For example:
    ```
    ./upx_fix malware_sample
    ```
6. Unpack newly created `malware_sample.fix` like normal upx executable:
    ```
    upx -d malware_sample.fix
    ```

## Project Structure and Code Explanation
The source code file `upx_fix.nim` contains the implementation of the UPX-Fix tool. It uses the Nim programming language, which provides a clean and readable syntax while offering strong static typing features. The project also relies on third-party libraries such as `cligen` for command line interface.

The code primarily consists of three main procedures:
1. `getMagicOffset(s: MemFile): int`: This procedure searches for the magic number "UPX!" in the memory file and returns its offset from the start of the file. If it cannot find the magic number, it displays an error message and exits without fixing the file.
2. `recoverFileSize(s: MemFile): uint32`: This procedure attempts to recover the original file size by reading the last 12 bytes of the memory file and interpreting them as a 32-bit unsigned integer. If it successfully recovers the file size, it updates the corresponding structure field in the Pinfo object.
3. `fix(fileName: string, force = false)`: This procedure is responsible for fixing the given file by reading its content, extracting relevant data structures (l_info and p_info), updating their fields based on the recovered file size, and writing the modified memory file back to disk with a new extension (e.g., `.fix`).

## References

* [UPX Anti-Unpacking Techniques in IoT Malware](https://cujo.com/blog/upx-anti-unpacking-techniques-in-iot-malware/)