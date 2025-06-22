![Contributions Welcome](https://img.shields.io/badge/Contributions-Welcome-orange?style=flat-square&logo=github)
![Maintained by elijamesku](https://img.shields.io/badge/Maintainer-elijamesku-blueviolet?style=flat-square&logo=github)

# Contributing to Zero-Touch Endpoint Setup

Thank you for your interest in contributing to **Zero-Touch Endpoint Setup**. It is an automation framework built with PowerShell to simulate enterprise-grade endpoint onboarding, offboarding, and configuration. 
``` 
 __     __     ______     __         ______     ______     __    __     ______        __  __     ______     __    __     ______    
/\ \  _ \ \   /\  ___\   /\ \       /\  ___\   /\  __ \   /\ "-./  \   /\  ___\      /\ \_\ \   /\  __ \   /\ "-./  \   /\  ___\   
\ \ \/ ".\ \  \ \  __\   \ \ \____  \ \ \____  \ \ \/\ \  \ \ \-./\ \  \ \  __\      \ \  __ \  \ \ \/\ \  \ \ \-./\ \  \ \  __\   
 \ \__/".~\_\  \ \_____\  \ \_____\  \ \_____\  \ \_____\  \ \_\ \ \_\  \ \_____\     \ \_\ \_\  \ \_____\  \ \_\ \ \_\  \ \_____\ 
  \/_/   \/_/   \/_____/   \/_____/   \/_____/   \/_____/   \/_/  \/_/   \/_____/      \/_/\/_/   \/_____/   \/_/  \/_/   \/_____/ 
                                                                                                                                   

```
This project aims to bridge the gap between local testing and cloud-scale deployment, whether or not you're using MDMs like Intune.



## Before You Start

- Read the [README](./README.md) to understand the project goals, structure, and execution flow.
- This project follows a **modular, testable, and portable** architecture. Keep your contributions aligned with that spirit.
- Have something major in mind? Open an issue first to discuss it before you spend hours coding.


## Setup

### To contribute:

1. Fork this repo
2. Clone your fork  
   ```bash
   git clone https://github.com/your-username/zero-touch-endpoint-setup.git
Create a new branch
```
git checkout -b feature/your-feature-name
```
Install PowerShell modules or prerequisites, if needed

## Run scripts using:
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```
```
.\install.ps1
```
## What hasnt been done
- JSON-driven improvements
- Enhanced error handling
- Windows Forms UI or GUI
- Azure/Intune integration
- Better uninstall detection
- Log shipping to cloud
- CI/CD with GitHub Actions
- Localization/multi-language support

## Coding 
PowerShell 5.1+ or 7.x compatible

## To know
- Use PascalCase for function names and camelCase for variables

- Modularize logic in reusable .ps1 files (don’t bloat install.ps1)

- Avoid hard-coded paths — always use $env: or relative paths

- Leave comments in complex logic blocks

- Use try/catch religiously — this is automation for real systems

## Commit Guidelines
Good commit messages help maintain sanity.  
Suggested format:  

- feat(logging): add JSON log writer for app installs
- fix(uninstall): handle missing uninstall string gracefully  
- docs(readme): add screenshot for feedback form

## Testing Your Changes
- Always test your script(s) on a fresh VM or snapshot

- Validate logs, feedback, and uninstall behavior

- Don’t break existing functionality (unless you're fixing it)

## Security Notes
Do NOT submit scripts that:

- Disable Defender permanently

- Tamper with UAC or system integrity

- Exfiltrate logs or data to non-transparent endpoints

## Contributor Recognition
All contributors will be listed in the README under "Contributors".
MVPs may get invited as repo collaborators.

## Found a Bug? Got an Idea?
Open an issue — include screenshots, logs, or repro steps

Tag it with bug, feature, question, or enhancement

## The end
"Don’t just automate. Orchestrate"

We shall build scripts that are clean, testable, and ready for real-world usage.. not one-off hackjobs. Your contributions should reflect that standard.

Let's build :D

```
 __     ______      __   __     ______     __   __   ______     ______        ______     __         ______     ______     ______   ______    
/\ \   /\__  _\    /\ "-.\ \   /\  ___\   /\ \ / /  /\  ___\   /\  == \      /\  ___\   /\ \       /\  ___\   /\  ___\   /\  == \ /\  ___\   
\ \ \  \/_/\ \/    \ \ \-.  \  \ \  __\   \ \ \'/   \ \  __\   \ \  __<      \ \___  \  \ \ \____  \ \  __\   \ \  __\   \ \  _-/ \ \___  \  
 \ \_\    \ \_\     \ \_\\"\_\  \ \_____\  \ \__|    \ \_____\  \ \_\ \_\     \/\_____\  \ \_____\  \ \_____\  \ \_____\  \ \_\    \/\_____\ 
  \/_/     \/_/      \/_/ \/_/   \/_____/   \/_/      \/_____/   \/_/ /_/      \/_____/   \/_____/   \/_____/   \/_____/   \/_/     \/_____/ 
```                                                                                                                                         

