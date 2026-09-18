# Privacy Policy for GitCounter

**Effective Date:** September 18, 2026  
**Publisher:** Black Pinion LLC  

Black Pinion LLC ("we", "us", or "our") built **GitCounter** as an independent native macOS application and desktop widget. We are committed to safeguarding your privacy. This Privacy Policy explains how GitCounter handles data, credential security, and network communication.

---

## 1. Zero Tracking & No Data Collection

* **No Analytics or Telemetry:** GitCounter contains zero analytics SDKs, advertising frameworks, third-party trackers, or crash reporting agents.
* **No Middleman Servers:** Black Pinion LLC does not own, operate, or route your data through any intermediate servers or databases. 
* **Zero Personal Information Collected:** We do not collect, harvest, store, or sell any personal data, IP addresses, browsing habits, or usage metrics.

---

## 2. GitHub Personal Access Tokens (PAT) Security

GitCounter allows optional entry of a GitHub Personal Access Token (PAT) with `repo` scope to enable enhanced traffic metrics (clones and visits).

* **macOS Keychain Encryption:** Your Personal Access Token is encrypted and stored exclusively inside your Mac's native **macOS Keychain Services** (`kSecClassGenericPassword`).
* **Hardware-Backed Protection:** Access to your token is protected by macOS Keychain access control policies. It is never stored in plain text, never written to log files, and never transmitted to Black Pinion LLC or any third party.

---

## 3. Network Communications

GitCounter connects over the internet exclusively to communicate with the official GitHub REST API:

* **Direct Encrypted HTTPS:** All network requests are dispatched directly from your local Mac over secure TLS/HTTPS to GitHub's official endpoints (`https://api.github.com`).
* **Endpoints Accessed:**
  * Releases and download statistics: `GET /repos/{owner}/{repo}/releases`
  * Repository metadata: `GET /repos/{owner}/{repo}`
  * Traffic clones (requires PAT): `GET /repos/{owner}/{repo}/traffic/clones`
  * Traffic views (requires PAT): `GET /repos/{owner}/{repo}/traffic/views`
* All network communication is subject to [GitHub's Privacy Statement](https://docs.github.com/en/site-policy/privacy-policies/github-privacy-statement).

---

## 4. Local Data Storage

All data utilized by GitCounter is stored strictly on your local device:

* **Metrics Cache:** Repository statistics and delta snapshots are cached locally on your device to ensure widgets render instantly and remain functional offline or between API rate limits.
* **Notes Scratchpad:** Any notes or release logs you author inside the Notes tab are stored locally in application support files.
* **Data Deletion:** You can delete cached data, stored repositories, and your Personal Access Token at any time directly through the app settings or by deleting the app from your Mac.

---

## 5. Contact & Privacy Inquiries

If you have questions, feedback, or security inquiries regarding this Privacy Policy or GitCounter, please open an issue or discussion on the official GitHub repository:

* **GitHub Repository Issues:** Please submit an issue via the repository's [Issues tracker](https://github.com/rabem12/GitCounter/issues).

---

## 6. Trademark Safe-Harbor Notice

Git and the Git logo are trademarks of Software Freedom Conservancy, Inc. GitCounter is an independent tool developed by Black Pinion LLC and is not affiliated with, endorsed by, or sponsored by Software Freedom Conservancy or GitHub, Inc.
