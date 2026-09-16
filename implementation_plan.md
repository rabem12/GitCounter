# Fix Data Sharing Without App Groups (GitHub Distribution)

Since you are distributing this via GitHub and using a Free Developer Account, we hit the final macOS restriction: **Ad-Hoc signed apps cannot share App Groups.** Even though Xcode compiled successfully, macOS secretly isolated the Main App and the Widget into two separate fake App Groups, which is why the App sees "No Historical Data" while the Widget clearly has the data!

### The Ultimate Workaround
Since this app is distributed outside the Mac App Store, the Main App **does not need to be sandboxed**. 

If we remove the sandbox from the Main App, it gains access to the entire file system. This allows the Main App to directly read the Widget's private sandbox files! 

We will completely remove App Groups and use this architecture instead:
1. **The Widget (Sandboxed):** Writes its data to a normal file in its own Documents folder.
2. **The Main App (Unsandboxed):** Reaches directly into `~/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Documents/` to read the exact same file. 

This requires zero setup from the user, zero Apple Developer accounts, and works flawlessly for GitHub distribution!

## Proposed Changes

### GithubCounter/project.yml
- [MODIFY] Remove `ENABLE_APP_SANDBOX: YES` from the Main App.

### Shared/Services/HistoryManager.swift
- [MODIFY] Refactor to save/load from a JSON file located in the Widget's Sandbox container rather than `UserDefaults`.
- In the Widget, it uses the standard `FileManager` Documents directory.
- In the Main App, it constructs the absolute path to the Widget's container.

### Shared/Services/CacheManager.swift
- [MODIFY] Same as `HistoryManager`.

### GithubCounter/GithubCounter.entitlements & GithubCounterWidget/GithubCounterWidget.entitlements
- [MODIFY] Completely remove the App Group entitlements. They are no longer needed!

## Verification Plan
After applying, you will run the app. The widget will save a file to its container, and the Main App will immediately be able to read it and populate the "Trends & History" graph!
