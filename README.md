# DirTravler
# 🔍 DirTravler - Subdomain Discovery Automation Tool

**DirTravler** is a powerful and automated shell-based tool designed for **penetration testers**, **bug bounty hunters**, and **security researchers**. It focuses on **collecting subdomains** from a list of target domains provided in `domains.txt` using the industry-standard tool [`subfinder`](https://github.com/projectdiscovery/subfinder).

## 🚀 Features

- ✅ Automatically extracts subdomains for multiple domains.
- ✅ Cleans domain input (strips http/https, slashes).
- ✅ Saves results for each domain in organized text files.
- ✅ Fast, silent, and ideal for chaining with tools like `httpx`, `nuclei`, and `dirsearch`.
- ✅ Fully scriptable and customizable for CI/CD and automation pipelines.

---

## 📌 Why DirTravler?

Penetration testers often need to **enumerate subdomains** quickly and reliably for hundreds of domains. This tool automates that process:

- 📁 Structured output (one file per domain).
- 🧠 Cleans up messy domain lists.
- 🧪 Finds attack surfaces (subdomains that may expose services or apps).
- 💡 Saves time and effort by integrating with your existing recon workflow.

---

## 🛠️ Requirements

- Linux / WSL environment
- `subfinder` must be installed (you already have it)
- Bash shell

---

## 📂 Folder Structure After Execution

