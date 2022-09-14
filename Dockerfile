#
# Dockerfile for creating a Windows build environment for S7-Project-Explorer
# Copyright (c) 2022 Colin Finck, ENLYZE GmbH <c.finck@enlyze.com>
# SPDX-License-Identifier: MIT
#

FROM mcr.microsoft.com/windows/servercore:ltsc2022
MAINTAINER Colin Finck <c.finck@enlyze.com>
LABEL Description="Windows Server Core 2022 with Visual Studio Build Tools 2019 (incl. Clang) and Git"

SHELL ["powershell"]

# Download and install Visual Studio Build Tools 2019 (version 16.11.19)
# You can get direct URLs from https://docs.microsoft.com/de-de/visualstudio/releases/2019/history
RUN $ProgressPreference = 'SilentlyContinue'; \
    Invoke-WebRequest https://download.visualstudio.microsoft.com/download/pr/6d7709aa-465b-4604-b797-3f9c1d911e67/bf33ca62eacd6ffb4f9e9f8e9e72294ed2b055c1ccbd7a299f5c5451d16c8447/vs_BuildTools.exe -OutFile vs_buildtools.exe; \
    Start-Process -FilePath vs_buildtools.exe -ArgumentList (\"--quiet\", \"--wait\", \"--norestart\", \"--nocache\", \"--installPath\", \"C:\\BuildTools\", \"--add\", \"Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Core\", \"--add\", \"Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Llvm.Clang\", \"--add\", \"Microsoft.VisualStudio.Component.VC.ATL\", \"--add\", \"Microsoft.VisualStudio.Component.VC.Tools.x86.x64\", \"--add\", \"Microsoft.VisualStudio.Component.Windows10SDK.20348\") -Wait; \
    Remove-Item vs_buildtools.exe

# Download and install MinGit compiled with Busybox.
# This is the most container-compatible version of Git for Windows, all others failed for me. See also https://github.com/git-for-windows/git/issues/1403#issuecomment-355429601
RUN $ProgressPreference = 'SilentlyContinue'; \
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest https://github.com/git-for-windows/git/releases/download/v2.21.0.windows.1/MinGit-2.21.0-busybox-64-bit.zip -OutFile git.zip; \
    Expand-Archive git.zip -DestinationPath C:\git; \
    [System.Environment]::SetEnvironmentVariable(\"Path\", [System.Environment]::GetEnvironmentVariable(\"Path\", \"Machine\") + \";C:\git\cmd\", \"Machine\"); \
    Remove-Item git.zip
